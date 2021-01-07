package com.navigationhybrid.navigator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class NavigatorRegistry {

    private final List<Navigator> navigators = new ArrayList<>();
    private final List<String> layouts = new ArrayList<>();
    private final HashMap<String, Navigator> actionNavigatorPairs = new HashMap<>();
    private final HashMap<String, Navigator> layoutNavigatorPairs = new HashMap<>();

    public NavigatorRegistry() {
        register(new ScreenNavigator());
        register(new StackNavigator());
        register(new TabNavigator());
        register(new DrawerNavigator());
    }

    public void register(@NonNull Navigator navigator) {
        navigators.add(0, navigator);
        layouts.add(navigator.name());

        for (String action : navigator.supportActions()) {
            if (actionNavigatorPairs.containsKey(action)) {
                Navigator duplicated = actionNavigatorPairs.get(action);
                throw new IllegalArgumentException(navigator.getClass().getName() + " 想要注册的 action " + action + " 已经被 " + duplicated.getClass().getName() + " 所注册。");
            }
            actionNavigatorPairs.put(action, navigator);
        }

        String layout = navigator.name();
        if (layoutNavigatorPairs.containsKey(layout)) {
            Navigator duplicated = layoutNavigatorPairs.get(layout);
            throw new IllegalArgumentException("Duplicated layout " + layout + ", which has registered through " + duplicated.getClass().getName());
        }
        layoutNavigatorPairs.put(layout, navigator);
    }

    @Nullable
    public Navigator navigatorForAction(@NonNull String action) {
        return actionNavigatorPairs.get(action);
    }

    @Nullable
    public Navigator navigatorForLayout(@NonNull String layout) {
        return layoutNavigatorPairs.get(layout);
    }

    public List<Navigator> allNavigators() {
        return navigators;
    }

    public List<String> allLayouts() {
        return layouts;
    }
}
