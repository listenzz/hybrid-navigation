package com.reactnative.hybridnavigation;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.ReactContext;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.AwesomeToolbar;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.Style;
import com.navigation.androidx.TabBarItem;

import static com.reactnative.hybridnavigation.Constants.ARG_MODULE_NAME;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.Constants.ARG_PROPS;
import static com.reactnative.hybridnavigation.Constants.ARG_SCENE_ID;

/**
 * Created by Listen on 2018/1/15.
 */

public class HybridFragment extends AwesomeFragment {

    private static final String SAVED_OPTIONS = "hybrid_options";
    private static final String SAVED_PROPS = "hybrid_props";

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    private Garden garden;

    @NonNull
    public ReactNativeHost getReactNativeHost() {
        return bridgeManager.getReactNativeHost();
    }

    @NonNull
    public ReactInstanceManager getReactInstanceManager() {
        return bridgeManager.getReactInstanceManager();
    }

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Nullable
    public ReactContext getCurrentReactContext() {
        return bridgeManager.getCurrentReactContext();
    }

    public boolean isReactModuleRegisterCompleted() {
        return bridgeManager.isReactModuleRegisterCompleted();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            options = savedInstanceState.getBundle(SAVED_OPTIONS);
            props = savedInstanceState.getBundle(SAVED_PROPS);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        bridgeManager.watchMemory(this);
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
    protected boolean hideTabBarWhenPushed() {
        return garden.hidesBottomBarWhenPushed;
    }

    @Override
    protected AwesomeToolbar onCreateAwesomeToolbar(View parent) {
        if (garden.toolbarHidden) {
            return null;
        }
        return super.onCreateAwesomeToolbar(parent);
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

    @Override
    public void setArguments(@Nullable Bundle args) {
        super.setArguments(args);
        TabBarItem tabBarItem = getTabBarItem();
        if (tabBarItem == null && args != null) {
            Bundle options = args.getBundle(Constants.ARG_OPTIONS);
            if (options != null) {
                Bundle tabItem = options.getBundle("tabItem");
                if (tabItem != null) {
                    String title = tabItem.getString("title");
                    if (title != null) {
                        tabBarItem = new TabBarItem(title);
                        Bundle icon = tabItem.getBundle("icon");
                        if (icon != null) {
                            String uri = icon.getString("uri");
                            if (uri != null) {
                                tabBarItem = new TabBarItem(title, uri);
                                Bundle unselectedIcon = tabItem.getBundle("unselectedIcon");
                                if (unselectedIcon != null) {
                                    String unselectedUri = unselectedIcon.getString("uri");
                                    if (unselectedUri != null) {
                                        tabBarItem = new TabBarItem(title, uri, unselectedUri);
                                    }
                                }
                            }
                        }
                    }

                    if (tabBarItem != null) {
                        setTabBarItem(tabBarItem);
                    }
                }
            }
        }
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
