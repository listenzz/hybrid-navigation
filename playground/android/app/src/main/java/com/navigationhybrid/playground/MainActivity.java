package com.navigationhybrid.playground;

import android.os.Bundle;

import com.navigationhybrid.ReactAppCompatActivity;
import com.navigationhybrid.ReactDrawerFragment;
import com.navigationhybrid.ReactFragmentHelper;
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

        // FIXME 不能在这里传递 options
        ReactNavigationFragment reactNavigation = ReactNavigationFragment.newInstance("ReactNavigation", null, ReactFragmentHelper.optionsByModuleName("ReactNavigation"));
        ReactNavigationFragment customStyle = ReactNavigationFragment.newInstance("CustomStyle", null, ReactFragmentHelper.optionsByModuleName("CustomStyle"));
        ReactTabBarFragment reactTabBarFragment = new ReactTabBarFragment();
        reactTabBarFragment.setFragments(reactNavigation, customStyle);

        ReactDrawerFragment drawerFragment = new ReactDrawerFragment();
        drawerFragment.setContentFragment(reactTabBarFragment);
        AwesomeFragment menuFragment = ReactFragmentHelper.createFragment("Menu", null, null);
        drawerFragment.setMenuFragment(menuFragment);

        setRootFragment(drawerFragment);

    }

}
