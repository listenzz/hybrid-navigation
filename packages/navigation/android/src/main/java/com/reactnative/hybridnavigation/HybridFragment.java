package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ARG_MODULE_NAME;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.Constants.ARG_PROPS;
import static com.reactnative.hybridnavigation.Constants.ARG_SCENE_ID;

import android.graphics.Color;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import com.navigation.androidx.AppUtils;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.AwesomeToolbar;
import com.navigation.androidx.BarStyle;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.PresentableActivity;
import com.navigation.androidx.PresentationStyle;
import com.navigation.androidx.Style;
import com.navigation.androidx.SystemUI;
import com.navigation.androidx.TabBarItem;

public class HybridFragment extends AwesomeFragment {

    private static final String SAVED_OPTIONS = "hybrid_options";
    private static final String SAVED_PROPS = "hybrid_props";

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    private Garden garden;

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    public boolean isReactModuleRegisterCompleted() {
        return bridgeManager.isReactModuleRegisterCompleted();
    }

    protected final ReactInstanceManager getReactInstanceManager() {
        return bridgeManager.getReactInstanceManager();
    }

    protected final ReactContext getCurrentReactContext() {
        return bridgeManager.getCurrentReactContext();
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
        if (getPresentationStyle() == PresentationStyle.OverFullScreen) {
            setBackgroundForModal(style);
        }
    }

    private void setBackgroundForModal(@NonNull Style style) {
        if (forceTransparentDialogWindow()) {
            style.setScreenBackgroundColor(Color.TRANSPARENT);
            return;
        }
        int color = mStyle.getScreenBackgroundColor();
        if (Color.alpha(color) == 255) {
            style.setScreenBackgroundColor(Color.parseColor("#77000000"));
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        garden.setupToolbar();
    }
    
    @NonNull
    @Override
    protected BarStyle preferredStatusBarStyle() {
        if (forceTransparentDialogWindow()) {
            return SystemUI.activityStatusBarStyle(requireActivity());
        }

        if (getPresentationStyle() == PresentationStyle.OverFullScreen) {
            return SystemUI.activityStatusBarStyle(requireActivity());
        }

        return super.preferredStatusBarStyle();
    }

    @Override
    protected boolean preferredStatusBarHidden() {
        if (forceTransparentDialogWindow()) {
            return SystemUI.isStatusBarHidden(requireActivity().getWindow());
        }

        if (getPresentationStyle() == PresentationStyle.OverFullScreen) {
            return SystemUI.isStatusBarHidden(requireActivity().getWindow());
        }

        return super.preferredStatusBarHidden();
    }

    @Override
    protected boolean preferredNavigationBarHidden() {
        if (getPresentationStyle() == PresentationStyle.OverFullScreen) {
            return SystemUI.isNavigationBarHidden(requireActivity().getWindow());
        }
        return super.preferredNavigationBarHidden();
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
    protected boolean shouldFitsNavigationBar() {
        if (preferredNavigationBarHidden()) {
            return false;
        }

        if (!preferredEdgeToEdge()) {
            return false;
        }

        if (shouldFitsTabBar()) {
            return true;
        }

        return mStyle.shouldFitsOpaqueNavigationBar() && AppUtils.isOpaque(preferredNavigationBarColor());
    }

    protected boolean shouldPassThroughTouches() {
        Bundle options = getOptions();
        return options.getBoolean("passThroughTouches");
    }

    protected boolean shouldAnimatedTransition() {
        Bundle options = getOptions();
        return options.getBoolean("animatedTransition", true);
    }

    protected boolean forceScreenLandscape() {
        Bundle options = getOptions();
        return options.getBoolean("forceScreenLandscape", false);
    }

    protected boolean forceTransparentDialogWindow() {
        return garden.forceTransparentDialogWindow;
    }

    @Override
    protected AwesomeToolbar onCreateToolbar(View parent) {
        if (garden.toolbarHidden) {
            return null;
        }
        return super.onCreateToolbar(parent);
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
        setTabBarItemIfNeeded(args);
    }

    private void setTabBarItemIfNeeded(@Nullable Bundle args) {
        if (args == null) {
            return;
        }

        TabBarItem tabBarItem = getTabBarItem();
        if (tabBarItem != null) {
            return;
        }

        Bundle options = args.getBundle(Constants.ARG_OPTIONS);
        if (options == null) {
            return;
        }

        Bundle tabItem = options.getBundle("tabItem");
        if (tabItem == null) {
            return;
        }

        String title = tabItem.getString("title");
        if (title == null) {
            return;
        }

        Bundle icon = tabItem.getBundle("icon");
        if (icon == null) {
            setTabBarItem(new TabBarItem(title));
            return;
        }

        String uri = icon.getString("uri");
        if (uri == null) {
            setTabBarItem(new TabBarItem(title));
            return;
        }

        Bundle unselectedIcon = tabItem.getBundle("unselectedIcon");
        if (unselectedIcon == null) {
            setTabBarItem(new TabBarItem(title, uri));
            return;
        }

        String unselectedUri = unselectedIcon.getString("uri");
        if (unselectedUri == null) {
            setTabBarItem(new TabBarItem(title, uri));
            return;
        }

        setTabBarItem(new TabBarItem(title, uri, unselectedUri));
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
            setArguments(args);
        }
    }

    public String getModuleName() {
        Bundle args = FragmentHelper.getArguments(this);
        return args.getString(ARG_MODULE_NAME);
    }
    
    public String getPresentingSceneId() {
        Bundle args = FragmentHelper.getArguments(this);
        return args.getString(PresentableActivity.ARG_PRESENTING_SCENE_ID);
    }
    
}
