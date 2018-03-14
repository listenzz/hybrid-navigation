package com.navigationhybrid;


import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;

import com.facebook.react.bridge.Arguments;

import me.listenzz.navigation.AwesomeToolbar;
import me.listenzz.navigation.BarStyle;
import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.Style;

import static com.navigationhybrid.Constants.ARG_SCENE_ID;
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

    private final HybridFragment fragment;

    private final Style style;

    private Bundle options;

    boolean backBackHidden;

    boolean backInteractive;

    boolean hidesBottomBarWhenPushed;

    boolean topBarHidden;

    float topBarAlpha = 1.0f;

    Garden(@NonNull HybridFragment fragment) {
        // 构造 garden 实例时，Toolbar 还没有被创建

        this.fragment = fragment;
        this.style = fragment.getStyle();

        Bundle options = fragment.getOptions();
        if (options == null) {
            options = new Bundle();
        }

        this.options = options;

        this.backBackHidden = options.getBoolean("backButtonHidden", false);
        this.backInteractive = options.getBoolean("backInteractive", true);
        this.topBarHidden = options.getBoolean("topBarHidden", false);
        Bundle tabItem = options.getBundle("tabItem");
        this.hidesBottomBarWhenPushed = tabItem == null || tabItem.getBoolean("hideTabBarWhenPush");

        double topBarAlpha = options.getDouble("topBarAlpha", -1);
        if (topBarAlpha != -1) {
            this.topBarAlpha = (float) topBarAlpha;
        }

        String barStyle = options.getString("topBarStyle");
        if (barStyle != null) {
            if (barStyle.equals("dark-content")) {
                style.setStatusBarStyle(BarStyle.DarkContent);
            } else {
                style.setStatusBarStyle(BarStyle.LightContent);
            }
        }

        String topBarColor = options.getString("topBarColor");
        if (!TextUtils.isEmpty(topBarColor)) {
            int color = Color.parseColor(topBarColor);
            style.setToolbarBackgroundColor(color);
            style.setStatusBarColor(color);
        }

        String statusBarColor = options.getString("statusBarColor");
        if (!TextUtils.isEmpty(statusBarColor)) {
            style.setStatusBarColor(Color.parseColor(statusBarColor));
        }
    }

    void configTopBar() {

        if (fragment.getView() == null || fragment.getContext() == null) {
            return;
        }

        Toolbar toolbar = fragment.getToolbar();
        if (toolbar == null) {
            return;
        }

        double topBarAlpha = options.getDouble("topBarAlpha", -1);
        if (topBarAlpha != -1) {
            setToolbarAlpha((float)topBarAlpha);
        }

        boolean topBarShadowHidden = options.getBoolean("topBarShadowHidden", false);
        setToolbarShadowHidden(topBarShadowHidden);

        Bundle titleItem = options.getBundle("titleItem");
        if (titleItem != null) {
            setTitleItem(titleItem);
        }

        Bundle rightBarButtonItem = options.getBundle("rightBarButtonItem");
        if (rightBarButtonItem != null) {
            setRightBarButtonItem(rightBarButtonItem);
        }

        Bundle leftBarButtonItem = options.getBundle("leftBarButtonItem");
        if (leftBarButtonItem != null) {
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

    void setLeftBarButtonItem(@NonNull Bundle item) {
        // Log.d(TAG, "leftBarButtonItem: " + item.toString());
        Context context = fragment.getContext();
        if (context == null) return;

        String title = item.getString("title");
        boolean enabled = item.getBoolean("enabled", true);
        Bundle icon = item.getBundle("icon");

        Drawable drawable = null;
        if (icon != null) {
            String uri = icon.getString("uri");
            if (uri != null) {
                drawable = DrawableUtils.fromUri(context, uri);
            }
        }
        final String action = item.getString("action");
        fragment.setToolbarLeftButton(drawable, title, enabled, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
                Bundle bundle = new Bundle();
                bundle.putString("action", action);
                bundle.putString(ARG_SCENE_ID, fragment.getSceneId());
                bridgeManager.sendEvent(ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
            }
        });
    }

    void setRightBarButtonItem(@NonNull Bundle item) {
        // Log.d(TAG, "rightBarButtonItem: " + item.toString());
        Context context = fragment.getContext();
        if (context == null) return;

        String title = item.getString("title");
        boolean enabled = item.getBoolean("enabled", true);
        Bundle icon = item.getBundle("icon");

        Drawable drawable = null;
        if (icon != null) {
            String uri = icon.getString("uri");
            if (uri != null) {
                drawable = DrawableUtils.fromUri(context, uri);
            }
        }
        final String action = item.getString("action");

        fragment.setToolbarRightButton(drawable, title, enabled, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
                Bundle bundle = new Bundle();
                bundle.putString("action", action);
                bundle.putString(ARG_SCENE_ID, fragment.getSceneId());
                bridgeManager.sendEvent(ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
            }
        });

    }

    void setStatusBarColor(int color) {
        style.setStatusBarColor(color);
        fragment.setStatusBarColor(color, false);
    }

    void setTopBarStyle(BarStyle barStyle) {
        style.setStatusBarStyle(barStyle);
        fragment.setNeedsStatusBarAppearanceUpdate();
    }

    void setToolbarAlpha(float alpha) {
        Toolbar toolbar = fragment.getToolbar();
        if (toolbar != null && toolbar instanceof AwesomeToolbar) {
            this.topBarAlpha = alpha;
            toolbar.setAlpha(alpha);
        }
    }

    void setTopBarColor(int color) {
        if (style.getToolbarBackgroundColor() == style.getStatusBarColor()) {
            style.setStatusBarColor(color);
        }
        style.setToolbarBackgroundColor(color);
        Toolbar toolbar = fragment.getToolbar();
        if (toolbar != null && toolbar instanceof AwesomeToolbar) {
            toolbar.setBackgroundColor(color);
        }
    }

    void setToolbarShadowHidden(boolean hidden) {
        Toolbar toolbar = fragment.getToolbar();
        if (toolbar != null && toolbar instanceof AwesomeToolbar) {
            AwesomeToolbar awesomeToolbar = (AwesomeToolbar) toolbar;
            if (hidden) {
                awesomeToolbar.hideShadow();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    awesomeToolbar.setElevation(fragment.getStyle().getElevation());
                } else {
                    awesomeToolbar.setShadow(fragment.getStyle().getShadow());
                }
            }
        }
    }

}
