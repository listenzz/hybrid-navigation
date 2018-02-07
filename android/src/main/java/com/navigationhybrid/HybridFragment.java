package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;

/**
 * Created by Listen on 2018/1/15.
 */

public class HybridFragment extends AwesomeFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    private Garden garden;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 为什么要放这里初始化呢？因为创建 view 时就需要用到 garden 中的值了
        garden = new Garden(this);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        garden.configTopBar();
    }

    @Override
    protected boolean shouldHideBackButton() {
        return garden.hideBackButton;
    }

    @Override
    protected boolean hidesBottomBarWhenPushed() {
        return garden.hidesBottomBarWhenPushed;
    }

    public Garden getGarden() {
        return garden;
    }

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
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
