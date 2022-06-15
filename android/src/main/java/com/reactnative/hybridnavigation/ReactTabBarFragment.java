package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.HBDEventEmitter.EVENT_NAVIGATION;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_INDEX;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_ON;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_REQUEST_CODE;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_RESULT_CODE;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_RESULT_DATA;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_SCENE_ID;
import static com.reactnative.hybridnavigation.HBDEventEmitter.ON_COMPONENT_RESULT;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.Style;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TabBarProvider;
import com.navigation.androidx.TransitionAnimation;

import java.util.List;


/**
 * Created by listen on 2018/1/15.
 */

public class ReactTabBarFragment extends TabBarFragment {

    private static final String SAVED_OPTIONS = "hybrid_options";

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            options = savedInstanceState.getBundle(SAVED_OPTIONS);
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
    }

    private final static TransitionAnimation FadeShort = new TransitionAnimation(R.anim.nav_fade_in_short, R.anim.nav_fade_out_short, R.anim.nav_fade_in_short, R.anim.nav_fade_out_short);
    private final static TransitionAnimation DelayShort = new TransitionAnimation(R.anim.nav_delay_short, R.anim.nav_delay_short, R.anim.nav_delay_short, R.anim.nav_delay_short);

    @Override
    protected void setPresentAnimation(AwesomeFragment current, AwesomeFragment previous) {
        if (shouldImproveTransitionForReact(current)) {
            improveTransitionForReact(current, previous);
            return;
        }
        super.setPresentAnimation(current, previous);
    }

    private boolean shouldImproveTransitionForReact(AwesomeFragment current) {
        ReactFragment reactFragment = Utils.findReactFragment(current);
        return reactFragment != null && !reactFragment.isFirstRenderCompleted();
    }

    private void improveTransitionForReact(AwesomeFragment current, AwesomeFragment previous) {
        List<AwesomeFragment> children = getChildAwesomeFragments();
        if (children.indexOf(current) > children.indexOf(previous)) {
            current.setAnimation(FadeShort);
            previous.setAnimation(DelayShort);
        } else {
            current.setAnimation(TransitionAnimation.None);
            previous.setAnimation(FadeShort);
        }
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        super.onCustomStyle(style);
        Bundle options = getOptions();
        String tabBarColor = options.getString("tabBarColor");
        if (tabBarColor != null) {
            style.setTabBarBackgroundColor(tabBarColor);
        }

        String tabBarItemColor = options.getString("tabBarItemColor");
        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");

        if (tabBarItemColor != null) {
            style.setTabBarItemColor(tabBarItemColor);
            style.setTabBarUnselectedItemColor(tabBarUnselectedItemColor);
        } else {
            options.putString("tabBarItemColor", style.getTabBarItemColor());
            options.putString("tabBarUnselectedItemColor", style.getTabBarUnselectedItemColor());
            options.putString("tabBarBadgeColor", style.getTabBarBadgeColor());
        }

        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        if (shadowImage != null) {
            style.setTabBarShadow(Utils.createTabBarShadow(requireContext(), shadowImage));
        }
    }

    @Override
    protected TabBarProvider createDefaultTabBarProvider() {
        Bundle options = getOptions();
        if (options.getString("tabBarModuleName") != null) {
            return new ReactTabBarProvider();
        }
        return new ReactDefaultTabBarProvider();
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

    public void setIntercepted(boolean intercepted) {
        this.intercepted = intercepted;
    }

    private boolean intercepted = true;

    @Override
    public void setSelectedIndex(int index, @NonNull Runnable completion) {
        if (shouldIntercept()) {
            sendSwitchTabEvent(index);
            // restore tab bar selected index
            setTabBarSelectedIndex(getSelectedIndex());
            return;
        }

        super.setSelectedIndex(index, completion);
        intercepted = true;
    }

    private boolean shouldIntercept() {
        return isAdded() && bridgeManager.hasRootLayout() && this.intercepted;
    }
    
    private void sendSwitchTabEvent(int index) {
        Bundle data = new Bundle();
        data.putString(KEY_SCENE_ID, getSceneId());
        data.putString(KEY_INDEX, getSelectedIndex() + "-" + index);
        HBDEventEmitter.sendEvent(HBDEventEmitter.EVENT_SWITCH_TAB, Arguments.fromBundle(data));
    }

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        sendResult(requestCode, resultCode, data);
    }

    private void sendResult(int requestCode, int resultCode, Bundle data) {
        Bundle options = getOptions();
        String tabBarModuleName = options.getString("tabBarModuleName");
        if (tabBarModuleName == null) {
            return;
        }
        Bundle result = new Bundle();
        result.putInt(KEY_REQUEST_CODE, requestCode);
        result.putInt(KEY_RESULT_CODE, resultCode);
        result.putBundle(KEY_RESULT_DATA, data);
        result.putString(KEY_SCENE_ID, getSceneId());
        result.putString(KEY_ON, ON_COMPONENT_RESULT);
        HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(result));
    }

    public Style getStyle() {
        return mStyle;
    }
    
}
