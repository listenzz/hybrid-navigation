package com.navigationhybrid;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.graphics.ColorUtils;

import static com.navigationhybrid.Constants.TOP_BAR_STYLE_LIGHT_CONTENT;


/**
 * Created by Listen on 2018/1/9.
 */

public class GlobalStyle {

    private static final String TAG = "ReactNative";

    private static int INVALID_COLOR = Integer.MAX_VALUE;
    private static Drawable defaultShadow = new ColorDrawable(Color.parseColor("#DDDDDD"));

    private int screenBackgroundColor = Color.WHITE;

    // ----- topBar -----
    private String topBarStyle = TOP_BAR_STYLE_LIGHT_CONTENT;
    private Drawable backIcon;
    private int statusBarColor = INVALID_COLOR;
    private int topBarBackgroundColor = INVALID_COLOR;
    private int topBarTintColor = INVALID_COLOR;
    private int titleTextColor = INVALID_COLOR;
    private int titleTextSize = 17;
    private float elevation = -1;
    private Drawable shadow;

    private String titleAlignment = "left"; // left, center, default is left
    private int barButtonItemTintColor = INVALID_COLOR;
    private int barButtonItemTextSize = 15;


    // ---- tabBar ------
    private int tabBarBackgroundColor = INVALID_COLOR;

    private int tabItemTextSize = 10;
    private int tabItemColor = INVALID_COLOR;
    private int tabItemSelectedColor = INVALID_COLOR;
    private int tabBadgeColor = Color.parseColor("#FF4040");
    private int tabBadgeBorderColor = Color.WHITE;

    private Bundle style;

    public void setStyle(Context context, Bundle style) {

        this.style = style;

        // screenBackgroundColor
        String screenBackgroundColor = style.getString("screenBackgroundColor");
        if (screenBackgroundColor != null) {
            setScreenBackgroundColor(Color.parseColor(screenBackgroundColor));
        }

        // topBarStyle
        String topBarStyle = style.getString("topBarStyle");
        if (topBarStyle != null) {
            setTopBarStyle(topBarStyle);
        }

        // topBarBackgroundColor
        String topBarBackgroundColor = style.getString("topBarBackgroundColor");
        if (topBarBackgroundColor != null) {
            setTopBarBackgroundColor(Color.parseColor(topBarBackgroundColor));
        }

        // statusBarColor
        String statusBarColor = style.getString("statusBarColor");
        if (statusBarColor != null) {
            setStatusBarColor(Color.parseColor(statusBarColor));
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // elevation
            double elevation = style.getDouble("elevation", -1);
            if (elevation != -1) {
                setElevation(context, Float.valueOf(elevation + ""));
            }
        } else {
            // shadow
            Bundle shadowImage = style.getBundle("shadowImage");
            Drawable drawable = null;
            if (shadowImage == null) {
                drawable = defaultShadow;
            } else {
                Bundle image = shadowImage.getBundle("image");
                String color = shadowImage.getString("color");

                if (image != null) {
                    drawable = StyleUtils.createDrawable(context, image);
                    if (drawable instanceof BitmapDrawable) {
                        BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
                        bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
                    }
                } else if (color != null) {
                    drawable = new ColorDrawable(Color.parseColor(color));
                }
            }
            setShadow(drawable);
        }

        // topBarTintColor
        String topBarTintColor = style.getString("topBarTintColor");
        if (topBarTintColor != null) {
            setTopBarTintColor(Color.parseColor(topBarTintColor));
        }

        // titleTextColor
        String titleTextColor = style.getString("titleTextColor");
        if (titleTextColor != null) {
            setTitleTextColor(Color.parseColor(titleTextColor));
        }

        // titleTextSize
        int titleTextSize = style.getInt("titleTextSize", -1);
        if (titleTextSize != -1) {
            setTitleTextSize(titleTextSize);
        }

        // titleAlignment
        String titleAlignment = style.getString("titleAlignment");
        if (titleAlignment != null) {
            setTitleAlignment(titleAlignment);
        }

        // barButtonItemTintColor
        String barButtonItemTintColor = style.getString("barButtonItemTintColor");
        if (barButtonItemTintColor != null) {
            setBarButtonItemTintColor(Color.parseColor(barButtonItemTintColor));
        }

        // barButtonItemTextSize
        int barButtonItemTextSize = style.getInt("barButtonItemTextSize", -1);
        if (barButtonItemTextSize != -1) {
            setBarButtonItemTextSize(barButtonItemTextSize);
        }

        // backIcon
        Bundle backIcon = style.getBundle("backIcon");
        if (backIcon != null) {
            Drawable drawable = StyleUtils.createDrawable(context, backIcon);
            drawable.setColorFilter(getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
            setBackIcon(drawable);
        }

        // --------- tabBar ------------
        // -----------------------------

        // tabBarBackgroundColor
        String tabBarBackgroundColor = style.getString("tabBarBackgroundColor");
        if (tabBarBackgroundColor != null) {
            setTabBarBackgroundColor(Color.parseColor(tabBarBackgroundColor));
        }

        // tabItemColor
        String tabItemColor = style.getString("tabItemColor");
        if (tabItemColor != null) {
            setTabItemColor(Color.parseColor(tabItemColor));
        }

        // tabItemSelectedColor
        String tabItemSelectedColor = style.getString("tabItemSelectedColor");
        if (tabItemSelectedColor != null) {
            setTabItemSelectedColor(Color.parseColor(tabItemSelectedColor));
        }

    }

    public Bundle getStyle() {
        return style;
    }

    public void setScreenBackgroundColor(int color) {
        screenBackgroundColor = color;
    }

    public int getScreenBackgroundColor() {
        return screenBackgroundColor;
    }


    // ----- tabBar  -----

    public void setTabBarBackgroundColor(int color) {
        tabBarBackgroundColor = color;
    }

    public int getTabBarBackgroundColor() {
        if (tabBarBackgroundColor != INVALID_COLOR) {
            return tabBarBackgroundColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.BLACK;
        } else {
            return Color.WHITE;
        }
    }

    public void setTabItemColor(int color) {
        tabItemColor = color;
    }

    public int getTabItemColor() {
        if (tabItemColor != INVALID_COLOR) {
            return tabItemColor;
        } else {
            return ColorUtils.setAlphaComponent(getTabItemSelectedColor(), 127);
        }
    }

    public void setTabItemSelectedColor(int color) {
        tabItemSelectedColor = color;
    }

    public int getTabItemSelectedColor() {
        if (tabItemSelectedColor != INVALID_COLOR) {
            return tabItemSelectedColor;
        }
        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.WHITE;
        } else {
            if (tabBarBackgroundColor == INVALID_COLOR) {
                return Color.parseColor("#666666");
            }
            return Color.BLACK;
        }
    }

