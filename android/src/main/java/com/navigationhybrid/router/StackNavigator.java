package com.navigationhybrid.router;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactNavigationFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DrawerFragment;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.TabBarFragment;

public class StackNavigator implements Navigator {

    private List<String> supportActions = Arrays.asList("push", "pop", "popTo", "popToRoot", "replace", "replaceToRoot");

    @Override
    public String name() {
        return "stack";
    }

    @Override
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableMap stack = layout.getMap(name());
            AwesomeFragment fragment = getReactBridgeManager().createFragment(stack);
            if (fragment != null) {
                if (layout.hasKey("options") && fragment instanceof HybridFragment) {
                    HybridFragment hybridFragment = (HybridFragment) fragment;
                    Bundle bundle = Arguments.toBundle(layout.getMap("options"));
                    hybridFragment.setOptions(bundle);
                }
                ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
                reactNavigationFragment.setRootFragment(fragment);
                return reactNavigationFragment;
            } else {
                throw new IllegalArgumentException("can't create stack component with " + layout);
            }
        }
        return null;
    }

    @Override
    public boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> graph) {
        if (fragment instanceof NavigationFragment) {
            NavigationFragment stack = (NavigationFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = stack.getChildFragmentsAtAddedList();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                getReactBridgeManager().buildRouteGraph(child, children);
            }
            Bundle bundle = new Bundle();
            bundle.putString("type", name());
            bundle.putParcelableArrayList(name(), children);
            graph.add(bundle);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryChildFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof NavigationFragment) {
            NavigationFragment stack = (NavigationFragment) fragment;
            return getReactBridgeManager().primaryChildFragment(stack.getTopFragment());
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull Bundle extras) {
        NavigationFragment navigationFragment = getNavigationFragment(fragment);
        if (navigationFragment != null) {
            String moduleName = extras.getString("moduleName");
            AwesomeFragment target = null;
            if (moduleName != null) {
                Bundle props = extras.getBundle("props");
                Bundle options = extras.getBundle("options");
                target = getReactBridgeManager().createFragment(moduleName, props, options);
            }
            switch (action) {
                case "push":
                    if (target != null) {
                        navigationFragment.pushFragment(target);
                    }
                    break;
                case "pop":
                    navigationFragment.popFragment();
                    break;
                case "popTo":
                    String targetId = extras.getString("targetId");
                    target = (AwesomeFragment) navigationFragment.getChildFragmentManager().findFragmentByTag(targetId);
                    if (target != null) {
                        navigationFragment.popToFragment(target);
                    }
                    break;
                case "popToRoot":
                    navigationFragment.popToRootFragment();
                    break;
                case "replace":
                    if (target != null) {
                        navigationFragment.replaceFragment(target);
                    }
                    break;
                case "replaceToRoot":
                    if (target != null) {
                        navigationFragment.replaceToRootFragment(target);
                    }
                    break;
            }
        }
    }

    private NavigationFragment getNavigationFragment(AwesomeFragment fragment) {
        if (fragment != null) {
            NavigationFragment navigationFragment = fragment.getNavigationFragment();
            if (navigationFragment == null && fragment.getDrawerFragment() != null) {
                DrawerFragment drawerFragment = fragment.getDrawerFragment();
                TabBarFragment tabBarFragment = drawerFragment.getContentFragment().getTabBarFragment();
                if (tabBarFragment != null) {
                    navigationFragment = tabBarFragment.getSelectedFragment().getNavigationFragment();
                } else {
                    navigationFragment = drawerFragment.getContentFragment().getNavigationFragment();
                }
            }
            return navigationFragment;
        }
        return null;
    }


    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.instance;
    }
}
