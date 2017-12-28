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
import android.support.annotation.NonNull;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.facebook.react.bridge.Arguments;

import static com.navigationhybrid.NavigationFragment.PROPS_NAV_ID;
import static com.navigationhybrid.NavigationFragment.PROPS_SCENE_ID;

/**
 * Created by Listen on 2017/11/22.
 */

public class Garden {

    public static String TOP_BAR_STYLE_LIGHT_CONTENT = "light-content";
    public static String TOP_BAR_STYLE_DARK_CONTENT = "dark-content";

    private static final String TAG = "ReactNative";
    private static int INVALID_COLOR = Integer.MAX_VALUE;

    private static int screenBackgroundColor = Color.WHITE;

    private static String topBarStyle = TOP_BAR_STYLE_LIGHT_CONTENT;
    private static Drawable backIcon;
    private static int statusBarColor = INVALID_COLOR;
    private static int topBarBackgroundColor = INVALID_COLOR;
    private static int topBarTintColor = INVALID_COLOR;
    private static int titleTextColor = INVALID_COLOR;
    private static int titleTextSize = 17;

    private static float elevation = -1;

    private static Drawable shadowDrawable;
    private static Drawable defaultShadow = new ColorDrawable(Color.parseColor("#DDDDDD"));

    private static String titleAlignment = "left"; // left, center, default is left
    private static int barButtonItemTintColor = INVALID_COLOR;
    private static int barButtonItemTextSize = 15;

    private static int tabBarItemColor = Color.parseColor("#c9c9c9");
    private static int tabBarItemSelectedColor = Color.parseColor("#F44336");
    private static int tabBarItemTextSize;
    private static int tabBarItemBubbleColor = Color.parseColor("#FF4040");
    private static int tabBarItemBubbleBorderColor = Color.WHITE;


