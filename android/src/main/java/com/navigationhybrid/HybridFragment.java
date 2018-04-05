package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.AwesomeToolbar;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.Style;

import static com.navigationhybrid.Constants.ARG_PROPS;
import static com.navigationhybrid.Constants.ARG_SCENE_ID;

/**
 * Created by Listen on 2018/1/15.
 */

public class HybridFragment extends AwesomeFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    private Garden garden;

    @Override
    protected void onCustomStyle(Style style) {
        super.onCustomStyle(style);
        garden = new Garden(this, style);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        garden.configureToolbar();
    }

    public Garden getGarden() {
        return garden;
    }

    @Override
    protected boolean shouldHideBackButton() {
        return garden.backButtonHidden;
    }

    @Override
    protected boolean backInteractive() {
        return garden.backInteractive;
    }

    @Override
    protected boolean hidesBottomBarWhenPushed() {
        return garden.hidesBottomBarWhenPushed;
    }

    @Override
    protected AwesomeToolbar onCreateAwesomeToolbar(View parent) {
        if (garden.toolbarHidden) {
            return null;
        }
        return super.onCreateAwesomeToolbar(parent);
    }

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    public Bundle getOptions() {
        Bundle args = FragmentHelper.getArguments(this);
        return args.getBundle(Constants.ARG_OPTIONS);
    }

    public void setOptions(Bundle options) {
        Bundle args = getArguments();
        if (args != null) {
            args.putBundle(Constants.ARG_OPTIONS, options);
            setArguments(args);
        }
    }

    public Bundle getProps() {
        Bundle args = FragmentHelper.getArguments(this);
        Bundle initialProps = args.getBundle(ARG_PROPS);
        if (initialProps == null) {
            initialProps = new Bundle();
        }
        initialProps.putString(ARG_SCENE_ID, getSceneId());
        return initialProps;
    }

}
