package com.navigationhybrid;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;

import com.facebook.react.uimanager.PixelUtil;

import me.listenzz.navigation.BarStyle;
import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.Style;


/**
 * Created by Listen on 2018/1/9.
 */

public class GlobalStyle {

    private static final String TAG = "ReactNative";

    private Bundle options;

    public Bundle getOptions() {
        return options;
    }

    public GlobalStyle(Bundle options) {
        this.options = options;
    }

    public void inflateStyle(Context context, Style style) {
        if (options == null) {
            Log.w(TAG, "style options is null");
            return;
        }

        Log.i(TAG, "custom global style");

        // screenBackgroundColor
        String screenBackgroundColor = options.getString("screenBackgroundColor");
        if (screenBackgroundColor != null) {
            style.setScreenBackgroundColor(Color.parseColor(screenBackgroundColor));
        }

        // toolbarHeight
        double toolbarHeight = options.getDouble("toolbarHeight", -1);
        if (toolbarHeight != -1) {
            style.setToolbarHeight((int) PixelUtil.toPixelFromDIP(toolbarHeight));
        }

        // topBarStyle
        String topBarStyle = options.getString("topBarStyle");
        if (topBarStyle != null) {
            style.setStatusBarStyle(topBarStyle.equals("dark-content") ? BarStyle.DarkContent : BarStyle.LightContent);
        }

        // topBarColor
        String topBarColor = options.getString("topBarColor");
        if (topBarColor != null) {
            style.setToolbarBackgroundColor(Color.parseColor(topBarColor));
        } else {
            if (style.getStatusBarStyle() == BarStyle.LightContent) {
                style.setToolbarBackgroundColor(Color.BLACK);
            } else {
                style.setToolbarBackgroundColor(Color.WHITE);
            }
        }

        // statusBarColor
        String statusBarColor = options.getString("statusBarColorAndroid");
        if (statusBarColor != null) {
            style.setStatusBarColor(Color.parseColor(statusBarColor));
        } else {
            style.setStatusBarColor(style.getToolbarBackgroundColor());
        }

        // navigationBarColor
        String navigationBarColor = options.getString("navigationBarColorAndroid");
        if (navigationBarColor != null) {
            style.setNavigationBarColor(Color.parseColor(navigationBarColor));
        } else {
            style.setNavigationBarColor(null);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // elevation
            double elevation = options.getDouble("elevationAndroid", -1);
            if (elevation != -1) {
                style.setElevation((int)elevation);
            }
        } else {
            // shadow
            Bundle shadowImage = options.getBundle("shadowImage");
            if (shadowImage != null) {
                Bundle image = shadowImage.getBundle("image");
                String color = shadowImage.getString("color");
                Drawable drawable = null;
                if (image != null) {
                    String uri = image.getString("uri");
                    if (uri != null) {
                        drawable = DrawableUtils.fromUri(context, uri);
                        if (drawable instanceof BitmapDrawable) {
                            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
                            bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
                        }
                    }
                } else if (color != null) {
                    drawable = new ColorDrawable(Color.parseColor(color));
                }
                style.setShadow(drawable);
            }
        }

        // topBarTintColor
        String topBarTintColor = options.getString("topBarTintColor");
        if (topBarTintColor != null) {
            style.setToolbarTintColor(Color.parseColor(topBarTintColor));
        }

        // titleTextColor
        String titleTextColor = options.getString("titleTextColor");
        if (titleTextColor != null) {
            style.setTitleTextColor(Color.parseColor(titleTextColor));
        }

        // titleTextSize
        double titleTextSize = options.getDouble("titleTextSize", -1);
        if (titleTextSize != -1) {
            style.setTitleTextSize((int)titleTextSize);
        }

        // titleAlignment
        String titleAlignment = options.getString("titleAlignmentAndroid");
        if (titleAlignment != null) {
            style.setTitleGravity(titleAlignment.equals("center") ? Gravity.CENTER : Gravity.START);
        } else {
            style.setTitleGravity(Gravity.START);
        }

        // barButtonItemTextSize
        double barButtonItemTextSize = options.getDouble("barButtonItemTextSize", -1);
        if (barButtonItemTextSize != -1) {
            style.setToolbarButtonTextSize((int) barButtonItemTextSize);
        }

        // backIcon
        Bundle backIcon = options.getBundle("backIcon");
        if (backIcon != null) {
            String uri = backIcon.getString("uri");
            if (uri != null) {
                Drawable drawable = DrawableUtils.fromUri(context, uri);
                style.setBackIcon(drawable);
            }
        }

        // --------- tabBar ------------
        // -----------------------------

        // tabBarColor
        String tabBarColor = options.getString("tabBarColor");
        if (tabBarColor != null) {
            style.setTabBarBackgroundColor(tabBarColor);
        }

        String tabBarItemColor = options.getString("tabBarItemColor");
        if (tabBarItemColor != null) {
            style.setTabBarItemColor(tabBarItemColor);
        } else {
            style.setTabBarItemColor("#FF5722");
        }

        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");
        if (tabBarUnselectedItemColor != null) {
            style.setTabBarUnselectedItemColor(tabBarUnselectedItemColor);
        } else {
            style.setTabBarUnselectedItemColor("#BDBDBD");
        }

        // tabBarShadowImage
        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            Bundle image = shadowImage.getBundle("image");
            String color = shadowImage.getString("color");
            Drawable drawable = null;
            if (image != null) {
                String uri = image.getString("uri");
                if (uri != null) {
                    drawable = DrawableUtils.fromUri(context, uri);
                    if (drawable instanceof BitmapDrawable) {
                        BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
                        bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
                    }
                }
            } else if (color != null) {
                drawable = new ColorDrawable(Color.parseColor(color));
            }
            style.setTabBarShadow(drawable);
        }

        // swipeBackEnabledAndroid
        boolean swipeBackEnabled = options.getBoolean("swipeBackEnabledAndroid", false);
        style.setSwipeBackEnabled(swipeBackEnabled);

        // badgeColor;
        String badgeColor = options.getString("tabBarBadgeColor");
        if (badgeColor != null) {
            style.setTabBarBadgeColor(badgeColor);
        }

    }

}
