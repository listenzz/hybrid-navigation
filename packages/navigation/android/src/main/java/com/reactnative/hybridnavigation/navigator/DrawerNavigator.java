package com.reactnative.hybridnavigation.navigator;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.reactnative.hybridnavigation.HybridFragment;
import com.reactnative.hybridnavigation.Navigator;
import com.reactnative.hybridnavigation.ReactBridgeManager;
import com.reactnative.hybridnavigation.ReactDrawerFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class DrawerNavigator implements Navigator {

    private final List<String> supportActions = Arrays.asList("toggleMenu", "openMenu", "closeMenu");

    @Override
    @NonNull
    public String name() {
        return "drawer";
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(@NonNull ReadableMap layout) {
        if (!layout.hasKey(name())) {
            return null;
        }

        ReadableMap drawer = layout.getMap(name());
        if (drawer == null) {
            throw new IllegalArgumentException("drawer should be an object.");
        }

        ReadableArray children = drawer.getArray("children");
        boolean match = children != null && children.size() == 2;
        if (!match) {
            throw new IllegalArgumentException("the drawer layout should had and only had two children");
        }

        ReadableMap content = children.getMap(0);
        ReadableMap menu = children.getMap(1);

        AwesomeFragment contentFragment = getReactBridgeManager().createFragment(content);
        if (contentFragment == null) {
            throw new IllegalArgumentException("can't create drawer content component with " + content);
        }
        AwesomeFragment menuFragment = getReactBridgeManager().createFragment(menu);
        if (menuFragment == null) {
            throw new IllegalArgumentException("can't create drawer menu component with " + menu);
        }

        ReactDrawerFragment drawerFragment = new ReactDrawerFragment();
        drawerFragment.setMenuFragment(menuFragment);
        drawerFragment.setContentFragment(contentFragment);

        if (drawer.hasKey("options")) {
            setDrawerOptions(drawer, drawerFragment);
        }

        return drawerFragment;
    }

    private void setDrawerOptions(ReadableMap drawer, ReactDrawerFragment drawerFragment) {
        ReadableMap options = drawer.getMap("options");
        if (options == null) {
            throw new IllegalArgumentException("options should be an object");
        }

        if (options.hasKey("maxDrawerWidth")) {
            int maxDrawerWidth = options.getInt("maxDrawerWidth");
            drawerFragment.setMaxDrawerWidth(maxDrawerWidth);
        }

        if (options.hasKey("minDrawerMargin")) {
            int minDrawerMargin = options.getInt("minDrawerMargin");
            drawerFragment.setMinDrawerMargin(minDrawerMargin);
        }

        if (options.hasKey("menuInteractive")) {
            boolean interactive = options.getBoolean("menuInteractive");
            drawerFragment.setMenuInteractive(interactive);
        }
    }

    @Nullable
    @Override
    public Bundle buildRouteGraph(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof DrawerFragment) || !fragment.isAdded()) {
            return null;
        }

        DrawerFragment drawer = (DrawerFragment) fragment;
        ArrayList<Bundle> children = buildChildrenGraph(drawer);
        Bundle graph = new Bundle();
        graph.putString("layout", name());
        graph.putString("sceneId", fragment.getSceneId());
        graph.putParcelableArrayList("children", children);
        graph.putString("mode", Navigator.Util.getMode(fragment));
        return graph;
    }

    @NonNull
    private ArrayList<Bundle> buildChildrenGraph(DrawerFragment drawer) {
        ArrayList<Bundle> children = new ArrayList<>();
        List<AwesomeFragment> fragments = drawer.getChildAwesomeFragments();
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
        if (!(fragment instanceof DrawerFragment) || !fragment.isAdded()) {
            return null;
        }

        DrawerFragment drawer = (DrawerFragment) fragment;
        if (drawer.isMenuPrimary()) {
            return getReactBridgeManager().primaryFragment(drawer.getMenuFragment());
        }
        return getReactBridgeManager().primaryFragment(drawer.getContentFragment());
    }

    @Override
    @NonNull
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Callback callback) {
        DrawerFragment drawerFragment = target.getDrawerFragment();
        if (drawerFragment == null) {
            callback.invoke(null, false);
            return;
        }

        switch (action) {
            case "toggleMenu":
                drawerFragment.toggleMenu(() -> callback.invoke(null, true));
                break;
            case "openMenu":
                drawerFragment.openMenu(() -> callback.invoke(null, true));
                break;
            case "closeMenu":
                drawerFragment.closeMenu(() -> callback.invoke(null, true));
                break;
        }
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }
}
