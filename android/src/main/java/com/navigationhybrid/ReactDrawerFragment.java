package com.navigationhybrid;


import androidx.annotation.NonNull;

import com.navigation.androidx.DrawerFragment;

/**
 * Created by listen on 2018/1/16.
 */

public class ReactDrawerFragment extends DrawerFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        bridgeManager.watchMemory(this);
    }
}
