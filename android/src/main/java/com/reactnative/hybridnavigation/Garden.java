package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.HBDEventEmitter.EVENT_NAVIGATION;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_ACTION;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_ON;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_SCENE_ID;
import static com.reactnative.hybridnavigation.HBDEventEmitter.ON_BAR_BUTTON_ITEM_CLICK;
import static com.reactnative.hybridnavigation.Parameters.mergeOptions;
import static com.reactnative.hybridnavigation.Parameters.toBundle;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeToolbar;
import com.navigation.androidx.BarStyle;
import com.navigation.androidx.Style;
import com.navigation.androidx.ToolbarButtonItem;

import java.util.ArrayList;

public class Garden {

    private static final String TAG = "Navigator";

    private static GlobalStyle globalStyle;

    static void createGlobalStyle(Bundle options) {
        globalStyle = new GlobalStyle(options);
    }

    static GlobalStyle getGlobalStyle() {
        return globalStyle;
    }

    private final HybridFragment fragment;

    private final Style style;

    private final Bundle options;

    boolean backButtonHidden = false;

    boolean backInteractive = true;

    boolean swipeBackEnabled;

    boolean hidesBottomBarWhenPushed;

    boolean toolbarHidden;

    boolean extendedLayoutIncludesTopBar;

    boolean forceTransparentDialogWindow;

    Garden(@NonNull HybridFragment fragment, Style style) {
        // 构造 garden 实例时，Toolbar 还没有被创建

        this.fragment = fragment;
        this.style = style;

        Bundle options = fragment.getOptions();
        this.options = options;

        this.swipeBackEnabled = options.getBoolean("swipeBackEnabled", true);
        this.toolbarHidden = options.getBoolean("topBarHidden", false);
        Bundle tabItem = options.getBundle("tabItem");
        this.hidesBottomBarWhenPushed = tabItem == null || tabItem.getBoolean("hideTabBarWhenPush", true);
        this.extendedLayoutIncludesTopBar = options.getBoolean("extendedLayoutIncludesTopBar", false);

        String screenColor = options.getString("screenBackgroundColor");
        if (!TextUtils.isEmpty(screenColor)) {
            style.setScreenBackgroundColor(Color.parseColor(screenColor));
        }

        this.forceTransparentDialogWindow = options.getBoolean("forceTransparentDialogWindow");

        applyOptions(options);
    }

    void setupToolbar() {
        AwesomeToolbar toolbar = fragment.getToolbar();
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
        if (items == null) {
            fragment.setLeftBarButtonItems(null);
        } else {
            fragment.setLeftBarButtonItems(barButtonItemsFromBundle(items));
        }
    }

    void setRightBarButtonItems(ArrayList<Bundle> items) {
        if (items == null) {
            fragment.setRightBarButtonItems(null);
        } else {
            fragment.setRightBarButtonItems(barButtonItemsFromBundle(items));
        }
    }

