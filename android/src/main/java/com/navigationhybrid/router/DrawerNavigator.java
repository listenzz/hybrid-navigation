package com.navigationhybrid.router;

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
    public String name() {
        return "drawer";
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableArray drawer = layout.getArray(name());
            if (drawer.size() == 2) {
                ReadableMap content = drawer.getMap(0);
                ReadableMap menu = drawer.getMap(1);

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
                if (layout.hasKey("options")) {
                    ReadableMap options = layout.getMap("options");
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
    public boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> graph) {
        if (fragment instanceof DrawerFragment) {
            DrawerFragment drawer = (DrawerFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            getReactBridgeManager().buildRouteGraph(drawer.getContentFragment(), children);
            getReactBridgeManager().buildRouteGraph(drawer.getMenuFragment(), children);
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
        if (fragment instanceof DrawerFragment) {
            DrawerFragment drawer = (DrawerFragment) fragment;
            if (drawer.isMenuOpened()) {
                return getReactBridgeManager().primaryChildFragment(drawer.getMenuFragment());
            } else {
                return getReactBridgeManager().primaryChildFragment(drawer.getContentFragment());
            }
        }
        return null;
    }

    @Override
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull Bundle extras) {
        DrawerFragment drawerFragment = fragment.getDrawerFragment();
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
        return ReactBridgeManager.instance;
    }
}
