package com.navigationhybrid;


import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import com.facebook.react.bridge.Arguments;
import com.navigationhybrid.androidnavigation.DrawableUtils;
import com.navigationhybrid.androidnavigation.TopBar;

import static com.navigationhybrid.Constants.ON_BAR_BUTTON_ITEM_CLICK_EVENT;
import static com.navigationhybrid.androidnavigation.AwesomeFragment.ARGS_SCENE_ID;


/**
 * Created by Listen on 2017/11/22.
 */
public class Garden {

    private static final String TAG = "ReactNative";

    private static GlobalStyle globalStyle = new GlobalStyle();

    static void setStyle(Context context, Bundle style) {
        globalStyle = new GlobalStyle();
        globalStyle.setStyle(context, style);
    }

    public static Bundle getStyle() {
        return globalStyle == null ? null : globalStyle.getStyle();
    }

    static GlobalStyle getGlobalStyle() {
        return globalStyle;
    }

    private final HybridFragment fragment;

    boolean hideBackButton;

    Garden(@NonNull HybridFragment fragment) {
        this.fragment = fragment;
    }


    String statusBarStyle() {
        return globalStyle.getTopBarStyle();
    }

    int statusBarColor() {
        return globalStyle.getTopBarBackgroundColor() == globalStyle.getStatusBarColor() ? Color.TRANSPARENT : globalStyle.getStatusBarColor();
    }

    int backgroundColor() {
        return globalStyle.getScreenBackgroundColor();
    }

    void setTopBarStyle() {
        if (fragment.getView() == null || fragment.getContext() == null) return;

        TopBar topBar = fragment.getTopBar();
        if (topBar == null) return;

        topBar.setBackgroundColor(globalStyle.getTopBarBackgroundColor());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            topBar.setElevation(globalStyle.getElevation(fragment.getContext().getApplicationContext()));
        } else {
            topBar.setShadow(globalStyle.getShadow());
        }

        Bundle options = fragment.getOptions();
        if (options == null) {
            options = new Bundle();
        }

        boolean hideShadow = options.getBoolean("hideShadow", false);
        setHideShadow(topBar, hideShadow);

        Bundle titleItem = options.getBundle("titleItem");
        if (titleItem != null) {
            setTitleItem(topBar, titleItem);
        }

        Bundle rightBarButtonItem = options.getBundle("rightBarButtonItem");
        if (rightBarButtonItem != null) {
            setRightBarButtonItem(topBar, rightBarButtonItem);
        }

