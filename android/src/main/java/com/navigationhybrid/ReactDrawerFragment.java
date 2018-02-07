package com.navigationhybrid;

import android.support.annotation.NonNull;

import me.listenzz.navigation.DrawerFragment;

/**
 * Created by listen on 2018/1/16.
 */

public class ReactDrawerFragment extends DrawerFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    public @NonNull ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

}
