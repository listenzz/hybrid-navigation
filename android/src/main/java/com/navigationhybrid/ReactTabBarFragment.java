package com.navigationhybrid;

import android.support.annotation.NonNull;

import me.listenzz.navigation.TabBarFragment;


/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

}