        Bundle leftBarButtonItem = options.getBundle("leftBarButtonItem");
        if (leftBarButtonItem != null) {
            setLeftBarButtonItem(topBar, leftBarButtonItem);
        } else {
            boolean hideBackButton = options.getBoolean("hideBackButton", false);
            this.hideBackButton = hideBackButton;
            if (!fragment.isRoot() && !hideBackButton) {
                topBar.setNavigationIcon(globalStyle.getBackIcon(fragment.getContext().getApplicationContext()));
                topBar.setNavigationOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        fragment.getNavigationFragment().popFragment();

                    }
                });
            }
        }

    }

    void setHideShadow(@NonNull TopBar topBar, boolean hidden) {
        if (hidden) {
            topBar.hideShadow();
        }
    }

    public void setTitle(String title) {
        if (fragment.getTopBar() != null) {
            setTitle(fragment.getTopBar(), title);
        }
    }

    void setTitle(@NonNull TopBar topBar, String title) {
        TextView titleView = topBar.getTitleView();
        if (globalStyle.getTitleAlignment().equals("center")) { // default is 'left'
            topBar.setTitleViewAlignment("center");
        }
        titleView.setTextColor(globalStyle.getTitleTextColor());
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, globalStyle.getTitleTextSize());
        titleView.setText(title);
        //titleView.getPaint().setFakeBoldText(true); // 粗体
    }

    void setTitleItem(@NonNull Bundle titleItem) {
        if (fragment.getTopBar() != null) {
            setTitleItem(fragment.getTopBar(), titleItem);
        }
    }

    void setTitleItem(@NonNull TopBar topBar, @NonNull Bundle titleItem) {
        String title = titleItem.getString("title");
        setTitle(topBar, title);
    }

    void setLeftButton(Drawable icon, String title, boolean enabled, View.OnClickListener onClickListener) {
        TopBar topBar = fragment.getTopBar();
        if (topBar != null) {
            TextView leftButton = topBar.getLeftButton();
            topBar.setContentInsetsRelative(0, topBar.getContentInsetEnd());
            topBar.setNavigationIcon(null);
            topBar.setNavigationOnClickListener(null);
            setButton(leftButton, icon, title, enabled);
            leftButton.setOnClickListener(onClickListener);
        }
    }

    void setRightButton(Drawable icon, String title, boolean enabled, View.OnClickListener onClickListener) {
        TopBar topBar = fragment.getTopBar();
        if (topBar != null) {
            TextView rightButton = topBar.getRightButton();
            topBar.setContentInsetsRelative(topBar.getContentInsetStart(), 0);
            setButton(rightButton, icon, title, enabled);
            rightButton.setOnClickListener(onClickListener);
        }
    }

    void setLeftBarButtonItem(@NonNull Bundle leftBarButtonItem) {
        if (fragment.getTopBar() != null) {
            setLeftBarButtonItem(fragment.getTopBar(), leftBarButtonItem);
        }
    }

    void setLeftBarButtonItem(@NonNull TopBar topBar, @NonNull Bundle leftBarButtonItem) {
        Log.d(TAG, "leftBarButtonItem: " + leftBarButtonItem.toString());
        TextView leftButton = topBar.getLeftButton();
        topBar.setContentInsetsRelative(0, topBar.getContentInsetEnd());
        topBar.setNavigationIcon(null);
        topBar.setNavigationOnClickListener(null);
        setBarButtonItem(leftButton, leftBarButtonItem);
    }

    void setRightBarButtonItem(@NonNull Bundle rightBarButtonItem) {
        if (fragment.getTopBar() != null) {
            setRightBarButtonItem(fragment.getTopBar(), rightBarButtonItem);
        }
    }

    void setRightBarButtonItem(@NonNull TopBar topBar, @NonNull Bundle rightBarButtonItem) {
        Log.d(TAG, "rightBarButtonItem: " + rightBarButtonItem.toString());
        TextView rightButton = topBar.getRightButton();
        topBar.setContentInsetsRelative(topBar.getContentInsetStart(), 0);
        setBarButtonItem(rightButton, rightBarButtonItem);
    }

    private void setBarButtonItem(TextView button, Bundle item) {
        if (item != null) {
            String title = item.getString("title");
            boolean enabled = item.getBoolean("enabled", true);
            Bundle icon = item.getBundle("icon");

            Drawable drawable = null;
            if (icon != null) {
                String uri = icon.getString("uri");
                if (uri != null) {
                    drawable = DrawableUtils.fromUri(button.getContext().getApplicationContext(), uri);
                }
            }
            final String action = item.getString("action");

            setButton(button, drawable, title, enabled);

            if (action != null && enabled) {
                button.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
                        Bundle bundle = new Bundle();
                        bundle.putString("action", action);
                        bundle.putString(ARGS_SCENE_ID, fragment.getSceneId());
                        bridgeManager.sendEvent(ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
                    }
                });
            }
        }
    }

    private void setButton(TextView button, Drawable icon, String title, boolean enabled) {
        button.setOnClickListener(null);
        button.setText(null);
        button.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
        button.setMaxWidth(Integer.MAX_VALUE);
        button.setAlpha(1.0f);
        button.setVisibility(View.VISIBLE);

        int color = globalStyle.getBarButtonItemTintColor();
        if (!enabled) {
            color = DrawableUtils.generateGrayColor(color);
            button.setAlpha(0.3f);
        }
        button.setEnabled(enabled);

        TopBar topBar = fragment.getTopBar();

        if (icon != null) {
            icon.setColorFilter(color, PorterDuff.Mode.SRC_ATOP);
            button.setCompoundDrawablesWithIntrinsicBounds(icon, null, null, null);
            int width = topBar.getContentInsetStartWithNavigation();
            int padding = (width - icon.getIntrinsicWidth()) / 2;
            button.setMaxWidth(width);
            button.setPaddingRelative(padding, 0, padding, 0);
        } else {
            int padding = topBar.getContentInset();
            button.setPaddingRelative(padding, 0, padding, 0);
            button.setText(title);
            button.setTextColor(color);
            button.setTextSize(globalStyle.getBarButtonItemTextSize());
        }

        TypedValue typedValue = new TypedValue();
        if (topBar.getContext().getTheme().resolveAttribute(R.attr.actionBarItemBackground, typedValue, true)) {
            button.setBackgroundResource(typedValue.resourceId);
        }
    }

}
