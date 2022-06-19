package com.reactnative.hybridnavigation;

import androidx.annotation.NonNull;

import com.navigation.androidx.DrawerFragment;

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
