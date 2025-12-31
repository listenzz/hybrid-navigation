package com.reactnative.hybridnavigation;

import com.navigation.androidx.DrawerFragment;

public class ReactDrawerFragment extends DrawerFragment {

    private final ReactManager reactManager = ReactManager.get();

    @Override
    public void onDestroy() {
        super.onDestroy();
        reactManager.watchMemory(this);
    }
}
