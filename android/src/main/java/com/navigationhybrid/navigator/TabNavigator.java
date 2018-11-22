package com.navigationhybrid.navigator;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactTabBarFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.TabBarFragment;

public class TabNavigator implements Navigator {

    private List<String> supportActions = Collections.singletonList("switchTab");

    @Override
    @NonNull
    public String name() {
        return "tabs";
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
            ReadableMap tabs = layout.getMap(name());
            ReadableArray children = tabs.getArray("children");
            List<AwesomeFragment> fragments = new ArrayList<>();
            for (int i = 0, size = children.size(); i < size; i++) {
                ReadableMap tab = children.getMap(i);
                AwesomeFragment awesomeFragment = getReactBridgeManager().createFragment(tab);
                if (awesomeFragment != null) {
                    fragments.add(awesomeFragment);
                }
            }
            if (fragments.size() > 0) {
                ReactTabBarFragment tabBarFragment = new ReactTabBarFragment();
                tabBarFragment.setChildFragments(fragments);
                if (tabs.hasKey("options")) {
                    ReadableMap options = tabs.getMap("options");
                    if (options.hasKey("selectedIndex")) {
                        int selectedIndex = options.getInt("selectedIndex");
                        tabBarFragment.setSelectedIndex(selectedIndex);
                    }
                }
                return tabBarFragment;
            } else {
                throw new IllegalArgumentException("tabs layout should has a child at least");
            }
        }
        return null;
    }

    @Override
    public boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment instanceof TabBarFragment) {
            TabBarFragment tabs = (TabBarFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = tabs.getChildFragments();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                getReactBridgeManager().buildRouteGraph(child, children, modal);
            }
            Bundle graph = new Bundle();
            graph.putString("layout", name());
            graph.putString("sceneId", fragment.getSceneId());
            graph.putParcelableArrayList("children", children);
            graph.putString("mode", Navigator.Util.getMode(fragment));
            Bundle state = new Bundle();
            state.putInt("selectedIndex", tabs.getSelectedIndex());
            graph.putBundle("state", state);
            root.add(graph);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof TabBarFragment) {
            TabBarFragment tabs = (TabBarFragment) fragment;
            return getReactBridgeManager().primaryFragment(tabs.getSelectedFragment());
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action, @NonNull ReadableMap extras) {
        switch (action) {
            case "switchTab":
                TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                if (tabBarFragment != null) {
                    AwesomeFragment presented = tabBarFragment.getPresentedFragment();
                    if (presented != null) {
                        presented.dismissFragment();
                    }
                    int index = extras.getInt("index");
                    boolean popToRoot = extras.getBoolean("popToRoot");
                    if (popToRoot && index != tabBarFragment.getSelectedIndex()) {
                        NavigationFragment nav = fragment.getNavigationFragment();
                        if (nav != null) {
                            nav.popToRootFragment(false);
                        }
                    }
                    tabBarFragment.setSelectedIndex(index);
                }
                break;
        }
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }

}
