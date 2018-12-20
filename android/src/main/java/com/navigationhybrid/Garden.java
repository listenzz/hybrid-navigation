package com.navigationhybrid;


import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.ColorInt;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.util.ArrayList;

import me.listenzz.navigation.AwesomeToolbar;
import me.listenzz.navigation.BarStyle;
import me.listenzz.navigation.Style;
import me.listenzz.navigation.ToolbarButtonItem;

import static com.navigationhybrid.Constants.ON_BAR_BUTTON_ITEM_CLICK_EVENT;


/**
 * Created by Listen on 2017/11/22.
 */
public class Garden {

    private static final String TAG = "ReactNative";

    private static GlobalStyle globalStyle;

    static void createGlobalStyle(Bundle options) {
        globalStyle = new GlobalStyle(options);
    }

    static GlobalStyle getGlobalStyle() {
        return globalStyle;
    }

    static @NonNull Bundle mergeOptions(@NonNull Bundle options, @Nullable ReadableMap readableMap) {
        if (readableMap == null) {
            return options;
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(options));
        writableMap.merge(readableMap);
        return Arguments.toBundle(writableMap);
    }

    static @NonNull Bundle mergeOptions(@NonNull Bundle options, @Nullable Bundle bundle) {
        if (bundle == null) {
            return options;
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(options));
        writableMap.merge(Arguments.fromBundle(bundle));
        return Arguments.toBundle(writableMap);
    }

    private final HybridFragment fragment;

    private final Style style;

    private Bundle options;

    boolean backButtonHidden;

    boolean backInteractive;

    boolean swipeBackEnabled;

    boolean hidesBottomBarWhenPushed;

    boolean toolbarHidden;

    boolean extendedLayoutIncludesTopBar;

    Garden(@NonNull HybridFragment fragment, Style style) {
        // 构造 garden 实例时，Toolbar 还没有被创建

        this.fragment = fragment;
        this.style = style;

        Bundle options = fragment.getOptions();
        this.options = options;

        this.backButtonHidden = options.getBoolean("backButtonHidden", false);
        this.backInteractive = options.getBoolean("backInteractive", true);
        this.swipeBackEnabled = options.getBoolean("swipeBackEnabled", true);
        this.toolbarHidden = options.getBoolean("topBarHidden", false);
        Bundle tabItem = options.getBundle("tabItem");
        this.hidesBottomBarWhenPushed = tabItem == null || tabItem.getBoolean("hideTabBarWhenPush");
        this.extendedLayoutIncludesTopBar = options.getBoolean("extendedLayoutIncludesTopBar", false);

        String screenColor = options.getString("screenBackgroundColor");
        if (!TextUtils.isEmpty(screenColor)) {
            style.setScreenBackgroundColor(Color.parseColor(screenColor));
        }

        String statusBarColor = options.getString("statusBarColorAndroid");
        if (statusBarColor == null) {
            statusBarColor = options.getString("statusBarColor");
        }
        if (!TextUtils.isEmpty(statusBarColor)) {
            style.setStatusBarColor(Color.parseColor(statusBarColor));
        }

        boolean statusBarHidden = options.getBoolean("statusBarHidden");
        style.setStatusBarHidden(statusBarHidden);

        String navigationBarColor = options.getString("navigationBarColorAndroid");
        if (!TextUtils.isEmpty(navigationBarColor)) {
            style.setNavigationBarColor(Color.parseColor(navigationBarColor));
        }

        applyToolbarOptions(options);
    }

    void configureToolbar() {

        if (fragment.getView() == null || fragment.getContext() == null) {
            return;
        }

        AwesomeToolbar toolbar = fragment.getAwesomeToolbar();
        if (toolbar == null) {
            return;
        }

        Bundle titleItem = options.getBundle("titleItem");
        if (titleItem != null) {
            setTitleItem(titleItem);
        }

        Bundle rightBarButtonItem = options.getBundle("rightBarButtonItem");
        ArrayList<Bundle> rightBarButtonItems = options.getParcelableArrayList("rightBarButtonItems");
        if (rightBarButtonItems != null) {
            setRightBarButtonItems(rightBarButtonItems);
        } else if (rightBarButtonItem != null) {
            setRightBarButtonItem(rightBarButtonItem);
        }
        Bundle leftBarButtonItem = options.getBundle("leftBarButtonItem");
        ArrayList<Bundle> leftBarButtonItems = options.getParcelableArrayList("leftBarButtonItems");
        if (leftBarButtonItems != null) {
            setLeftBarButtonItems(leftBarButtonItems);
        } else if (leftBarButtonItem != null) {
            setLeftBarButtonItem(leftBarButtonItem);
        }
    }

