package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;

import com.facebook.react.bridge.Arguments;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.NavigationFragment;

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
    public void setRootFragment(@NonNull AwesomeFragment fragment) {
        super.setRootFragment(fragment);
        if (fragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) fragment;
            setTabBarItem(hybridFragment.getTabBarItem());
        }
    }

    @Override
    public void popFragment() {
        if (!getReactBridgeManager().isReactModuleInRegistry()) {
            AwesomeFragment fragment = getTopFragment();
            if (fragment instanceof ReactFragment) {
                Bundle bundle = new Bundle();
                bundle.putString(Constants.ARG_SCENE_ID, fragment.getSceneId());
                getReactBridgeManager().sendEvent(Constants.ON_COMPONENT_BACK, Arguments.fromBundle(bundle));
            }
        }
        super.popFragment();
    }
}
