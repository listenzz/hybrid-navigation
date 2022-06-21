package com.reactnative.hybridnavigation.navigator;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.StackFragment;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TransitionAnimation;
import com.reactnative.hybridnavigation.HybridFragment;
import com.reactnative.hybridnavigation.Navigator;
import com.reactnative.hybridnavigation.ReactBridgeManager;
import com.reactnative.hybridnavigation.ReactTabBarFragment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class TabNavigator implements Navigator {

    private final List<String> supportActions = Collections.singletonList("switchTab");

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
        if (!layout.hasKey(name())) {
            return null;
        }

        ReadableMap tabs = layout.getMap(name());
        if (tabs == null) {
            throw new IllegalArgumentException("tabs should be an object");
        }

        ReadableArray children = tabs.getArray("children");
        if (children == null) {
            throw new IllegalArgumentException("children is required and it is an array");
        }

        List<AwesomeFragment> fragments = createChildrenFragment(children);

        if (fragments.size() == 0) {
            throw new IllegalArgumentException("tabs layout should has a child at least");
        }

        ReactTabBarFragment tabBarFragment = new ReactTabBarFragment();
        tabBarFragment.setChildFragments(fragments);
        if (tabs.hasKey("options")) {
            setTabsOptions(tabs, tabBarFragment);
        }

        return tabBarFragment;
    }

    private void setTabsOptions(ReadableMap tabs, ReactTabBarFragment tabBarFragment) {
        ReadableMap options = tabs.getMap("options");
        if (options == null) {
            throw new IllegalArgumentException("options should be an object");
        }

        Bundle bundle = new Bundle();
        if (options.hasKey("selectedIndex")) {
            int selectedIndex = options.getInt("selectedIndex");
            tabBarFragment.setSelectedIndex(selectedIndex);
            bundle.putInt("selectedIndex", selectedIndex);
        }

        if (options.hasKey("tabBarModuleName")) {
            String tabBarModuleName = options.getString("tabBarModuleName");
            bundle.putString("tabBarModuleName", tabBarModuleName);
        }

        if (options.hasKey("sizeIndeterminate")) {
            boolean sizeIndeterminate = options.getBoolean("sizeIndeterminate");
            bundle.putBoolean("sizeIndeterminate", sizeIndeterminate);
        }

        tabBarFragment.setOptions(bundle);
    }

    @NonNull
    private List<AwesomeFragment> createChildrenFragment(ReadableArray children) {
        List<AwesomeFragment> fragments = new ArrayList<>();
        for (int i = 0, size = children.size(); i < size; i++) {
            ReadableMap child = children.getMap(i);
            AwesomeFragment awesomeFragment = getReactBridgeManager().createFragment(child);
            if (awesomeFragment != null) {
                fragments.add(awesomeFragment);
            }
        }
        return fragments;
    }

    @Nullable
    @Override
    public Bundle buildRouteGraph(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof TabBarFragment) || !fragment.isAdded()) {
            return null;
        }

        TabBarFragment tabs = (TabBarFragment) fragment;
        ArrayList<Bundle> children = buildChildrenGraph(tabs);
        Bundle graph = new Bundle();
        graph.putString("layout", name());
        graph.putString("sceneId", fragment.getSceneId());
        graph.putParcelableArrayList("children", children);
        graph.putString("mode", Navigator.Util.getMode(fragment));
        graph.putInt("selectedIndex", tabs.getSelectedIndex());
        return graph;
    }

    @NonNull
    private ArrayList<Bundle> buildChildrenGraph(TabBarFragment tabs) {
        ArrayList<Bundle> children = new ArrayList<>();
        List<AwesomeFragment> fragments = tabs.getChildAwesomeFragments();
        for (int i = 0; i < fragments.size(); i++) {
            AwesomeFragment child = fragments.get(i);
            Bundle graph = getReactBridgeManager().buildRouteGraph(child);
            if (graph != null) {
                children.add(graph);
            }
        }
        return children;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof TabBarFragment) || !fragment.isAdded()) {
            return null;
        }

        TabBarFragment tabs = (TabBarFragment) fragment;
        return getReactBridgeManager().primaryFragment(tabs.getSelectedFragment());
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Promise promise) {
        TabBarFragment tabBarFragment = target.getTabBarFragment();
        if (tabBarFragment == null) {
            promise.resolve(false);
            return;
        }

        if ("switchTab".equals(action)) {
            handleSwitchTab(extras, promise, tabBarFragment);
        }
    }

    private void handleSwitchTab(@NonNull ReadableMap extras, @NonNull Promise promise, TabBarFragment tabBarFragment) {
        int to = extras.getInt("to");
        if (isSameTab(to, extras)) {
            promise.resolve(true);
            return;
        }

        popToStackRootIfNeeded(extras, tabBarFragment);

        if (!(tabBarFragment instanceof ReactTabBarFragment)) {
            tabBarFragment.setSelectedIndex(to, () -> promise.resolve(true));
            return;
        }

        ReactTabBarFragment reactTabBarFragment = (ReactTabBarFragment) tabBarFragment;
        reactTabBarFragment.setIntercepted(false);
        reactTabBarFragment.setSelectedIndex(to, () -> promise.resolve(true));
        reactTabBarFragment.setIntercepted(true);
    }

    private boolean isSameTab(int to, @NonNull ReadableMap extras) {
        if (!extras.hasKey("from")) {
            return false;
        }
        int from = extras.getInt("from");
        return from == to;
    }

    private void popToStackRootIfNeeded(@NonNull ReadableMap extras, TabBarFragment tabBarFragment) {
        boolean popToRoot = extras.hasKey("popToRoot") && extras.getBoolean("popToRoot");
        if (!popToRoot) {
            return;
        }

        StackFragment stackFragment = tabBarFragment.requireSelectedFragment().getStackFragment();
        if (stackFragment != null && stackFragment.getChildAwesomeFragments().size() > 1) {
            stackFragment.popToRootFragment(() -> {
            }, TransitionAnimation.None);
        }
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }

}
