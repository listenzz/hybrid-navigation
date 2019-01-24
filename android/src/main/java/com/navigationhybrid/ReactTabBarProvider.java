package com.navigationhybrid;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Pair;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import com.facebook.react.ReactInstanceManager;

import java.util.ArrayList;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.Style;
import me.listenzz.navigation.TabBarFragment;
import me.listenzz.navigation.TabBarItem;
import me.listenzz.navigation.TabBarProvider;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;
import static com.navigationhybrid.Constants.ACTION_SET_BADGE_TEXT;
import static com.navigationhybrid.Constants.ACTION_SET_RED_POINT;
import static com.navigationhybrid.Constants.ACTION_SET_TAB_ICON;
import static com.navigationhybrid.Constants.ACTION_UPDATE_TAB_BAR;
import static com.navigationhybrid.Constants.ARG_ACTION;
import static com.navigationhybrid.Constants.ARG_BADGE_TEXT;
import static com.navigationhybrid.Constants.ARG_ICON;
import static com.navigationhybrid.Constants.ARG_ICON_SELECTED;
import static com.navigationhybrid.Constants.ARG_INDEX;
import static com.navigationhybrid.Constants.ARG_OPTIONS;
import static com.navigationhybrid.Constants.ARG_VISIBLE;

public class ReactTabBarProvider implements TabBarProvider {

    private static final String TAG = "ReactNative";

    private ReactView reactView;
    private ReactTabBarFragment tabBarFragment;
    private ReactTabBar tabBar;

