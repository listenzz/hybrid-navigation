package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.TabBarItem;

/**
 * Created by Listen on 2018/1/15.
 */

public class ReactNavigationFragment extends NavigationFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Override
    public void setRootFragment(AwesomeFragment fragment) {
        super.setRootFragment(fragment);
        if (fragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) fragment;
            Bundle options = hybridFragment.getOptions();
            Bundle tabItem = options.getBundle("tabItem");
            if (tabItem != null) {
                String title = tabItem.getString("title");
                Bundle icon = tabItem.getBundle("icon");
                String uri = null;
                if (icon != null) {
                    uri = icon.getString("uri");
                }
                TabBarItem tabBarItem = new TabBarItem(uri, title);
                setTabBarItem(tabBarItem);
            }
        }
    }
}
