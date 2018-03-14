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

        Log.i(TAG, "begin custom global style");

        // screenBackgroundColor
        String screenBackgroundColor = options.getString("screenBackgroundColor");
        if (screenBackgroundColor != null) {
            style.setScreenBackgroundColor(Color.parseColor(screenBackgroundColor));
        }

        // topBarStyle
        String topBarStyle = options.getString("topBarStyle");
        if (topBarStyle != null) {
            style.setStatusBarStyle(topBarStyle.equals("dark-content") ? BarStyle.DarkContent : BarStyle.LightContent);
        }

        // topBarBackgroundColor
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
        String statusBarColor = options.getString("statusBarColor");
        if (statusBarColor != null) {
            style.setStatusBarColor(Color.parseColor(statusBarColor));
        } else {
            style.setStatusBarColor(style.getToolbarBackgroundColor());
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // elevation
            double elevation = options.getDouble("elevation", -1);
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
        String titleAlignment = options.getString("titleAlignment");
        if (titleAlignment != null) {
            style.setTitleGravity(titleAlignment.equals("center") ? Gravity.CENTER : Gravity.START);
        }

        // barButtonItemTintColor
        String barButtonItemTintColor = options.getString("barButtonItemTintColor");
        if (barButtonItemTintColor != null) {
            style.setToolbarButtonTintColor(Color.parseColor(barButtonItemTintColor));
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
                //drawable.setColorFilter(style.getToolbarTintColor(), PorterDuff.Mode.SRC_ATOP);
                style.setBackIcon(drawable);
            }
        }

        // --------- tabBar ------------
        // -----------------------------

        // bottomBarColor
        String bottomBarColor = options.getString("bottomBarColor");
        if (bottomBarColor != null) {
            style.setBottomBarBackgroundColor(bottomBarColor);
        }

        String bottomBarButtonItemActiveColor = options.getString("bottomBarButtonItemActiveColor");
        if (bottomBarButtonItemActiveColor != null) {
            style.setBottomBarActiveColor(bottomBarButtonItemActiveColor);
        }

        String bottomBarButtonItemInactiveColor = options.getString("bottomBarButtonItemInactiveColor");
        if (bottomBarButtonItemInactiveColor != null) {
            style.setBottomBarInactiveColor(bottomBarButtonItemInactiveColor);
        }

        // bottomBarShadowImage
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            Bundle shadowImage = options.getBundle("bottomBarShadowImage");
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
                style.setBottomBarShadow(drawable);
            }
        }
    }

}
