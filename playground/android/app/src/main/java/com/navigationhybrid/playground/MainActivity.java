package com.navigationhybrid.playground;

import android.os.Bundle;

import com.navigationhybrid.ReactAppCompatActivity;
import com.navigationhybrid.ReactDrawerFragment;
import com.navigationhybrid.ReactNavigationFragment;
import com.navigationhybrid.ReactTabBarFragment;
import com.navigationhybrid.androidnavigation.AwesomeFragment;

public class MainActivity extends ReactAppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onCreateMainComponent() {

        ReactNavigationFragment reactNavigation = ReactNavigationFragment.newInstance("ReactNavigation");
        ReactNavigationFragment customStyle = ReactNavigationFragment.newInstance("CustomStyle");
        ReactTabBarFragment reactTabBarFragment = new ReactTabBarFragment();
        reactTabBarFragment.setFragments(reactNavigation, customStyle);

        ReactDrawerFragment drawerFragment = new ReactDrawerFragment();
        drawerFragment.setContentFragment(reactTabBarFragment);
        AwesomeFragment menuFragment = getReactBridgeManager().createFragment("Menu");
        drawerFragment.setMenuFragment(menuFragment);

        setRootFragment(drawerFragment);

    }

}
