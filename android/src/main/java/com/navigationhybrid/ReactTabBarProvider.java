package com.navigationhybrid;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.content.LocalBroadcastManager;
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
import static com.navigationhybrid.Constants.ACTION_SET_TAB_BADGE;
import static com.navigationhybrid.Constants.ACTION_SET_TAB_ICON;
import static com.navigationhybrid.Constants.ACTION_UPDATE_TAB_BAR;
import static com.navigationhybrid.Constants.ARG_ACTION;
import static com.navigationhybrid.Constants.ARG_OPTIONS;

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
                tab.putString("unselectedIcon", Utils.getIconUri(context, tabBarItem.unselectedIconUri));
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

        jsBundleReloadBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                LocalBroadcastManager.getInstance(context).unregisterReceiver(this);
                jsBundleReloadBroadcastReceiver = null;

                if (reactView != null) {
                    reactView.unmountReactApplication();
                    reactView = null;
                }
            }
        };
        LocalBroadcastManager.getInstance(tabBarFragment.requireContext()).registerReceiver(jsBundleReloadBroadcastReceiver, new IntentFilter(Constants.INTENT_RELOAD_JS_BUNDLE));

        configureTabBar(tabBar, reactTabBarFragment.getStyle());
        this.tabBarFragment = reactTabBarFragment;
        this.tabBar = tabBar;
        return tabBar;
    }

    BroadcastReceiver jsBundleReloadBroadcastReceiver = null;

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
        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");

        if (tabBarItemColor != null) {
            props.putString("itemColor", tabBarItemColor);
            props.putString("unselectedItemColor", tabBarUnselectedItemColor);
        }

        props.putString("badgeColor", options.getString("tabBarBadgeColor"));
        return props;
    }

    @Override
    public void onDestroyTabBar() {
        if (jsBundleReloadBroadcastReceiver != null) {
            LocalBroadcastManager.getInstance(tabBarFragment.requireContext()).unregisterReceiver(jsBundleReloadBroadcastReceiver);
            jsBundleReloadBroadcastReceiver = null;
        }
        if (reactView != null) {
            reactView.unmountReactApplication();
            reactView = null;
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
            case ACTION_SET_TAB_BADGE:
                setTabBadge(options.getParcelableArrayList(ARG_OPTIONS));
                break;
            case ACTION_SET_TAB_ICON:
                setTabIcon(options.getParcelableArrayList(ARG_OPTIONS));
                break;
            case ACTION_UPDATE_TAB_BAR:
                updateTabBarAppearance(options.getBundle(ARG_OPTIONS));
                break;
        }
    }


    private void setTabBadge(@Nullable ArrayList<Bundle> options) {
        if (options == null) {
            return;
        }

        Bundle tabBar = tabBarFragment.getOptions();
        ArrayList<Bundle> tabs = tabBar.getParcelableArrayList("tabs");

        if (tabs == null) {
            return;
        }

        for (Bundle option : options) {
            int index = (int) option.getDouble("index");
            boolean hidden = option.getBoolean("hidden", true);

            String text = !hidden ? option.getString("text", null) : null;
            boolean dot = !hidden && option.getBoolean("dot", false);

            Bundle tab = tabs.get(index);
            tab.putString("badgeText", text);
            tab.putBoolean("dot", dot);
        }

        reactView.setAppProperties(getProps(tabBarFragment));
    }

    private void setTabIcon(@Nullable ArrayList<Bundle> options) {
        if (options == null) {
            return;
        }

        Bundle tabBar = tabBarFragment.getOptions();
        ArrayList<Bundle> tabs = tabBar.getParcelableArrayList("tabs");

        if (tabs == null) {
            return;
        }

        for (Bundle option : options) {
            int index = (int) option.getDouble("index");
            Bundle icon = option.getBundle("icon");
            Bundle unselectedIcon = option.getBundle("unselectedIcon");
            Context context = tabBarFragment.requireContext();
            Bundle tab = tabs.get(index);
            if (icon != null) {
                String uri = Utils.getIconUri(context, icon.getString("uri"));
                tab.putString("icon", uri);
                tab.putString("unselectedIcon", null);
            }

            if (unselectedIcon != null) {
                String uri = Utils.getIconUri(context, unselectedIcon.getString("uri"));
                tab.putString("unselectedIcon", uri);
            }
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
        if (tabBarItemColor != null) {
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
