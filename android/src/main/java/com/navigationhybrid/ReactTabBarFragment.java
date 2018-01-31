package com.navigationhybrid;

import android.support.annotation.NonNull;

import com.navigationhybrid.androidnavigation.BottomBar;
import com.navigationhybrid.androidnavigation.TabBarFragment;

/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    @Override
    protected void onBottomBarInitialise(BottomBar bottomBar) {

        GlobalStyle globalStyle = Garden.getGlobalStyle();
        if (globalStyle.getBottomBarButtonItemTintColor() != null) {
            bottomBar.setActiveColor(globalStyle.getBottomBarButtonItemTintColor());
        }

        if (globalStyle.getBottomBarBackgroundColor() != null) {
            bottomBar.setBarBackgroundColor(globalStyle.getBottomBarBackgroundColor());
        }

        if (globalStyle.getBottomBarShadow() != null) {
            bottomBar.setShadow(globalStyle.getBottomBarShadow());
        }

    }

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

}
