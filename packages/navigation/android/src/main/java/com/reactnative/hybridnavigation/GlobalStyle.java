package com.reactnative.hybridnavigation;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.common.logging.FLog;
import com.navigation.androidx.BarStyle;
import com.navigation.androidx.DrawableUtils;
import com.navigation.androidx.Style;

import java.util.Objects;

public class GlobalStyle {

    private static final String TAG = "Navigation";

    private final Bundle options;

    public GlobalStyle(Bundle options) {
        this.options = options;
    }

    public void inflateStyle(Context context, Style style) {
        if (options == null) {
            FLog.w(TAG, "Style options is null");
            return;
        }

        String screenBackgroundColor = options.getString("screenBackgroundColor");
        if (screenBackgroundColor != null) {
            style.setScreenBackgroundColor(Color.parseColor(screenBackgroundColor));
        }

        String statusBarStyle = options.getString("statusBarStyle");
        if (statusBarStyle != null) {
            style.setStatusBarStyle(statusBarStyle.equals("dark-content") ? BarStyle.DarkContent : BarStyle.LightContent);
        } else {
            style.setStatusBarStyle(BarStyle.DarkContent);
        }

        boolean displayCutout = options.getBoolean("displayCutoutWhenLandscapeAndroid", true);
        style.setDisplayCutoutWhenLandscape(displayCutout);

        String navigationBarColor = options.getString("navigationBarColorAndroid");
        if (navigationBarColor != null) {
            style.setNavigationBarColor(Color.parseColor(navigationBarColor));
        }

        // --------- tabBar ------------
        String tabBarBackgroundColor = options.getString("tabBarBackgroundColor");
        if (tabBarBackgroundColor != null) {
            style.setTabBarBackgroundColor(tabBarBackgroundColor);
        }

        String tabBarItemSelectedColor = options.getString("tabBarItemSelectedColor");
        style.setTabBarItemColor(Objects.requireNonNullElse(tabBarItemSelectedColor, "#FF5722"));

        String tabBarItemNormalColor = options.getString("tabBarItemNormalColor");
        style.setTabBarUnselectedItemColor(Objects.requireNonNullElse(tabBarItemNormalColor, "#666666"));

        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            setTabBarShadowImage(context, style, shadowImage);
        }

        String badgeColor = options.getString("tabBarBadgeColor");
        if (badgeColor != null) {
            style.setTabBarBadgeColor(badgeColor);
        }
    }

    private void setTabBarShadowImage(@NonNull Context context, @NonNull Style style, @NonNull Bundle shadowImage) {
        Bundle image = shadowImage.getBundle("image");
        if (image != null) {
            style.setTabBarShadow(buildDrawableFromImageBundle(context, image));
            return;
        }

        String color = shadowImage.getString("color");
        if (color != null) {
            style.setTabBarShadow(new ColorDrawable(Color.parseColor(color)));
        }
    }

    @Nullable
    private Drawable buildDrawableFromImageBundle(@NonNull Context context, @NonNull Bundle image) {
        String uri = image.getString("uri");
        if (uri == null) {
            throw new IllegalArgumentException("必须指定 image 的 uri 字段");
        }

        Drawable drawable = DrawableUtils.fromUri(context, uri);
        if (drawable instanceof BitmapDrawable bitmapDrawable) {
            bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
        }
        return drawable;
    }
}
