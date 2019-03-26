package com.navigationhybrid.navigator;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactDrawerFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DrawerFragment;

public class DrawerNavigator implements Navigator {

    private List<String> supportActions = Arrays.asList("toggleMenu", "openMenu", "closeMenu");

    @Override
    @NonNull
    public String name() {
        return "drawer";
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(@NonNull ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableMap drawer = layout.getMap(name());
            if (drawer == null) {
                throw new IllegalArgumentException("drawer should be an object.");
            }
            ReadableArray children = drawer.getArray("children");
            if (children != null && children.size() == 2) {

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
                return drawerFragment;
            } else {
                throw new IllegalArgumentException("the drawer layout should had and only had two children");
            }
        }
        return null;
    }

    @Override
    public boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull  ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment instanceof DrawerFragment && fragment.isAdded()) {
            DrawerFragment drawer = (DrawerFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            getReactBridgeManager().buildRouteGraph(drawer.getContentFragment(), children, modal);
            getReactBridgeManager().buildRouteGraph(drawer.getMenuFragment(), children, modal);
            Bundle graph = new Bundle();
            graph.putString("layout", name());
            graph.putString("sceneId", fragment.getSceneId());
            graph.putParcelableArrayList("children", children);
            graph.putString("mode", Navigator.Util.getMode(fragment));
            root.add(graph);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof DrawerFragment && fragment.isAdded()) {
            DrawerFragment drawer = (DrawerFragment) fragment;
            if (drawer.isMenuOpened()) {
                return getReactBridgeManager().primaryFragment(drawer.getMenuFragment());
            } else {
                return getReactBridgeManager().primaryFragment(drawer.getContentFragment());
            }
        }
        return null;
    }

    @Override
    @NonNull
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action,  @NonNull ReadableMap extras) {
        DrawerFragment drawerFragment = target.getDrawerFragment();
        if (drawerFragment == null) {
            return;
        }
        switch (action) {
            case "toggleMenu":
                drawerFragment.toggleMenu();
                break;
            case "openMenu":
                drawerFragment.openMenu();
                break;
            case "closeMenu":
                drawerFragment.closeMenu();
                break;
        }
    }


    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }
}
