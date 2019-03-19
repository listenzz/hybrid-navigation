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
import me.listenzz.navigation.TabBarItem;

import static com.navigationhybrid.Constants.ACTION_SET_BADGE_TEXT;
import static com.navigationhybrid.Constants.ACTION_SET_RED_POINT;
import static com.navigationhybrid.Constants.ACTION_SET_TAB_ICON;
import static com.navigationhybrid.Constants.ACTION_UPDATE_TAB_BAR;
import static com.navigationhybrid.Constants.ARG_ACTION;
import static com.navigationhybrid.Constants.ARG_BADGE_TEXT;
import static com.navigationhybrid.Constants.ARG_ICON;
import static com.navigationhybrid.Constants.ARG_ICON_SELECTED;
import static com.navigationhybrid.Constants.ARG_INDEX;
import static com.navigationhybrid.Constants.ARG_OPTIONS;
import static com.navigationhybrid.Constants.ARG_VISIBLE;
import static com.navigationhybrid.HBDEventEmitter.EVENT_NAVIGATION;
import static com.navigationhybrid.HBDEventEmitter.KEY_INDEX;
import static com.navigationhybrid.HBDEventEmitter.KEY_MODULE_NAME;
import static com.navigationhybrid.HBDEventEmitter.KEY_ON;
import static com.navigationhybrid.HBDEventEmitter.KEY_REQUEST_CODE;
import static com.navigationhybrid.HBDEventEmitter.KEY_RESULT_CODE;
import static com.navigationhybrid.HBDEventEmitter.KEY_RESULT_DATA;
import static com.navigationhybrid.HBDEventEmitter.KEY_SCENE_ID;
import static com.navigationhybrid.HBDEventEmitter.ON_COMPONENT_RESULT;


/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment {

    private static final String SAVED_OPTIONS = "hybrid_options";

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            options = savedInstanceState.getBundle(SAVED_OPTIONS);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        bridgeManager.watchMemory(this);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBundle(SAVED_OPTIONS, options);
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

        if (tabBarUnselectedItemColor != null) {
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
    public void updateTabBar(Bundle options) {
        super.updateTabBar(options);
        if (getTabBarProvider() instanceof DefaultTabBarProvider) {
            String action = options.getString(ARG_ACTION);
            if (action == null) {
                return;
            }

            switch (action) {
                case ACTION_SET_BADGE_TEXT:
                    setBadge(options.getInt(ARG_INDEX), options.getString(ARG_BADGE_TEXT));
                    break;
                case ACTION_SET_RED_POINT:
                    setRedPoint(options.getInt(ARG_INDEX), options.getBoolean(ARG_VISIBLE));
                    break;
                case ACTION_SET_TAB_ICON:
                    setTabIcon(options.getInt(ARG_INDEX), options.getBundle(ARG_ICON), options.getBundle(ARG_ICON_SELECTED));
                    break;
                case ACTION_UPDATE_TAB_BAR:
                    updateTabBarAppearance(options.getBundle(ARG_OPTIONS));
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
            fragment.setTabBarItem(newTabBarItem(fragment, icon.getString("uri"), selectedIcon.getString("uri")));
            tabBar.setTabIcon(index, selectedDrawable, drawable);
        } else {
            fragment.setTabBarItem(newTabBarItem(fragment, icon.getString("uri"), null));
            tabBar.setTabIcon(index, drawable, null);
        }
    }

    private TabBarItem newTabBarItem(@NonNull AwesomeFragment fragment, @Nullable String icon, @Nullable String selectedIcon) {
        TabBarItem tabBarItem = fragment.getTabBarItem();
        if (tabBarItem == null) {
            throw new IllegalArgumentException("the fragment must have a tabBarItem");
        }
        return new TabBarItem(icon, selectedIcon, tabBarItem.title);
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

    private Bundle options;

    @NonNull
    public Bundle getOptions() {
        if (options == null) {
            Bundle args = FragmentHelper.getArguments(this);
            options = args.getBundle(ARG_OPTIONS);
            if (options == null) {
                options = new Bundle();
            }
        }
        return options;
    }

    public void setOptions(@NonNull Bundle options) {
        this.options = options;
    }

    public void setIntercepted(boolean intercepted) {
        this.intercepted = intercepted;
    }

    private boolean intercepted = true;

    @Override
    protected void restoreSelectedIndex(int index) {
        super.setSelectedIndex(index);
    }

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
        data.putString(KEY_SCENE_ID, selectedReactFragment.getSceneId());
        if (reactFragment != null) {
            data.putString(KEY_MODULE_NAME, reactFragment.getModuleName());
        }
        data.putInt(KEY_INDEX, index);
        HBDEventEmitter.sendEvent(HBDEventEmitter.EVENT_SWITCH_TAB, Arguments.fromBundle(data));
    }

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        Bundle options = getOptions();
        String tabBarModuleName = options.getString("tabBarModuleName");
        if (tabBarModuleName != null) {
            Bundle result = new Bundle();
            result.putInt(KEY_REQUEST_CODE, requestCode);
            result.putInt(KEY_RESULT_CODE, resultCode);
            result.putBundle(KEY_RESULT_DATA, data);
            result.putString(KEY_SCENE_ID, getSceneId());
            result.putString(KEY_ON, ON_COMPONENT_RESULT);
            HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(result));
        }
    }

    public Style getStyle() {
        return style;
    }

}
