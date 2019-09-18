package com.navigationhybrid.navigator;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.navigation.androidx.NavigationFragment;
import com.navigation.androidx.TabBarFragment;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactNavigationFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class StackNavigator implements Navigator {

    private List<String> supportActions = Arrays.asList("push", "pushLayout", "pop", "popTo", "popToRoot", "replace", "replaceToRoot");

    @Override
    @NonNull
    public String name() {
        return "stack";
    }

    @Override
    @NonNull
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(@NonNull ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableMap stack = layout.getMap(name());
            if (stack == null) {
                throw new IllegalArgumentException("stack should be an object.");
            }
            ReadableArray children = stack.getArray("children");
            if (children == null) {
                throw new IllegalArgumentException("children is required, and it is an array.");
            }
            ReadableMap root = children.getMap(0);
            AwesomeFragment rootFragment = getReactBridgeManager().createFragment(root);
            if (rootFragment != null) {
                ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
                reactNavigationFragment.setRootFragment(rootFragment);
                return reactNavigationFragment;
            } else {
                throw new IllegalArgumentException("can't create stack component with " + layout);
            }
        }
        return null;
    }

    @Override
    public boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment instanceof NavigationFragment && fragment.isAdded()) {
            NavigationFragment stack = (NavigationFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = stack.getChildFragmentsAtAddedList();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                if (!child.getShowsDialog()) {
                    getReactBridgeManager().buildRouteGraph(child, children, modal);
                }
            }
            Bundle graph = new Bundle();
            graph.putString("layout", name());
            graph.putString("sceneId", stack.getSceneId());
            graph.putParcelableArrayList("children", children);
            graph.putString("mode", Navigator.Util.getMode(fragment));
            root.add(graph);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof NavigationFragment && fragment.isAdded()) {
            NavigationFragment stack = (NavigationFragment) fragment;
            return getReactBridgeManager().primaryFragment(stack.getTopFragment());
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras) {
        NavigationFragment navigationFragment = getNavigationFragment(target);
        if (navigationFragment == null) {
            return;
        }

        AwesomeFragment fragment = null;
        if (extras.hasKey("moduleName")) {
            String moduleName = extras.getString("moduleName");
            if (moduleName != null) {
                Bundle props = null;
                Bundle options = null;
                if (extras.hasKey("props")) {
                    props = Arguments.toBundle(extras.getMap("props"));
                }
                if (extras.hasKey("options")) {
                    options = Arguments.toBundle(extras.getMap("options"));
                }
                fragment = getReactBridgeManager().createFragment(moduleName, props, options);
            }
        }

        switch (action) {
            case "push":
                if (fragment != null) {
                    navigationFragment.pushFragment(fragment);
                }
                break;
            case "pop":
                navigationFragment.popFragment();
                break;
            case "popTo":
                String targetId = extras.getString("targetId");
                fragment = (AwesomeFragment) navigationFragment.getChildFragmentManager().findFragmentByTag(targetId);
                if (fragment != null) {
                    navigationFragment.popToFragment(fragment);
                }
                break;
            case "popToRoot":
                navigationFragment.popToRootFragment();
                break;
            case "replace":
                if (fragment != null) {
                    navigationFragment.replaceFragment(fragment, target);
                }
                break;
            case "replaceToRoot":
                if (fragment != null) {
                    navigationFragment.replaceToRootFragment(fragment);
                }
                break;
            case "pushLayout":
                ReadableMap layout = extras.getMap("layout");
                fragment = getReactBridgeManager().createFragment(layout);
                if (fragment != null) {
                    navigationFragment.pushFragment(fragment);
                }
                break;
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
        return ReactBridgeManager.get();
    }
}
