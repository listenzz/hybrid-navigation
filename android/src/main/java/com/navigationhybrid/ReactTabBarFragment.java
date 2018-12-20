package com.navigationhybrid;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.graphics.drawable.DrawableCompat;

import com.facebook.react.bridge.Arguments;

import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DefaultTabBarProvider;
import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.Style;
import me.listenzz.navigation.TabBar;
import me.listenzz.navigation.TabBarFragment;

import static com.navigationhybrid.Constants.ACTION_SET_BADGE_TEXT;
import static com.navigationhybrid.Constants.ACTION_SET_RED_POINT;
import static com.navigationhybrid.Constants.ACTION_SET_TAB_ICON;
import static com.navigationhybrid.Constants.ACTION_UPDATE_TAB_BAR;
import static com.navigationhybrid.Constants.ARG_SCENE_ID;
import static com.navigationhybrid.Constants.KEY_ACTION;
import static com.navigationhybrid.Constants.KEY_BADGE_TEXT;
import static com.navigationhybrid.Constants.KEY_ICON;
import static com.navigationhybrid.Constants.KEY_ICON_SELECTED;
import static com.navigationhybrid.Constants.KEY_INDEX;
import static com.navigationhybrid.Constants.KEY_OPTIONS;
import static com.navigationhybrid.Constants.KEY_VISIBLE;
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
        } else {
            options.putString("tabBarItemColor", style.getTabBarItemColor());
            options.putString("tabBarSelectedItemColor", style.getTabBarSelectedItemColor());
            options.putString("badgeColor", style.getBadgeColor());
        }

        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            style.setTabBarShadow(Utils.createTabBarShadow(requireContext(), shadowImage));
        }
    }

    @Override
    public void updateTabbar(Bundle options) {
        super.updateTabbar(options);
        if (getTabBarProvider() instanceof DefaultTabBarProvider) {
            String action = options.getString(KEY_ACTION);
            if (action == null) {
                return;
            }

            switch (action) {
                case ACTION_SET_BADGE_TEXT:
                    setBadge(options.getInt(KEY_INDEX), options.getString(KEY_BADGE_TEXT));
                    break;
                case ACTION_SET_RED_POINT:
                    setRedPoint(options.getInt(KEY_INDEX), options.getBoolean(KEY_VISIBLE));
                    break;
                case ACTION_SET_TAB_ICON:
                    setTabIcon(options.getInt(KEY_INDEX), options.getBundle(KEY_ICON), options.getBundle(KEY_ICON_SELECTED));
                    break;
                case ACTION_UPDATE_TAB_BAR:
                    updateTabBarAppearance(options.getBundle(KEY_OPTIONS));
                    break;
            }
        }
    }

    private void setBadge(int index, String text) {
        TabBar tabBar = getTabBar();
        tabBar.setBadge(index, text);
    }

    private void setRedPoint(int index, boolean visible) {
        TabBar tabBar = getTabBar();
        tabBar.setRedPoint(index, visible);
    }

    private void setTabIcon(int index, Bundle icon, Bundle selectedIcon) {
        TabBar tabBar = getTabBar();
        Drawable drawable = drawableFromReadableMap(requireContext(), icon);
        if (drawable == null) {
            return;
        }
        Drawable selectedDrawable = drawableFromReadableMap(requireContext(), selectedIcon);
        AwesomeFragment fragment = getChildFragments().get(index);
        if (selectedDrawable != null) {
            fragment.getTabBarItem().iconUri = icon.getString("uri");
            fragment.getTabBarItem().selectedIconUri = selectedIcon.getString("uri");
            tabBar.setTabIcon(index, selectedDrawable, drawable);
        } else {
            fragment.getTabBarItem().iconUri = icon.getString("uri");
            tabBar.setTabIcon(index, drawable, null);
        }
    }

    private void updateTabBarAppearance(@Nullable Bundle options) {
        if (options == null) {
            return;
        }

        TabBar tabBar = getTabBar();
        String tabBarColor = options.getString("tabBarColor");
        if (tabBarColor != null) {
            style.setTabBarBackgroundColor(tabBarColor);
            tabBar.setTabBarBackgroundColor(tabBarColor);
            setNeedsNavigationBarAppearanceUpdate();
        }

        String tabBarItemColor = options.getString("tabBarItemColor");
        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");
        if (tabBarItemColor != null && tabBarUnselectedItemColor != null) {
            tabBar.setTabItemColor(tabBarItemColor, tabBarUnselectedItemColor);
        }

        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            tabBar.setShadow(Utils.createTabBarShadow(requireContext(), shadowImage));
        }

        setOptions(Garden.mergeOptions(getOptions(), options));
    }

    private Drawable drawableFromReadableMap(Context context, Bundle icon) {
        if (icon != null) {
            String uri = icon.getString("uri");
            if (uri != null) {
                return DrawableCompat.wrap(DrawableUtils.fromUri(context, uri));
            }
        }
        return null;
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

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        Bundle options = getOptions();
        String tabBarModuleName = options.getString("tabBarModuleName");
        if (tabBarModuleName != null) {
            Bundle result = new Bundle();
            result.putInt(REQUEST_CODE_KEY, requestCode);
            result.putInt(RESULT_CODE_KEY, resultCode);
            result.putBundle(RESULT_DATA_KEY, data);
            result.putString(ARG_SCENE_ID, getSceneId());
            getReactBridgeManager().sendEvent(ON_COMPONENT_RESULT_EVENT, Arguments.fromBundle(result));
        }
    }

    public Style getStyle() {
        return style;
    }

}
