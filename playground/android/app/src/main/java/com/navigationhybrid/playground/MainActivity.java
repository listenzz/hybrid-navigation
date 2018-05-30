package com.navigationhybrid.playground;

import android.os.Bundle;

import com.navigationhybrid.ReactAppCompatActivity;
import com.navigationhybrid.ReactNavigationFragment;

import me.listenzz.navigation.AwesomeFragment;


public class MainActivity extends ReactAppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onCreateMainComponent() {

        AwesomeFragment react = getReactBridgeManager().createFragment("Navigation");
        ReactNavigationFragment reactNavigation = new ReactNavigationFragment();
        reactNavigation.setRootFragment(react);
//
//        AwesomeFragment custom = getReactBridgeManager().createFragment("Options");
//        ReactNavigationFragment customNavigation = new ReactNavigationFragment();
//        customNavigation.setRootFragment(custom);
//
//        ReactTabBarFragment reactTabBarFragment = new ReactTabBarFragment();
//        reactTabBarFragment.setChildFragments(reactNavigation, customNavigation);
//
//        ReactDrawerFragment drawerFragment = new ReactDrawerFragment();
//
//        drawerFragment.setContentFragment(reactTabBarFragment);
//        AwesomeFragment menuFragment = getReactBridgeManager().createFragment("Menu");
//        drawerFragment.setMenuFragment(menuFragment);
//        drawerFragment.setMaxDrawerWidth(280);

        CustomContainerFragment root = new CustomContainerFragment();

        root.setBackgroundFragment(reactNavigation);
        root.setContainerFragment(getReactBridgeManager().createFragment("Transparent"));
        setActivityRootFragment(root);

    }

}
