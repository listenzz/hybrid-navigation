package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_ITEM;
import static com.reactnative.hybridnavigation.Constants.ACTION_UPDATE_TAB_BAR;
import static com.reactnative.hybridnavigation.Constants.ARG_ACTION;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.Parameters.mergeOptions;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.navigation.androidx.Style;
import com.navigation.androidx.TabBar;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TabBarItem;

import java.util.ArrayList;
import java.util.List;

public class ReactTabBarProvider extends com.navigation.androidx.DefaultTabBarProvider {

    private ReactTabBarFragment tabBarFragment;

    @Override
    public View onCreateTabBar(@NonNull List<TabBarItem> tabBarItems, @NonNull TabBarFragment tabBarFragment, @Nullable Bundle savedInstanceState) {
        this.tabBarFragment = (ReactTabBarFragment) tabBarFragment;
        return super.onCreateTabBar(tabBarItems, tabBarFragment, savedInstanceState);
    }

    @Override
    public void updateTabBar(@NonNull Bundle options) {
        String action = options.getString(ARG_ACTION);
        if (action == null) {
            return;
        }

        switch (action) {
            case ACTION_SET_TAB_ITEM:
                setTabItem(options.getParcelableArrayList(ARG_OPTIONS));
                break;
            case ACTION_UPDATE_TAB_BAR:
                updateTabBarStyle(options.getBundle(ARG_OPTIONS));
                break;
        }
    }

    private void setTabItem(@Nullable ArrayList<Bundle> options) {
        if (options == null) {
            return;
        }

        TabBar tabBar = tabBarFragment.getTabBar();

        for (Bundle option : options) {
            int index = (int) option.getDouble("index");
            TabBarItem tabBarItem = tabBar.getTabBarItem(index);
            if (tabBarItem == null) {
                continue;
            }

            setTabItemTitle(option, tabBarItem);
            setTabItemIcon(option, tabBarItem);
            setTabItemBadge(option, tabBarItem);
            tabBar.renderTabView(index);
        }
    }

    private void setTabItemBadge(Bundle option, TabBarItem tabBarItem) {
        Bundle badge = option.getBundle("badge");
        if (badge == null) {
            return;
        }

        boolean hidden = badge.getBoolean("hidden", true);
        String text = !hidden ? badge.getString("text", "") : "";
        boolean dot = !hidden && badge.getBoolean("dot", false);

        tabBarItem.badgeText = text;
        tabBarItem.showDotBadge = dot;
    }

    private void setTabItemIcon(Bundle option, TabBarItem tabBarItem) {
        Bundle icon = option.getBundle("icon");
        if (icon == null) {
            return;
        }

        Bundle selected = icon.getBundle("selected");
        tabBarItem.iconUri = selected.getString("uri");

        Bundle unselected = icon.getBundle("unselected");
        if (unselected != null) {
            tabBarItem.unselectedIconUri = unselected.getString("uri");
        }
    }

    private void setTabItemTitle(Bundle option, TabBarItem tabBarItem) {
        String title = option.getString("title");
        if (title != null) {
            tabBarItem.title = title;
        }
    }

    private void updateTabBarStyle(@Nullable Bundle options) {
        if (options == null) {
            return;
        }

        tabBarFragment.setOptions(mergeOptions(tabBarFragment.getOptions(), options));
        TabBar tabBar = tabBarFragment.getTabBar();

        String tabBarBackgroundColor = options.getString("tabBarBackgroundColor");
        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        String tabBarItemSelectedColor = options.getString("tabBarItemSelectedColor");
        String tabBarItemNormalColor = options.getString("tabBarItemNormalColor");

        if (tabBarBackgroundColor != null) {
            tabBar.setBarBackgroundColor(tabBarBackgroundColor);

            Style style = tabBarFragment.getStyle();
            style.setTabBarBackgroundColor(tabBarBackgroundColor);
            tabBarFragment.setNeedsNavigationBarAppearanceUpdate();
        }

        if (shadowImage != null) {
            tabBar.setShadowDrawable(Utils.createTabBarShadow(tabBarFragment.requireContext(), shadowImage));
        }

        if (tabBarItemSelectedColor != null) {
            tabBar.setSelectedItemColor(tabBarItemSelectedColor);
        }

        if (tabBarItemNormalColor != null) {
            tabBar.setUnselectedItemColor(tabBarItemNormalColor);
        }

        tabBar.initialise(tabBar.getCurrentSelectedPosition());
    }

}
