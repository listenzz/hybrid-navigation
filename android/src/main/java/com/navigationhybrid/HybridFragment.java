package com.navigationhybrid;

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
import static com.navigationhybrid.Constants.ARG_PROPS;
import static com.navigationhybrid.Constants.ARG_SCENE_ID;

/**
 * Created by Listen on 2018/1/15.
 */

public class HybridFragment extends AwesomeFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    private Garden garden;

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

    @NonNull
    public Bundle getOptions() {
        Bundle args = FragmentHelper.getArguments(this);
        Bundle bundle = args.getBundle(Constants.ARG_OPTIONS);
        if (bundle == null) {
            bundle = new Bundle();
        }
        return bundle;
    }

    public void setOptions(@NonNull Bundle options) {
        Bundle args = getArguments();
        if (args != null) {
            args.putBundle(Constants.ARG_OPTIONS, options);
            setArguments(args);
        }
    }

    @NonNull
    public Bundle getProps() {
        Bundle args = FragmentHelper.getArguments(this);
        Bundle initialProps = args.getBundle(ARG_PROPS);
        if (initialProps == null) {
            initialProps = new Bundle();
        }
        initialProps.putString(ARG_SCENE_ID, getSceneId());
        return initialProps;
    }

    @CallSuper
    public void setAppProperties(@NonNull Bundle props) {
        Bundle args = FragmentHelper.getArguments(this);
        args.putBundle(Constants.ARG_PROPS, props);
    }

    public String getModuleName() {
        Bundle args = FragmentHelper.getArguments(this);
        return args.getString(ARG_MODULE_NAME);
    }

}
