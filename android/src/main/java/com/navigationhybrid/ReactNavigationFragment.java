package com.navigationhybrid;

import android.support.annotation.NonNull;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.NavigationFragment;

/**
 * Created by Listen on 2018/1/15.
 */

public class ReactNavigationFragment extends NavigationFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }
    
    @Override
    public void setRootFragment(@NonNull AwesomeFragment fragment) {
        super.setRootFragment(fragment);
        if (fragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) fragment;
            setTabBarItem(hybridFragment.getTabBarItem());
        }
    }

}
