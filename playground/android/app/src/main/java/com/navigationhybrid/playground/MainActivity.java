package com.navigationhybrid.playground;

import android.os.Bundle;

import com.navigationhybrid.ReactAppCompatActivity;
import com.navigationhybrid.ReactDrawerFragment;
import com.navigationhybrid.ReactNavigationFragment;
import com.navigationhybrid.ReactTabBarFragment;

import me.listenzz.navigation.AwesomeFragment;


public class MainActivity extends ReactAppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onCreateMainComponent() {

        AwesomeFragment react = getReactBridgeManager().createFragment("ReactNavigation");
        ReactNavigationFragment reactNavigation = new ReactNavigationFragment();
        reactNavigation.setRootFragment(react);

        AwesomeFragment custom = getReactBridgeManager().createFragment("CustomStyle");
        ReactNavigationFragment customNavigation = new ReactNavigationFragment();
        customNavigation.setRootFragment(custom);

        ReactTabBarFragment reactTabBarFragment = new ReactTabBarFragment();
        reactTabBarFragment.setFragments(reactNavigation, customNavigation);

        ReactDrawerFragment drawerFragment = new ReactDrawerFragment();
        drawerFragment.setContentFragment(reactTabBarFragment);
        AwesomeFragment menuFragment = getReactBridgeManager().createFragment("Menu");
        drawerFragment.setMenuFragment(menuFragment);

        setRootFragment(drawerFragment);

    }

}
