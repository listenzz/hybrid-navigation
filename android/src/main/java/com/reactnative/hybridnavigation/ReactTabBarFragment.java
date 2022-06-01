package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_ITEM;
import static com.reactnative.hybridnavigation.Constants.ACTION_UPDATE_TAB_BAR;
import static com.reactnative.hybridnavigation.Constants.ARG_ACTION;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.HBDEventEmitter.EVENT_NAVIGATION;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_INDEX;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_ON;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_REQUEST_CODE;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_RESULT_CODE;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_RESULT_DATA;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_SCENE_ID;
import static com.reactnative.hybridnavigation.HBDEventEmitter.ON_COMPONENT_RESULT;
import static com.reactnative.hybridnavigation.Parameters.mergeOptions;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DefaultTabBarProvider;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.Style;
import com.navigation.androidx.TabBar;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TabBarItem;
import com.navigation.androidx.TabBarProvider;
import com.navigation.androidx.TransitionAnimation;

import java.util.ArrayList;
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
    public void setSelectedIndex(int index, @Nullable Runnable completion) {
        if (shouldIntercept()) {
            sendSwitchTabEvent(index);
            restoreTabBarState();
            return;
        }

        super.setSelectedIndex(index, completion);
        intercepted = true;
    }

    private boolean shouldIntercept() {
        return isAdded() && bridgeManager.hasRootLayout() && this.intercepted;
    }

    private void restoreTabBarState() {
        TabBarProvider tabBarProvider = getTabBarProvider();
        if (tabBarProvider == null) {
            return;
        }
        tabBarProvider.setSelectedIndex(getSelectedIndex());
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


    @Override
    public void updateTabBar(Bundle options) {
        super.updateTabBar(options);
        if (getTabBarProvider() instanceof DefaultTabBarProvider) {
            updateDefaultTabBar(options);
        }
    }

    private void updateDefaultTabBar(Bundle options) {
        String action = options.getString(ARG_ACTION);
        if (action == null) {
            return;
        }

        switch (action) {
            case ACTION_SET_TAB_ITEM:
                setTabItem(options.getParcelableArrayList(ARG_OPTIONS));
                break;
            case ACTION_UPDATE_TAB_BAR:
                updateTabBarStyle(options.getBundle(ARG_OPTIONS));
                break;
        }
    }

    private void setTabItem(@Nullable ArrayList<Bundle> options) {
        if (options == null) {
            return;
        }

        TabBar tabBar = getTabBar();
        if (tabBar == null) {
            return;
        }

        for (Bundle option : options) {
            int index = (int) option.getDouble("index");
            TabBarItem tabBarItem = tabBar.getTabBarItem(index);
            if (tabBarItem == null) {
                continue;
            }

            setTabItemTitle(option, tabBarItem);
            setTabItemIcon(option, tabBarItem);
            setTabItemBadge(option, tabBarItem);
            tabBar.renderTabView(index);
        }
    }

    private void setTabItemBadge(Bundle option, TabBarItem tabBarItem) {
        Bundle badge = option.getBundle("badge");
        if (badge == null) {
            return;
        }

        boolean hidden = badge.getBoolean("hidden", true);
        String text = !hidden ? badge.getString("text", "") : "";
        boolean dot = !hidden && badge.getBoolean("dot", false);

        tabBarItem.badgeText = text;
        tabBarItem.showDotBadge = dot;
    }

    private void setTabItemIcon(Bundle option, TabBarItem tabBarItem) {
        Bundle icon = option.getBundle("icon");
        if (icon == null) {
            return;
        }
        
        Bundle selected = icon.getBundle("selected");
        tabBarItem.iconUri = selected.getString("uri");

        Bundle unselected = icon.getBundle("unselected");
        if (unselected == null) {
            return;
        }
        tabBarItem.unselectedIconUri = unselected.getString("uri");
    }

    private void setTabItemTitle(Bundle option, TabBarItem tabBarItem) {
        String title = option.getString("title");
        if (title == null) {
            return;
        }
        tabBarItem.title = title;
    }

    private void updateTabBarStyle(@Nullable Bundle options) {
        if (options == null) {
            return;
        }
        setOptions(mergeOptions(getOptions(), options));

        TabBar tabBar = getTabBar();
        if (tabBar == null) {
            return;
        }

        String tabBarColor = options.getString("tabBarColor");
        Bundle shadowImage = options.getBundle("tabBarShadowImage");
        String tabBarItemColor = options.getString("tabBarItemColor");
        String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");

        if (tabBarColor != null) {
            mStyle.setTabBarBackgroundColor(tabBarColor);
            tabBar.setBarBackgroundColor(tabBarColor);
            setNeedsNavigationBarAppearanceUpdate();
        }

        if (shadowImage != null) {
            tabBar.setShadowDrawable(Utils.createTabBarShadow(requireContext(), shadowImage));
        }

        if (tabBarItemColor != null) {
            tabBar.setSelectedItemColor(tabBarItemColor);
        }

        if (tabBarUnselectedItemColor != null) {
            tabBar.setUnselectedItemColor(tabBarUnselectedItemColor);
        }

        tabBar.initialise(tabBar.getCurrentSelectedPosition());
    }

}
