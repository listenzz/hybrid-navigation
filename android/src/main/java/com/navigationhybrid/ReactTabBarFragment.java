package com.navigationhybrid;

import android.graphics.Color;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;

import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.Style;
import me.listenzz.navigation.TabBar;
import me.listenzz.navigation.TabBarFragment;


/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        super.onCustomStyle(style);
        Bundle options = getOptions();
        String tabBarColor = options.getString("tabBarColor");
        if (tabBarColor != null) {
            style.setTabBarBackgroundColor(tabBarColor);
        }

        String tabBarItemColor = options.getString("tabBarItemColor");
        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");

        if (tabBarItemColor != null) {
            style.setTabBarItemColor(tabBarUnselectedItemColor);
            style.setTabBarSelectedItemColor(tabBarItemColor);
        }

        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            style.setTabBarShadow(createTabBarShadow(shadowImage));
        }
    }

    @NonNull
    public Bundle getOptions() {
        Bundle args = FragmentHelper.getArguments(this);
        Bundle bundle = args.getBundle(Constants.ARG_OPTIONS);
        if (bundle == null) {
            bundle = new Bundle();
        }
        return bundle;
    }

    public void setOptions(@NonNull Bundle options) {
        Bundle args = FragmentHelper.getArguments(this);
        args.putBundle(Constants.ARG_OPTIONS, options);
        setArguments(args);
    }

    void updateTabBar(@NonNull ReadableMap readableMap) {
        TabBar tabBar = getTabBar();
        if (readableMap.hasKey("tabBarColor")) {
            String tabBarColor = readableMap.getString("tabBarColor");
            tabBar.setTabBarBackgroundColor(tabBarColor);
        }

        if (readableMap.hasKey("tabBarItemColor") && readableMap.hasKey("tabBarUnselectedItemColor")) {
            String tabBarItemColor = readableMap.getString("tabBarItemColor");
            String tabBarUnselectedItemColor = readableMap.getString("tabBarUnselectedItemColor");
            tabBar.setTabItemColor(tabBarItemColor, tabBarUnselectedItemColor);
        }

        if (readableMap.hasKey("tabBarShadowImage")) {
            Bundle shadowImage = Arguments.toBundle(readableMap.getMap("tabBarShadowImage"));
            if (shadowImage != null) {
                tabBar.setShadow(createTabBarShadow(shadowImage));
            }
        }

        setOptions(Garden.mergeOptions(getOptions(), readableMap));
    }

    Drawable createTabBarShadow(Bundle shadowImage) {
        Bundle image = shadowImage.getBundle("image");
        String color = shadowImage.getString("color");
        Drawable drawable = new ColorDrawable();
        if (image != null) {
            String uri = image.getString("uri");
            if (uri != null) {
                drawable = DrawableUtils.fromUri(requireContext(), uri);
                if (drawable instanceof BitmapDrawable) {
                    BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
                    bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
                }
            }
        } else if (color != null) {
            drawable = new ColorDrawable(Color.parseColor(color));
        }
        return drawable;
    }

}