    void setTitleItem(@NonNull Bundle titleItem) {
        String moduleName = titleItem.getString("moduleName");
        if (moduleName == null) {
            String title = titleItem.getString("title");
            fragment.setTitle(title);
        }
    }

    void setLeftBarButtonItems(ArrayList<Bundle> items) {
        fragment.setLeftBarButtonItems(barButtonItemsFromBundle(items));
    }

    void setRightBarButtonItems(ArrayList<Bundle> items) {
        fragment.setRightBarButtonItems(barButtonItemsFromBundle(items));
    }

    private ToolbarButtonItem[] barButtonItemsFromBundle(ArrayList<Bundle> items) {
        ArrayList<ToolbarButtonItem> buttonItems = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            Bundle item = items.get(i);
            buttonItems.add(barButtonItemFromBundle(item));
        }
        return buttonItems.toArray(new ToolbarButtonItem[0]);
    }

    void setLeftBarButtonItem(@NonNull Bundle item) {
        fragment.setLeftBarButtonItem(barButtonItemFromBundle(item));
    }

    void setRightBarButtonItem(@NonNull Bundle item) {
        fragment.setRightBarButtonItem(barButtonItemFromBundle(item));
    }

    private ToolbarButtonItem barButtonItemFromBundle(@NonNull Bundle item) {
        Context context = fragment.getContext();
        if (context == null) return null;
        String title = item.getString("title");
        boolean enabled = item.getBoolean("enabled", true);
        Bundle icon = item.getBundle("icon");
        String uri = null;
        if (icon != null) {
            uri = icon.getString("uri");
        }
        final String action = item.getString("action");
        int tintColor = 0;
        String color = item.getString("tintColor");
        if (color != null) {
            tintColor = Color.parseColor(color);
        }
        boolean renderOriginal = item.getBoolean("renderOriginal", false);
        return new ToolbarButtonItem(uri, 0, renderOriginal, title, tintColor, enabled, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ReactBridgeManager bridgeManager = ReactBridgeManager.get();
                Bundle bundle = new Bundle();
                bundle.putString("action", action);
                bundle.putString("sceneId", fragment.getSceneId());
                bridgeManager.sendEvent(ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
            }
        });
    }

    void setPassThroughTouches(boolean passThroughTouches) {
        View view = fragment.getView();
        if (view instanceof BubbleTouchEventReactRootView) {
            ((BubbleTouchEventReactRootView) view).setShouldConsumeTouchEvent(!passThroughTouches);
        }
    }

    private void applyToolbarOptions(@NonNull Bundle options) {
        String barStyle = options.getString("topBarStyle");
        if (barStyle != null) {
            if (barStyle.equals("dark-content")) {
                style.setStatusBarStyle(BarStyle.DarkContent);
            } else {
                style.setStatusBarStyle(BarStyle.LightContent);
            }
        }

        String topBarTintColor = options.getString("topBarTintColor");
        if (!TextUtils.isEmpty(topBarTintColor)) {
            style.setToolbarTintColor(Color.parseColor(topBarTintColor));
        }

        String titleTextColor = options.getString("titleTextColor");
        if (!TextUtils.isEmpty(titleTextColor)) {
            style.setTitleTextColor(Color.parseColor(titleTextColor));
        }

        double titleTextSize = options.getDouble("titleTextSize", -1);
        if (titleTextSize != -1) {
            style.setTitleTextSize((int)titleTextSize);
        }

        String topBarColor = options.getString("topBarColor");
        if (!TextUtils.isEmpty(topBarColor)) {
            int color = Color.parseColor(topBarColor);
            style.setToolbarBackgroundColor(color);
        }

        double topBarAlpha = options.getDouble("topBarAlpha", -1);
        if (topBarAlpha != -1) {
            style.setToolbarAlpha((float) topBarAlpha);
        }

        boolean topBarShadowHidden = options.getBoolean("topBarShadowHidden", false);
        style.setToolbarShadowHidden(topBarShadowHidden);
    }

    void updateToolbar(@NonNull ReadableMap readableMap) {
        Bundle options = Arguments.toBundle(readableMap);
        applyToolbarOptions(options);
        fragment.setNeedsStatusBarAppearanceUpdate(false);
        fragment.setNeedsToolbarAppearanceUpdate();
        fragment.setOptions(mergeOptions(fragment.getOptions(), readableMap));
    }

    void setStatusBarColor(@ColorInt int color) {
        style.setStatusBarColor(color);
        fragment.setNeedsStatusBarAppearanceUpdate();
    }

    void setStatusBarHidden(boolean hidden) {
        style.setStatusBarHidden(hidden);
        fragment.setNeedsStatusBarAppearanceUpdate();
    }

}
