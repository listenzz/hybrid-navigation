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
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.TabBarFragment;

public class TabNavigator implements Navigator {

    private List<String> supportActions = Arrays.asList("switchToTab", "switchTab");

    @Override
    public String name() {
        return "tabs";
    }

    @Override
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableArray tabs = layout.getArray(name());
            List<AwesomeFragment> fragments = new ArrayList<>();
            for (int i = 0, size = tabs.size(); i < size; i++) {
                ReadableMap tab = tabs.getMap(i);
                AwesomeFragment awesomeFragment = getReactBridgeManager().createFragment(tab);
                if (awesomeFragment != null) {
                    fragments.add(awesomeFragment);
                }
            }
            if (fragments.size() > 0) {
                ReactTabBarFragment tabBarFragment = new ReactTabBarFragment();
                tabBarFragment.setChildFragments(fragments);
                if (layout.hasKey("options")) {
                    ReadableMap options = layout.getMap("options");
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
    public boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> root, ArrayList<Bundle> modal) {
        if (fragment instanceof TabBarFragment) {
            TabBarFragment tabs = (TabBarFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = tabs.getChildFragments();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                getReactBridgeManager().buildRouteGraph(child, children, modal);
            }
            Bundle graph = new Bundle();
            graph.putString("type", name());
            graph.putInt("selectedIndex", tabs.getSelectedIndex());
            graph.putParcelableArrayList(name(), children);
            root.add(graph);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryChildFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof TabBarFragment) {
            TabBarFragment tabs = (TabBarFragment) fragment;
            return getReactBridgeManager().primaryChildFragment(tabs.getSelectedFragment());
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull ReadableMap extras) {
        switch (action) {
            case "switchToTab":
            case "switchTab":
                TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                if (tabBarFragment != null) {
                    AwesomeFragment presented = tabBarFragment.getPresentedFragment();
                    if (presented != null) {
                        presented.dismissFragment();
                    }
                    int index = extras.getInt("index");
                    tabBarFragment.setSelectedIndex(index);
                }
                break;
        }
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }

}