    public void setTabBadgeColor(int color) {
        tabBadgeColor = color;
    }

    public int getTabBadgeColor() {
        return tabBadgeColor;
    }

    public void setTabBadgeBorderColor(int color) {
        tabBadgeBorderColor = color;
    }

    public int getTabBadgeBorderColor() {
        return tabBadgeBorderColor;
    }

    public int getTabItemTextSize() {
        return tabItemTextSize;
    }

    public void setTabItemTextSize(int dp) {
        this.tabItemTextSize = dp;
    }

    // ------- topBar ---------

    public void setTopBarStyle(String barStyle) {
        topBarStyle = barStyle;
    }

    public String getTopBarStyle() {
        return topBarStyle;
    }

    public void setStatusBarColor(int color) {
        statusBarColor = color;
    }

    public int getStatusBarColor() {
        if (statusBarColor != INVALID_COLOR) {
            return statusBarColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return getTopBarBackgroundColor();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return getTopBarBackgroundColor();
        }

        return Color.BLACK;
    }

    public void setTopBarBackgroundColor(int color) {
        topBarBackgroundColor = color;
    }

    public int getTopBarBackgroundColor() {
        if (topBarBackgroundColor != INVALID_COLOR) {
            return topBarBackgroundColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.BLACK;
        } else {
            return Color.WHITE;
        }
    }

    public void setElevation(Context context, float elevation) {
        this.elevation = elevation * context.getResources().getDisplayMetrics().density;
    }

    public float getElevation(Context context) {
        if (elevation != -1) {
            return elevation;
        }
        elevation = 4 * context.getResources().getDisplayMetrics().density;
        return elevation;
    }

    public void setTopBarTintColor(int color) {
        topBarTintColor = color;
    }

    public int getTopBarTintColor() {
        if (topBarTintColor != INVALID_COLOR) {
            return topBarTintColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.WHITE;
        } else {

            if (topBarBackgroundColor == INVALID_COLOR) {
                return Color.parseColor("#666666");
            }

            return Color.BLACK;
        }
    }

    public void setBackIcon(Drawable icon) {
        backIcon = icon;
    }

    public Drawable getBackIcon(Context context) {
        if (backIcon != null) {
            return backIcon;
        }
        Drawable drawable = context.getResources().getDrawable(R.drawable.nav_ic_arrow_back);
        drawable.setColorFilter(getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
        backIcon = drawable;
        return backIcon;
    }

    public void setTitleTextColor(int color) {
        titleTextColor = color;
    }

    public int getTitleTextColor() {
        if (titleTextColor != INVALID_COLOR) {
            return titleTextColor;
        }

        return getTopBarTintColor();
    }

    public void setTitleTextSize(int dp) {
        titleTextSize = dp;
    }


    public int getTitleTextSize() {
        return titleTextSize;
    }

    public Drawable getShadow() {
        return shadow;
    }

    public void setShadow(Drawable drawable) {
        this.shadow = drawable;
    }



    public void setBarButtonItemTintColor(int color) {
        barButtonItemTintColor = color;
    }

    public int getBarButtonItemTintColor() {
        if (barButtonItemTintColor != INVALID_COLOR) {
            return barButtonItemTintColor;
        }
        return getTopBarTintColor();
    }

    public void setBarButtonItemTextSize(int dp) {
        barButtonItemTextSize = dp;
    }

    public int getBarButtonItemTextSize() {
        return barButtonItemTextSize;
    }

    public void setTitleAlignment(String alignment) {
        titleAlignment = alignment;
    }

    public String getTitleAlignment() {
        return titleAlignment;
    }

}
