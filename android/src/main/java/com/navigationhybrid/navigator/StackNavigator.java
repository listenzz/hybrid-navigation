package com.navigationhybrid.navigator;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
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
    public void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull ReadableMap extras) {
        NavigationFragment navigationFragment = getNavigationFragment(fragment);
        if (navigationFragment == null) {
            return;
        }

        AwesomeFragment target = null;
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
                target = getReactBridgeManager().createFragment(moduleName, props, options);
            }
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
                case "pushLayout":
                    ReadableMap layout = extras.getMap("layout");
                    target = getReactBridgeManager().createFragment(layout);
                    if (target != null) {
                        navigationFragment.pushFragment(target);
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
