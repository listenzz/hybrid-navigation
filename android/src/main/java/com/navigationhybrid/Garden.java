package com.navigationhybrid;


import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.view.View;

import com.facebook.react.bridge.Arguments;

import me.listenzz.navigation.AwesomeToolbar;
import me.listenzz.navigation.DrawableUtils;

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

    private Bundle options;

    boolean hideBackButton;

    boolean hidesBottomBarWhenPushed;

    Garden(@NonNull HybridFragment fragment) {
        this.fragment = fragment;
        Bundle options = fragment.getOptions();
        if (options == null) {
            options = new Bundle();
        }
        this.options = options;
        this.hideBackButton = options.getBoolean("hideBackButton", false);

        Bundle tabItem = options.getBundle("tabItem");
        hidesBottomBarWhenPushed = tabItem == null || tabItem.getBoolean("hideTabBarWhenPush");

    }

    void configTopBar() {

        if (fragment.getView() == null || fragment.getContext() == null) return;

        boolean hideShadow = options.getBoolean("hideShadow", false);
        setHideShadow(hideShadow);

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

    public void setHideShadow(boolean hidden) {
        if (hidden) {
            Toolbar toolbar = fragment.getToolbar();
            if (toolbar != null && toolbar instanceof AwesomeToolbar) {
                AwesomeToolbar awesomeToolbar = (AwesomeToolbar) toolbar;
                awesomeToolbar.hideShadow();
            }
        }
    }

    void setTitleItem( @NonNull Bundle titleItem) {
        String title = titleItem.getString("title");
        fragment.setTitle(title);
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

    void setRightBarButtonItem( @NonNull Bundle item) {
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

}