    @Override
    public View onCreateTabBar(@NonNull List<TabBarItem> tabBarItems, @NonNull TabBarFragment tabBarFragment, @Nullable Bundle savedInstanceState) {
        if (!(tabBarFragment instanceof ReactTabBarFragment)) {
            throw new IllegalStateException("必须和 ReactTabBarFragment 一起使用");
        }

        ReactTabBarFragment reactTabBarFragment = (ReactTabBarFragment) tabBarFragment;
        Bundle options = reactTabBarFragment.getOptions();
        Context context = reactTabBarFragment.requireContext();
        List<AwesomeFragment> children = tabBarFragment.getChildFragments();

        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        if (tabs == null) {
            tabs = new ArrayList<>();
            for (int i = 0, size = tabBarItems.size(); i < size; i++) {
                TabBarItem tabBarItem = tabBarItems.get(i);
                Bundle tab = new Bundle();
                tab.putInt("index", i);
                tab.putString("icon", Utils.getIconUri(context, tabBarItem.iconUri));
                tab.putString("selectedIcon", Utils.getIconUri(context, tabBarItem.selectedIconUri));
                tab.putString("title", tabBarItem.title);
                Pair<String, String> pair = extractSceneIdAndModuleName(children.get(i));
                tab.putString("sceneId", pair.first);
                tab.putString("moduleName", pair.second);
                tabs.add(i, tab);
            }
            options.putParcelableArrayList("tabs", tabs);
        }

        String tabBarModuleName = options.getString("tabBarModuleName");

        if (tabBarModuleName == null) {
            throw new IllegalStateException("tabBarModuleName 不能为 null");
        }

        reactView = new ReactView(tabBarFragment.requireContext());
        boolean sizeIndeterminate = options.getBoolean("sizeIndeterminate");
        if (sizeIndeterminate) {
            reactView.setLayoutParams(new FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT, Gravity.BOTTOM));
            reactView.setShouldConsumeTouchEvent(false);
        } else {
            reactView.setLayoutParams(new FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT, Gravity.BOTTOM));
        }

        ReactTabBar tabBar = new ReactTabBar(tabBarFragment.requireContext(), sizeIndeterminate);
        tabBar.setRootView(reactView);

        Bundle props = getProps(reactTabBarFragment);
        props.putInt("selectedIndex", options.getInt("selectedIndex"));
        ReactInstanceManager reactInstanceManager = getReactBridgeManager().getReactInstanceManager();
        reactView.startReactApplication(reactInstanceManager, tabBarModuleName, props);
        configureTabBar(tabBar, reactTabBarFragment.getStyle());
        this.tabBarFragment = reactTabBarFragment;
        this.tabBar = tabBar;
        return tabBar;
    }

    private Pair<String, String> extractSceneIdAndModuleName(AwesomeFragment awesomeFragment) {
        if (awesomeFragment instanceof NavigationFragment) {
            NavigationFragment navigationFragment = (NavigationFragment) awesomeFragment;
            awesomeFragment = navigationFragment.getRootFragment();
        }
        if (awesomeFragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) awesomeFragment;
            return new Pair<>(hybridFragment.getSceneId(), hybridFragment.getModuleName());
        }
        return null;
    }

    private void configureTabBar(ReactTabBar tabBar, Style style) {
        tabBar.setTabBarBackground(new ColorDrawable(Color.parseColor(style.getTabBarBackgroundColor())));
        tabBar.setShadow(style.getTabBarShadow());
    }

    @NonNull
    private Bundle getProps(@NonNull ReactTabBarFragment tabBarFragment) {

        Bundle options = tabBarFragment.getOptions();
        Bundle props = new Bundle();
        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        props.putParcelableArrayList("tabs", tabs);
        props.putString("sceneId", tabBarFragment.getSceneId());
        props.putInt("selectedIndex", tabBarFragment.getSelectedIndex());

        String tabBarItemColor = options.getString("tabBarItemColor");
        String tabBarSelectedItemColor = options.getString("tabBarSelectedItemColor");
        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");

        if (tabBarItemColor != null) {
            props.putString("itemColor", tabBarItemColor);
            if (tabBarSelectedItemColor != null) {
                props.putString("selectedItemColor", tabBarSelectedItemColor);
            }
            if (tabBarUnselectedItemColor != null) {
                props.putString("itemColor", tabBarUnselectedItemColor);
                props.putString("selectedItemColor", tabBarItemColor);
            }
        }

        props.putString("badgeColor", options.getString("badgeColor"));
        return props;
    }

    @Override
    public void onDestroyTabBar() {
        if (reactView != null) {
            reactView.unmountReactApplication();
        }
        tabBarFragment = null;
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {

    }

    @Override
    public void setSelectedIndex(int index) {
        if (tabBarFragment != null) {
            Bundle bundle = getProps(tabBarFragment);
            bundle.putInt("selectedIndex", index);
            reactView.setAppProperties(bundle);
        }
    }

    @Override
    public void updateTabBar(@NonNull Bundle options) {
        String action = options.getString(ARG_ACTION);
        if (action == null) {
            return;
        }

        switch (action) {
            case ACTION_SET_BADGE_TEXT:
                setBadge(options.getInt(ARG_INDEX), options.getString(ARG_BADGE_TEXT));
                break;
            case ACTION_SET_RED_POINT:
                setRedPoint(options.getInt(ARG_INDEX), options.getBoolean(ARG_VISIBLE));
                break;
            case ACTION_SET_TAB_ICON:
                setTabIcon(options.getInt(ARG_INDEX), options.getBundle(ARG_ICON), options.getBundle(ARG_ICON_SELECTED));
                break;
            case ACTION_UPDATE_TAB_BAR:
                updateTabBarAppearance(options.getBundle(ARG_OPTIONS));
                break;
        }
    }

    private void setBadge(int index, String text) {
        Bundle options = tabBarFragment.getOptions();
        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        if (tabs == null) {
            // should never happen
            throw new IllegalStateException("现在还不能执行设置 badge 的操作");
        }
        Bundle tab = tabs.get(index);
        tab.putString("badgeText", text);
        reactView.setAppProperties(getProps(tabBarFragment));
    }

    private void setRedPoint(int index, boolean visible) {
        Bundle options = tabBarFragment.getOptions();
        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        if (tabs == null) {
            // should never happen
            throw new IllegalStateException("现在还不能执行设置 badge 的操作");
        }
        Bundle tab = tabs.get(index);
        tab.putBoolean("remind", visible);
        reactView.setAppProperties(getProps(tabBarFragment));
    }

    private void setTabIcon(int index, @Nullable Bundle icon, @Nullable Bundle selectedIcon) {
        if (icon == null) {
            return;
        }

        Bundle options = tabBarFragment.getOptions();
        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        if (tabs == null) {
            // should never happen
            throw new IllegalStateException("现在还不能执行设置 badge 的操作");
        }
        Bundle tab = tabs.get(index);

        Context context = tabBarFragment.requireContext();
        String iconUri = Utils.getIconUri(context, icon.getString("uri"));
        tab.putString("icon", iconUri);

        if (selectedIcon != null) {
            String selectedIconUri = Utils.getIconUri(context, selectedIcon.getString("uri"));
            tab.putString("selectedIcon", selectedIconUri);
        }
        reactView.setAppProperties(getProps(tabBarFragment));
    }

    private void updateTabBarAppearance(@Nullable Bundle bundle) {
        if (bundle == null) {
            return;
        }

        Style style = tabBarFragment.getStyle();
        Bundle options = tabBarFragment.getOptions();
        ReactTabBar tabBar = this.tabBar;

        String tabBarColor = bundle.getString("tabBarColor");
        if (tabBarColor != null) {
            options.putString("tabBarColor", tabBarColor);
            style.setTabBarBackgroundColor(tabBarColor);
            tabBar.setTabBarBackground(new ColorDrawable(Color.parseColor(tabBarColor)));
            tabBarFragment.setNeedsNavigationBarAppearanceUpdate();
        }

        Bundle shadowImage = bundle.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            options.putBundle("tabBarShadowImage", shadowImage);
            tabBar.setShadow(Utils.createTabBarShadow(tabBarFragment.requireContext(), shadowImage));
        }

        String tabBarItemColor = bundle.getString("tabBarItemColor");
        String tabBarUnselectedItemColor = bundle.getString("tabBarUnselectedItemColor");
        if (tabBarItemColor != null && tabBarUnselectedItemColor != null) {
            options.putString("tabBarItemColor", tabBarItemColor);
            options.putString("tabBarUnselectedItemColor", tabBarUnselectedItemColor);
            Bundle props = getProps(tabBarFragment);
            reactView.setAppProperties(props);
        }
    }

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }
}
