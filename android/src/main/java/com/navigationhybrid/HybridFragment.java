package com.navigationhybrid;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.navigationhybrid.androidnavigation.AwesomeFragment;
import com.navigationhybrid.androidnavigation.FragmentHelper;
import com.navigationhybrid.androidnavigation.NavigationFragment;

import static com.navigationhybrid.ReactBridgeManager.REACT_MODULE_REGISTRY_COMPLETED_BROADCAST;

/**
 * Created by Listen on 2018/1/15.
 */

public class HybridFragment extends AwesomeFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    private Garden garden;

    private BroadcastReceiver styleUpdatedReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            updateStyle(garden);
        }
    };


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 为什么要放这里初始化呢？
        garden = new Garden(this);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (getContext() != null) {
            IntentFilter intentFilter = new IntentFilter(REACT_MODULE_REGISTRY_COMPLETED_BROADCAST);
            LocalBroadcastManager.getInstance(getContext()).registerReceiver(styleUpdatedReceiver, intentFilter);
        }

        updateStyle(garden);
    }

    @Override
    public void onDestroyView() {
        if (getContext() != null) {
            LocalBroadcastManager.getInstance(getContext()).unregisterReceiver(styleUpdatedReceiver);
        } else {
            Log.e(TAG, toString() + " context is null!!");
        }
        super.onDestroyView();
        Log.d(TAG, toString() + "#onDestroyView");
    }

    @Override
    protected boolean shouldHideBackButton() {
        return garden.hideBackButton;
    }

    @Override
    public boolean hidesBottomBarWhenPushed() {
        Bundle options = getOptions();
        Bundle tabItem = options.getBundle("tabItem");
        return tabItem == null || tabItem.getBoolean("hideTabBarWhenPush");
    }

    @Override
    protected String preferredStatusBarStyle() {
        return garden.statusBarStyle();
    }

    @Override
    protected int preferredStatusBarColor() {
        return garden.statusBarColor();
    }

    @Override
    protected int preferredBackgroundColor() {
        return garden.backgroundColor();
    }

    public Garden getGarden() {
        return garden;
    }

    protected boolean isRoot() {
        NavigationFragment navigationFragment = getNavigationFragment();
        if (navigationFragment != null) {
            AwesomeFragment awesomeFragment = navigationFragment.getRootFragment();
            return awesomeFragment == this;
        }
        return true;
    }

    protected void updateStyle(Garden garden) {
        garden.setTopBarStyle();
    }

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    protected Bundle getOptions() {
        Bundle args = FragmentHelper.getArguments(this);
        return args.getBundle(Constants.ARG_OPTIONS);
    }

    protected void setOptions(Bundle options) {
        Bundle args = getArguments();
        if (args != null) {
            args.putBundle(Constants.ARG_OPTIONS, options);
            setArguments(args);
        }
    }

}
