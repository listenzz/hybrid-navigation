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

import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.Style;
import me.listenzz.navigation.TabBar;
import me.listenzz.navigation.TabBarFragment;

import static com.navigationhybrid.Constants.ARG_SCENE_ID;
import static com.navigationhybrid.Constants.ON_COMPONENT_RESULT_EVENT;
import static com.navigationhybrid.Constants.REQUEST_CODE_KEY;
import static com.navigationhybrid.Constants.RESULT_CODE_KEY;
import static com.navigationhybrid.Constants.RESULT_DATA_KEY;
import static com.navigationhybrid.Constants.SWITCH_TAB;


/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

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

    public void setIntercepted(boolean intercepted) {
        this.intercepted = intercepted;
    }

    private boolean intercepted = true;

    @Override
    public void setSelectedIndex(int index) {
        AwesomeFragment selectedFragment = getSelectedFragment();
        if (selectedFragment == null) {
            super.setSelectedIndex(index);
            return;
        }

        if (selectedFragment instanceof NavigationFragment) {
            NavigationFragment nav = (NavigationFragment) selectedFragment;
            selectedFragment = nav.getRootFragment();
        }

        ReactFragment selectedReactFragment = null;
        if (selectedFragment instanceof ReactFragment) {
            selectedReactFragment = (ReactFragment) selectedFragment;
        }

        // 必须先判断选中的 fragment 是否为 ReactFragment
        if (selectedReactFragment == null || !this.intercepted) {
            super.setSelectedIndex(index);
            return;
        }

        super.setSelectedIndex(getSelectedIndex());

        List<AwesomeFragment> fragments = getChildFragments();
        AwesomeFragment fragment = fragments.get(index);

        if (fragment instanceof NavigationFragment) {
            NavigationFragment nav = (NavigationFragment) fragment;
            fragment = nav.getRootFragment();
        }

        ReactFragment reactFragment = null;
        if (fragment instanceof ReactFragment) {
            reactFragment = (ReactFragment) fragment;
        }

        Bundle data = new Bundle();
        data.putString("from", selectedReactFragment.getModuleName());
        data.putString(ARG_SCENE_ID, selectedReactFragment.getSceneId());
        if (reactFragment != null) {
            data.putString("moduleName", reactFragment.getModuleName());
        }
        data.putInt("index", index);
        getReactBridgeManager().sendEvent(SWITCH_TAB, Arguments.fromBundle(data));
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
            style.setTabBarBackgroundColor(tabBarColor);
            tabBar.setTabBarBackgroundColor(tabBarColor);
            setNeedsNavigationBarAppearanceUpdate();
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