    private ToolbarButtonItem[] barButtonItemsFromBundle(ArrayList<Bundle> items) {
        ArrayList<ToolbarButtonItem> buttonItems = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            Bundle item = items.get(i);
            buttonItems.add(barButtonItemFromBundle(item));
        }
        return buttonItems.toArray(new ToolbarButtonItem[0]);
    }

    void setLeftBarButtonItem(@Nullable Bundle item) {
        if (item == null) {
            fragment.setLeftBarButtonItem(null);
        } else {
            fragment.setLeftBarButtonItem(barButtonItemFromBundle(item));
        }
    }

    void setRightBarButtonItem(@Nullable Bundle item) {
        if (item == null) {
            fragment.setRightBarButtonItem(null);
        } else {
            fragment.setRightBarButtonItem(barButtonItemFromBundle(item));
        }
    }

    private ToolbarButtonItem barButtonItemFromBundle(@NonNull Bundle item) {
        Context context = fragment.getContext();
        if (context == null) return null;
        String title = item.getString("title");
        boolean enabled = item.getBoolean("enabled", true);
        String uri = uri(item);
        String action = item.getString("action");
        int tintColor = tintColor(item);
        boolean renderOriginal = item.getBoolean("renderOriginal", false);
        return new ToolbarButtonItem(uri, 0, renderOriginal, title, tintColor, enabled, view -> {
            Bundle bundle = new Bundle();
            bundle.putString(KEY_ACTION, action);
            bundle.putString(KEY_SCENE_ID, fragment.getSceneId());
            bundle.putString(KEY_ON, ON_BAR_BUTTON_ITEM_CLICK);
            HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(bundle));
        });
    }

    private int tintColor(@NonNull Bundle item) {
        String tintColor = item.getString("tintColor");
        if (tintColor != null) {
            return Color.parseColor(tintColor);
        }
        return 0;
    }

    @Nullable
    private String uri(@NonNull Bundle item) {
        Bundle icon = item.getBundle("icon");
        if (icon != null) {
            return icon.getString("uri");
        }
        return null;
    }

    private void applyOptions(@NonNull Bundle options) {
        String barStyle = options.getString("topBarStyle");
        if (barStyle != null) {
            if (barStyle.equals("dark-content")) {
                style.setStatusBarStyle(BarStyle.DarkContent);
            } else {
                style.setStatusBarStyle(BarStyle.LightContent);
            }
        }

        String statusBarColor = options.getString("statusBarColorAndroid");
        if (!TextUtils.isEmpty(statusBarColor)) {
            style.setStatusBarColor(Color.parseColor(statusBarColor));
        }

        String navigationBarColor = options.getString("navigationBarColorAndroid");
        if (!TextUtils.isEmpty(navigationBarColor)) {
            style.setNavigationBarColor(Color.parseColor(navigationBarColor));
        }

        if (options.get("navigationBarHiddenAndroid") != null) {
            style.setNavigationBarHidden(options.getBoolean("navigationBarHiddenAndroid"));
        }

        if (options.get("displayCutoutWhenLandscapeAndroid") != null) {
            style.setDisplayCutoutWhenLandscape(options.getBoolean("displayCutoutWhenLandscapeAndroid"));
        }

        boolean statusBarHidden = options.getBoolean("statusBarHidden");
        style.setStatusBarHidden(statusBarHidden);

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
            style.setTitleTextSize((int) titleTextSize);
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

        if (options.get("backInteractive") != null) {
            this.backInteractive = options.getBoolean("backInteractive");
        }

        if (options.get("backButtonHidden") != null) {
            this.backButtonHidden = options.getBoolean("backButtonHidden");
        }
    }

    void updateOptions(@NonNull ReadableMap readableMap) {
        Bundle patches = toBundle(readableMap);
        applyOptions(patches);

        if (readableMap.hasKey("screenBackgroundColor")) {
            String color = readableMap.getString("screenBackgroundColor");
            style.setScreenBackgroundColor(Color.parseColor(color));
            View root = fragment.requireView();
            root.setBackground(new ColorDrawable(Color.parseColor(color)));
        }

        if (shouldUpdateStatusBar(readableMap)) {
            fragment.setNeedsStatusBarAppearanceUpdate();
        }

        if (shouldUpdateToolbar(readableMap)) {
            fragment.setNeedsToolbarAppearanceUpdate();
        }

        if (shouldUpdateNavigationBar(readableMap)) {
            fragment.setNeedsNavigationBarAppearanceUpdate();
        }

        Bundle options = mergeOptions(fragment.getOptions(), patches);
        fragment.setOptions(options);

        if (readableMap.hasKey("leftBarButtonItem")) {
            Bundle bundle = options.getBundle("leftBarButtonItem");
            setLeftBarButtonItem(bundle);
        }

        if (readableMap.hasKey("rightBarButtonItem")) {
            Bundle bundle = options.getBundle("rightBarButtonItem");
            setRightBarButtonItem(bundle);
        }

        if (readableMap.hasKey("leftBarButtonItems")) {
            ArrayList<Bundle> items = options.getParcelableArrayList("leftBarButtonItems");
            setLeftBarButtonItems(items);
        }

        if (readableMap.hasKey("rightBarButtonItems")) {
            ArrayList<Bundle> items = options.getParcelableArrayList("rightBarButtonItems");
            setRightBarButtonItems(items);
        }

        if (readableMap.hasKey("titleItem")) {
            Bundle titleItem = options.getBundle("titleItem");
            setTitleItem(titleItem);
        }
    }

    private boolean shouldUpdateStatusBar(@NonNull ReadableMap readableMap) {
        String[] keys = new String[]{"topBarStyle", "statusBarColorAndroid", "statusBarHidden", "topBarColor", "displayCutoutWhenLandscapeAndroid"};
        for (String key : keys) {
            if (readableMap.hasKey(key)) {
                return true;
            }
        }
        return false;
    }

    private boolean shouldUpdateToolbar(@NonNull ReadableMap readableMap) {
        String[] keys = new String[]{
            "topBarStyle",
            "topBarColor", "topBarAlpha", "topBarShadowHidden", "topBarTintColor",
            "titleTextSize", "titleTextColor", "backButtonHidden"
        };

        for (String key : keys) {
            if (readableMap.hasKey(key)) {
                return true;
            }
        }
        return false;
    }

    private boolean shouldUpdateNavigationBar(@NonNull ReadableMap readableMap) {
        String[] keys = new String[]{"navigationBarColorAndroid", "navigationBarHiddenAndroid", "screenBackgroundColor"};
        for (String key : keys) {
            if (readableMap.hasKey(key)) {
                return true;
            }
        }
        return false;
    }

}
