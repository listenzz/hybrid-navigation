package com.navigationhybrid;

import androidx.annotation.NonNull;

import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.NavigationFragment;

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

    @Override
    public void onDestroy() {
        super.onDestroy();
        bridgeManager.watchMemory(this);
    }

}