    public static void setStyle(Bundle style) {

        // screenBackgroundColor
        String screenBackgroundColor = style.getString("screenBackgroundColor");
        if (screenBackgroundColor != null) {
            setScreenBackgroundColor(Color.parseColor(screenBackgroundColor));
        }

        // topBarStyle
        String topBarStyle = style.getString("topBarStyle");
        if (topBarStyle != null) {
            setTopBarStyle(topBarStyle);
            backIcon = null;
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
                setElevation(Float.valueOf(elevation + ""));
            }
        } else {
            // shadowDrawable
            Bundle shadowImage = style.getBundle("shadowImage");
            if (shadowImage == null) {
                shadowDrawable = defaultShadow;
            } else {
                Bundle image = shadowImage.getBundle("image");
                String color = shadowImage.getString("color");

                if (image != null) {
                    Drawable drawable = StyleUtils.createDrawable(image);
                    if (drawable instanceof BitmapDrawable) {
                        BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
                        bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
                    }
                    shadowDrawable = drawable;
                } else if (color != null) {
                    shadowDrawable = new ColorDrawable(Color.parseColor(color));
                } else {
                    shadowDrawable = null;
                }
            }
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
            setBackIcon(backIcon);
        }
    }

    public static void setScreenBackgroundColor(int color) {
        screenBackgroundColor = color;
    }

    public static int getScreenBackgroundColor() {
        return screenBackgroundColor;
    }

    public static void setTopBarStyle(String barStyle) {
        topBarStyle = barStyle;
    }

    public static String getTopBarStyle() {
        return topBarStyle;
    }

    public static void setStatusBarColor(int color) {
        statusBarColor = color;
    }

    public static int getStatusBarColor() {
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

    public static void setTopBarBackgroundColor(int color) {
        topBarBackgroundColor = color;
    }

    public static int getTopBarBackgroundColor() {
        if (topBarBackgroundColor != INVALID_COLOR) {
            return topBarBackgroundColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.BLACK;
        } else {
            return Color.WHITE;
        }
    }

    public static void setElevation(float elevation) {
        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        Context context =  bridgeManager.getReactInstanceManager().getCurrentReactContext().getApplicationContext();
        Garden.elevation = elevation * context.getResources().getDisplayMetrics().density;
    }

    public static float getElevation(Context context) {
        if (elevation != -1) {
            return elevation;
        }
        elevation = 4 * context.getResources().getDisplayMetrics().density;
        return  elevation;
    }

    public static void setTopBarTintColor(int color) {
        topBarTintColor = color;
    }

    public static int getTopBarTintColor() {
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

    public static void setBackIcon(Bundle icon) {
        Drawable drawable = StyleUtils.createDrawable(icon);
        drawable.setColorFilter(getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
        backIcon = drawable;
    }

    public static Drawable getBackIcon(Context context) {
        if (backIcon != null) {
            return backIcon;
        }
        Drawable drawable = context.getResources().getDrawable(R.drawable.nav_ic_arrow_back);
        drawable.setColorFilter(Garden.getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
        backIcon = drawable;
        return backIcon;
    }

    public static void setTitleTextColor(int color) {
        titleTextColor = color;
    }

    public static int getTitleTextColor() {
        if (titleTextColor != INVALID_COLOR) {
            return titleTextColor;
        }

        return getTopBarTintColor();
    }

    public static void setTitleTextSize(int dp) {
        titleTextSize = dp;
    }

    public static int getTitleTextSizeDp() {
        return titleTextSize;
    }

    public static void setBarButtonItemTintColor(int color) {
        barButtonItemTintColor = color;
    }

    public static int getBarButtonItemTintColor() {
        if (barButtonItemTintColor != INVALID_COLOR) {
            return barButtonItemTintColor;
        }
        return getTopBarTintColor();
    }


    public static void setBarButtonItemTextSize(int dp) {
        barButtonItemTextSize = dp;
    }

    public static int  getBarButtonItemTextSizeDp() {
        return barButtonItemTextSize;
    }

    public static void setTitleAlignment(String alignment) {
        titleAlignment = alignment;
    }

    public static String getTitleAlignment() {
        return titleAlignment;
    }


    // ----- instance ------

    private  final NavigationFragment fragment;

    public Garden(@NonNull NavigationFragment fragment) {
        this.fragment = fragment;
    }

    public void setTopBarStyle() {
        fragment.toolBar.setBackgroundColor(Garden.getTopBarBackgroundColor());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            fragment.toolBar.setElevation(Garden.getElevation(fragment.getContext()));
        } else {
            fragment.toolBar.setShadow(shadowDrawable);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = fragment.getActivity().getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Garden.getStatusBarColor());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (Garden.getTopBarStyle().equals(Garden.TOP_BAR_STYLE_DARK_CONTENT)) {
                    window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                }
            }
        }
    }

    public void setHideShadow(boolean hidden) {
        if (hidden) {
            fragment.toolBar.hideShadow();
        }
    }

    public void setTitle(String title) {
        if (fragment.getView() == null) return;
        TextView titleView = fragment.toolBar.getTitleView();
        if (Garden.getTitleAlignment().equals("center")) { // default is 'left'
            fragment.toolBar.setTitleViewAlignment("center");
        }
        titleView.setTextColor(Garden.getTitleTextColor());
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Garden.getTitleTextSizeDp());
        titleView.setText(title);
        //titleView.getPaint().setFakeBoldText(true); // 粗体
    }

    public void setTitleItem(Bundle titleItem) {
        if (titleItem != null) {
            String title = titleItem.getString("title");
            setTitle(title);
        }
    }

    public void setLeftBarButtonItem(Bundle leftBarButtonItem) {
        if (fragment.getView() == null) return;
        if (leftBarButtonItem == null) { return; }

        Log.d(TAG, "leftBarButtonItem: " + leftBarButtonItem.toString());

        TopBar topBar = fragment.toolBar;
        TextView leftButton = topBar.getLeftButton();
        
        topBar.setContentInsetsRelative(0, topBar.getContentInsetEnd());
        topBar.setNavigationIcon(null);
        topBar.setNavigationOnClickListener(null);
        setBarButtonItem(topBar, leftButton, leftBarButtonItem);
    }

    public void setRightBarButtonItem(Bundle rightBarButtonItem) {
        if (fragment.getView() == null) return;
        if (rightBarButtonItem == null) { return; }

        Log.d(TAG, "rightBarButtonItem: " + rightBarButtonItem.toString());

        TopBar topBar = fragment.toolBar;
        TextView rightButton = topBar.getRightButton();

        topBar.setContentInsetsRelative(topBar.getContentInsetStart(), 0);
        setBarButtonItem(topBar, rightButton, rightBarButtonItem);
    }

    private void setBarButtonItem(TopBar topBar, TextView button, Bundle item) {
        if (item != null) {
            String title = item.getString("title");
            boolean enabled = item.getBoolean("enabled", true);
            Bundle icon = item.getBundle("icon");

            Drawable drawable = null;
            if (icon != null) {
                drawable = StyleUtils.createDrawable(icon);
            }
            final String action = item.getString("action");

            topBar.setButton(button, drawable, title, enabled);

            if (action != null && enabled) {
                button.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
                        Bundle bundle = new Bundle();
                        bundle.putString("action", action);
                        bundle.putString(PROPS_NAV_ID, fragment.navigator.navId);
                        bundle.putString(PROPS_SCENE_ID, fragment.navigator.sceneId);
                        bridgeManager.sendEvent(Navigator.ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
                    }
                });
            }
        }
    }

}
