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

import com.facebook.react.bridge.ReactContext;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.BarStyle;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.PresentableActivity;
import com.navigation.androidx.PresentationStyle;
import com.navigation.androidx.Style;
import com.navigation.androidx.SystemUI;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TabBarItem;

public class HybridFragment extends AwesomeFragment {

    private static final String SAVED_OPTIONS = "hybrid_options";
    private static final String SAVED_PROPS = "hybrid_props";

    private final ReactManager reactManager = ReactManager.get();

    private Garden garden;

    @NonNull
    public ReactManager getReactManager() {
        return reactManager;
    }

    public boolean isReactModuleRegisterCompleted() {
        return reactManager.isReactModuleRegisterCompleted();
    }

    protected final ReactContext getCurrentReactContext() {
        return reactManager.getCurrentReactContext();
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
        reactManager.watchMemory(this);
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
        int color = mStyle.getScreenBackgroundColor();
        if (Color.alpha(color) == 255) {
            style.setScreenBackgroundColor(Color.parseColor("#77000000"));
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @NonNull
    @Override
    protected BarStyle preferredStatusBarStyle() {
        if (getPresentationStyle() == PresentationStyle.OverFullScreen) {
            return SystemUI.activityStatusBarStyle(requireActivity());
        }

        return super.preferredStatusBarStyle();
    }

    @Override
    protected boolean preferredStatusBarHidden() {
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
        return false;
    }

    @Override
    protected boolean isBackInteractive() {
        return garden.backInteractive;
    }

    protected boolean shouldAnimatedTransition() {
		if (forceScreenLandscape()) {
			return false;
		}
        Bundle options = getOptions();
        return options.getBoolean("animatedTransition", true);
    }

    protected boolean forceScreenLandscape() {
        Bundle options = getOptions();
        return options.getBoolean("forceScreenLandscape", false);
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
            injectTabBarInset(props);
        }
        return props;
    }

    private void injectTabBarInset(@NonNull Bundle props) {
        TabBarFragment tabBarFragment = getTabBarFragment();
        if (tabBarFragment != null) {
            float tabBarHeightDp = getResources().getDimension(R.dimen.nav_tab_bar_height)
                    / getResources().getDisplayMetrics().density;
            props.putDouble("tabBarInset", tabBarHeightDp);
        }
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
