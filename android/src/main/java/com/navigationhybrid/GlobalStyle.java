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

import com.navigationhybrid.androidnavigation.DrawableUtils;

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
    private String bottomBarBackgroundColor;
    private String bottomBarButtonItemTintColor;
    private Drawable bottomBarShadow;

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
            String uri = backIcon.getString("uri");
            if (uri != null) {
                Drawable drawable = DrawableUtils.fromUri(context, uri);
                drawable.setColorFilter(getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
                setBackIcon(drawable);
            }
        }

        // --------- tabBar ------------
        // -----------------------------

        // tabBarBackgroundColor
        String bottomBarBackgroundColor = style.getString("bottomBarBackgroundColor");
        if (bottomBarBackgroundColor != null) {
            setBottomBarBackgroundColor(bottomBarBackgroundColor);
        }

        String bottomBarButtonItemTintColor = style.getString("bottomBarButtonItemTintColor");
        if (bottomBarButtonItemTintColor != null) {
            setBottomBarButtonItemTintColor(bottomBarButtonItemTintColor);
        }

        // bottomBarShadowImage
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // elevation
            //double elevation = style.getDouble("elevation", -1);
            //if (elevation != -1) {
            //    setElevation(context, Float.valueOf(elevation + ""));
            //}
        } else {
            // shadow
            Bundle shadowImage = style.getBundle("bottomBarShadowImage");
            Drawable drawable = null;
            if (shadowImage == null) {
                drawable = defaultShadow;
            } else {
                Bundle image = shadowImage.getBundle("image");
                String color = shadowImage.getString("color");

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
            }
            setBottomBarShadow(drawable);
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

    public void setBottomBarBackgroundColor(String bottomBarBackgroundColor) {
        this.bottomBarBackgroundColor = bottomBarBackgroundColor;
    }

    public String getBottomBarBackgroundColor() {
        return bottomBarBackgroundColor;
    }

    public void setBottomBarButtonItemTintColor(String bottomBarButtonItemTintColor) {
        this.bottomBarButtonItemTintColor = bottomBarButtonItemTintColor;
    }

    public String getBottomBarButtonItemTintColor() {
        return bottomBarButtonItemTintColor;
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

    public Drawable getBottomBarShadow() {
        return bottomBarShadow;
    }

    public void setBottomBarShadow(Drawable drawable) {
        this.bottomBarShadow = drawable;
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
