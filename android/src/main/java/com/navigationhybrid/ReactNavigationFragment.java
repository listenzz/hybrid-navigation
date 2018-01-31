package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.navigationhybrid.androidnavigation.AwesomeFragment;
import com.navigationhybrid.androidnavigation.FragmentHelper;
import com.navigationhybrid.androidnavigation.NavigationFragment;
import com.navigationhybrid.androidnavigation.TabBarItem;

import static com.navigationhybrid.Constants.ARG_MODULE_NAME;
import static com.navigationhybrid.Constants.ARG_OPTIONS;
import static com.navigationhybrid.Constants.ARG_PROPS;

/**
 * Created by Listen on 2018/1/15.
 */

public class ReactNavigationFragment extends NavigationFragment {

    public static ReactNavigationFragment newInstance(@NonNull String moduleName) {
        return newInstance(moduleName, null, null);
    }

    public static ReactNavigationFragment newInstance(@NonNull String moduleName, Bundle props, Bundle options) {
        ReactNavigationFragment navigationFragment = new ReactNavigationFragment();
        Bundle args = FragmentHelper.getArguments(navigationFragment);
        args.putString(ARG_MODULE_NAME, moduleName);
        args.putBundle(ARG_PROPS, props);
        args.putBundle(ARG_OPTIONS, options);

        ReactBridgeManager reactBridgeManager = ReactBridgeManager.instance;
        Bundle tabItem = reactBridgeManager.optionsByModuleName(moduleName).getBundle("tabItem");
        if (tabItem != null) {
            String title = tabItem.getString("title");
            Bundle icon = tabItem.getBundle("icon");
            String uri = null;
            if (icon != null) {
                uri = icon.getString("uri");
            }
            boolean hideTabBarWhenPush = tabItem.getBoolean("hideTabBarWhenPush", true);
            TabBarItem tabBarItem = new TabBarItem(uri, title, hideTabBarWhenPush);
            navigationFragment.setTabBarItem(tabBarItem);
        }

        return navigationFragment;
    }

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        if (savedInstanceState == null) {
            Bundle args = FragmentHelper.getArguments(this);
            String rootModuleName = args.getString(ARG_MODULE_NAME);
            Bundle rootModuleProps = args.getBundle(ARG_PROPS);
            Bundle rootModuleOptions = args.getBundle(ARG_OPTIONS);

            if (rootModuleName == null) {
                throw new IllegalArgumentException("出错了，找不着 rootModuleName, 你是否没有正确初始化？");
            }

            AwesomeFragment awesomeFragment = getReactBridgeManager().createFragment(rootModuleName, rootModuleProps, rootModuleOptions);
            setRootFragment(awesomeFragment);
        }
    }

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }
}
