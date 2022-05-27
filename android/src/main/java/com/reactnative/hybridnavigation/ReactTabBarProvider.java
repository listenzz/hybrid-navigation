package com.reactnative.hybridnavigation;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;
import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_ITEM;
import static com.reactnative.hybridnavigation.Constants.ACTION_UPDATE_TAB_BAR;
import static com.reactnative.hybridnavigation.Constants.ARG_ACTION;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Pair;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.StackFragment;
import com.navigation.androidx.Style;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TabBarItem;
import com.navigation.androidx.TabBarProvider;

import java.util.ArrayList;
import java.util.List;

public class ReactTabBarProvider implements TabBarProvider, ReactBridgeManager.ReactBridgeReloadListener {

    private static final String TAG = "Navigator";

    private HBDReactRootView reactRootView;
    private ReactTabBarFragment tabBarFragment;
    private ReactTabBar tabBar;

    @Override
    public View onCreateTabBar(@NonNull List<TabBarItem> tabBarItems, @NonNull TabBarFragment tabBarFragment, @Nullable Bundle savedInstanceState) {
        if (!(tabBarFragment instanceof ReactTabBarFragment)) {
            throw new IllegalStateException("必须和 ReactTabBarFragment 一起使用");
        }
        this.tabBarFragment = (ReactTabBarFragment) tabBarFragment;

        Bundle options = this.tabBarFragment.getOptions();
        String tabBarModuleName = options.getString("tabBarModuleName");
        if (tabBarModuleName == null) {
            throw new IllegalStateException("tabBarModuleName 不能为 null");
        }

        HBDReactRootView reactRootView = createReactRootView();
        this.reactRootView = reactRootView;
        startReactApplication(tabBarItems, tabBarModuleName, reactRootView);

        this.tabBar = createReactTabBar(reactRootView, options);
        return tabBar;
    }

    @NonNull
    private ReactTabBar createReactTabBar(HBDReactRootView reactRootView, Bundle options) {
        boolean sizeIndeterminate = options.getBoolean("sizeIndeterminate");
        ReactTabBar tabBar = new ReactTabBar(tabBarFragment.requireContext(), sizeIndeterminate);
        Style style = tabBarFragment.getStyle();
        tabBar.setTabBarBackground(new ColorDrawable(Color.parseColor(style.getTabBarBackgroundColor())));
        tabBar.setShadow(style.getTabBarShadow());
        tabBar.setRootView(reactRootView);
        return tabBar;
    }

    private void startReactApplication(@NonNull List<TabBarItem> tabBarItems, String tabBarModuleName, HBDReactRootView reactRootView) {
        Bundle options = tabBarFragment.getOptions();
        inflateTabsIfNeeded(tabBarItems, options);
        
        Bundle props = createProps(options);
        props.putInt("selectedIndex", options.getInt("selectedIndex"));

        ReactBridgeManager bridgeManager = getReactBridgeManager();
        bridgeManager.addReactBridgeReloadListener(this);
        ReactInstanceManager reactInstanceManager = bridgeManager.getReactInstanceManager();

        reactRootView.startReactApplication(reactInstanceManager, tabBarModuleName, props);
    }
    
    @NonNull
    private HBDReactRootView createReactRootView() {
        HBDReactRootView reactRootView = new HBDReactRootView(tabBarFragment.requireContext());
        Bundle options = tabBarFragment.getOptions();
        boolean sizeIndeterminate = options.getBoolean("sizeIndeterminate");
        if (sizeIndeterminate) {
            reactRootView.setLayoutParams(new FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT, Gravity.BOTTOM));
            reactRootView.setShouldConsumeTouchEvent(false);
        } else {
            reactRootView.setLayoutParams(new FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT, Gravity.BOTTOM));
        }

        return reactRootView;
    }
    
    private void inflateTabsIfNeeded(@NonNull List<TabBarItem> tabBarItems, Bundle options) {
        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        if (tabs != null) {
            return;
        }
        options.putParcelableArrayList("tabs", createTabs(tabBarItems));
    }

    @NonNull
    private ArrayList<Bundle> createTabs(@NonNull List<TabBarItem> tabBarItems) {
        ArrayList<Bundle> tabs = new ArrayList<>();
        Context context = tabBarFragment.requireContext();
        List<AwesomeFragment> children = tabBarFragment.getChildFragments();
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
        return tabs;
    }

    private Pair<String, String> extractSceneIdAndModuleName(AwesomeFragment fragment) {
        if (fragment instanceof StackFragment) {
            StackFragment stackFragment = (StackFragment) fragment;
            fragment = stackFragment.getRootFragment();
        }
        if (fragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) fragment;
            return new Pair<>(hybridFragment.getSceneId(), hybridFragment.getModuleName());
        }
        return null;
    }

    private void unmountReactView() {
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        bridgeManager.removeReactBridgeReloadListener(this);
        ReactContext reactContext = bridgeManager.getCurrentReactContext();
        
        if (reactContext == null || !reactContext.hasActiveCatalystInstance()) {
            return;
        }
        if (reactRootView != null) {
            reactRootView.unmountReactApplication();
            reactRootView = null;
        }
    }
    
    @NonNull
    private Bundle createProps(Bundle options) {
        Bundle props = new Bundle();
        
        props.putParcelableArrayList("tabs", options.getParcelableArrayList("tabs"));
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
        unmountReactView();
        tabBarFragment = null;
    }

    @Override
    public void onReload() {
        unmountReactView();
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {

    }

    @Override
    public void setSelectedIndex(int index) {
        if (tabBarFragment != null) {
            Bundle props = createProps(tabBarFragment.getOptions());
            props.putInt("selectedIndex", index);
            reactRootView.setAppProperties(props);
        }
    }

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
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

    private void setTabItem(@Nullable ArrayList<Bundle> tabItems) {
        if (tabItems == null) {
            return;
        }
        Bundle options = tabBarFragment.getOptions();
        ArrayList<Bundle> tabs = options.getParcelableArrayList("tabs");
        if (tabs == null) {
            return;
        }

        for (Bundle tabItem : tabItems) {
            int index = (int) tabItem.getDouble("index");
            Bundle tab = tabs.get(index);
            buildTabTitle(tabItem, tab);
            buildTabIcon(tabItem, tab);
            buildTabBadge(tabItem, tab);
        }
        reactRootView.setAppProperties(createProps(options));
    }

    private void buildTabBadge(Bundle tabItem, Bundle tab) {
        Bundle badge = tabItem.getBundle("badge");
        if (badge == null) {
            return;
        }
        boolean hidden = badge.getBoolean("hidden", true);
        String text = !hidden ? badge.getString("text", "") : "";
        boolean dot = !hidden && badge.getBoolean("dot", false);

        tab.putString("badgeText", text);
        tab.putBoolean("dot", dot);
    }

    private void buildTabIcon(Bundle tabItem, Bundle tab) {
        Bundle icon = tabItem.getBundle("icon");
        if (icon == null) {
            return;
        }
        Bundle unselected = icon.getBundle("unselected");
        Bundle selected = icon.getBundle("selected");
        if (unselected != null) {
            tab.putString("unselectedIcon", unselected.getString("uri"));
        }
        tab.putString("icon", selected.getString("uri"));
    }

    private void buildTabTitle(Bundle titleItem, Bundle tab) {
        String title = titleItem.getString("title");
        if (title != null) {
            tab.putString("title", title);
        }
    }

    private void updateTabBarStyle(@Nullable Bundle bundle) {
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
            Bundle props = createProps(options);
            reactRootView.setAppProperties(props);
        }
    }

}
