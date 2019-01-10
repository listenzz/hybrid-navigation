package com.navigationhybrid;

import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.CallSuper;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.AwesomeToolbar;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.Style;

import static com.navigationhybrid.Constants.ARG_MODULE_NAME;
import static com.navigationhybrid.Constants.ARG_OPTIONS;
import static com.navigationhybrid.Constants.ARG_PROPS;
import static com.navigationhybrid.Constants.ARG_SCENE_ID;

/**
 * Created by Listen on 2018/1/15.
 */

public class HybridFragment extends AwesomeFragment {

    private static final String SAVED_OPTIONS = "hybrid_options";
    private static final String SAVED_PROPS = "hybrid_props";

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    private Garden garden;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            options = savedInstanceState.getBundle(SAVED_OPTIONS);
            props = savedInstanceState.getBundle(SAVED_PROPS);
        }
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBundle(SAVED_OPTIONS, options);
        outState.putBundle(SAVED_PROPS, props);
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
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
    protected boolean isBackInteractive() {
        return garden.backInteractive;
    }

    @Override
    protected boolean isSwipeBackEnabled() {
        return garden.swipeBackEnabled;
    }

    @Override
    protected boolean hidesBottomBarWhenPushed() {
        return garden.hidesBottomBarWhenPushed;
    }

    @Override
    protected int preferredStatusBarColor() {
        if (garden.toolbarHidden && super.preferredStatusBarColor() == preferredToolbarColor()) {
            return Color.TRANSPARENT;
        }
        return super.preferredStatusBarColor();
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

    private Bundle options;

    @NonNull
    public Bundle getOptions() {
        if (options == null) {
            Bundle args = FragmentHelper.getArguments(this);
            options = args.getBundle(ARG_OPTIONS);
            if (options == null) {
                options = new Bundle();
            }
        }
        return options;
    }

    public void setOptions(@NonNull Bundle options) {
        this.options = options;
    }

    private Bundle props;

    @NonNull
    public Bundle getProps() {
        if (props == null) {
            Bundle args = FragmentHelper.getArguments(this);
            props = args.getBundle(ARG_PROPS);
            if (props == null) {
                props = new Bundle();
            }
            props.putString(ARG_SCENE_ID, getSceneId());
        }
        return props;
    }

    @CallSuper
    public void setAppProperties(@NonNull Bundle props) {
        if (isAdded()) {
            props.putString(ARG_SCENE_ID, getSceneId());
            this.props = props;
        } else {
            Bundle args = FragmentHelper.getArguments(this);
            args.putBundle(ARG_PROPS, props);
        }
    }

    public String getModuleName() {
        Bundle args = FragmentHelper.getArguments(this);
        return args.getString(ARG_MODULE_NAME);
    }

}
