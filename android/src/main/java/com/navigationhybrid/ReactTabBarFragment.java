package com.navigationhybrid;

import android.os.Bundle;

import com.ashokvarma.bottomnavigation.BottomNavigationBar;
import com.navigationhybrid.androidnavigation.AwesomeFragment;
import com.navigationhybrid.androidnavigation.FragmentHelper;
import com.navigationhybrid.androidnavigation.TabBarFragment;
import com.navigationhybrid.androidnavigation.TabBarItem;

import java.util.List;

/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment{

    @Override
    public void setFragments(List<AwesomeFragment> fragments) {
        super.setFragments(fragments);
        for (AwesomeFragment fragment : fragments) {
            Bundle args = FragmentHelper.getArguments(fragment);
            Bundle options = args.getBundle(Constants.ARG_OPTIONS);
            if (options != null) {
                Bundle tabItem = options.getBundle("tabItem");
                if (tabItem != null) {
                    String title = tabItem.getString("title");
                    Bundle icon = tabItem.getBundle("icon");
                    boolean hideTabBarWhenPush = tabItem.getBoolean("hideTabBarWhenPush", true);
                    TabBarItem tabBarItem = new TabBarItem(icon, title, hideTabBarWhenPush);
                    fragment.setTabBarItem(tabBarItem);
                }
            }
        }
    }

    @Override
    protected void onBottomBarInitialise(BottomNavigationBar bottomNavigationBar) {

//        GlobalStyle globalStyle = Garden.getGlobalStyle();
//        bottomNavigationBar.setActiveColor(globalStyle.getTabItemSelectedColor());
//        bottomNavigationBar.setInActiveColor(globalStyle.getTabItemColor());
//        bottomNavigationBar.setBackgroundColor(globalStyle.getTabBarBackgroundColor());
    }
}
