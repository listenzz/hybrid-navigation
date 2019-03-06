package com.navigationhybrid;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;
import java.util.Map;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DrawerFragment;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.TabBarFragment;

import static com.navigationhybrid.Constants.ACTION_SET_BADGE_TEXT;
import static com.navigationhybrid.Constants.ACTION_SET_RED_POINT;
import static com.navigationhybrid.Constants.ACTION_SET_TAB_ICON;
import static com.navigationhybrid.Constants.ACTION_UPDATE_TAB_BAR;
import static com.navigationhybrid.Constants.ARG_ACTION;
import static com.navigationhybrid.Constants.ARG_BADGE_TEXT;
import static com.navigationhybrid.Constants.ARG_ICON;
import static com.navigationhybrid.Constants.ARG_ICON_SELECTED;
import static com.navigationhybrid.Constants.ARG_INDEX;
import static com.navigationhybrid.Constants.ARG_OPTIONS;
import static com.navigationhybrid.Constants.ARG_VISIBLE;
import static com.navigationhybrid.Constants.TOP_BAR_STYLE_DARK_CONTENT;
import static com.navigationhybrid.Constants.TOP_BAR_STYLE_LIGHT_CONTENT;

/**
 * Created by Listen on 2017/11/22.
 */

public class GardenModule extends ReactContextBaseJavaModule {

    private static final String TAG = "ReactNative";

    static Bundle mergeOptions(@NonNull Bundle options, @NonNull String key, @NonNull ReadableMap readableMap) {
        Bundle bundle = options.getBundle(key);
        if (bundle == null) {
            bundle = new Bundle();
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(bundle));
        writableMap.merge(readableMap);
        return Arguments.toBundle(writableMap);
    }

    public GardenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "GardenHybrid";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("DARK_CONTENT", TOP_BAR_STYLE_DARK_CONTENT);
        constants.put("LIGHT_CONTENT", TOP_BAR_STYLE_LIGHT_CONTENT);
        constants.put("TOOLBAR_HEIGHT", Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP ? 56 : 48);
        return constants;
    }

    @ReactMethod
    public void setStyle(final ReadableMap style) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Context context = getReactApplicationContext();
                if (context != null) {
                    Garden.createGlobalStyle(Arguments.toBundle(style));
                    ReactAppCompatActivity activity = (ReactAppCompatActivity) getCurrentActivity();
                    if (activity != null && !activity.isFinishing() && ReactBridgeManager.get().isReactModuleRegisterCompleted()) {
                        activity.inflateStyle();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setPassThroughTouches(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setPassThroughTouches:" + readableMap);
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("passThroughTouches")) {
                        boolean passThroughTouches = readableMap.getBoolean("passThroughTouches");
                        options.putBoolean("passThroughTouches", passThroughTouches);
                        fragment.getGarden().setPassThroughTouches(passThroughTouches);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String sceneId, final ReadableMap readableMap) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle buttonItem = mergeOptions(options, "leftBarButtonItem", readableMap);
                    options.putBundle("leftBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setLeftBarButtonItem(buttonItem);
                }
            }
        });
    }

    @ReactMethod
    public void setRightBarButtonItem(final String sceneId, final ReadableMap readableMap) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle buttonItem = mergeOptions(options, "rightBarButtonItem", readableMap);
                    options.putBundle("rightBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setRightBarButtonItem(buttonItem);
                }
            }
        });
    }

    @ReactMethod
    public void setTitleItem(final String sceneId, final ReadableMap readableMap) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle titleItem = mergeOptions(options, "titleItem", readableMap);
                    options.putBundle("titleItem", titleItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setTitleItem(titleItem);
                }
            }
        });
    }

    @ReactMethod
    public void setStatusBarColor(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setStatusBarColor:" + readableMap);
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    String statusBarColor = null;
                    if (readableMap.hasKey("statusBarColorAndroid")) {
                        statusBarColor = readableMap.getString("statusBarColorAndroid");
                    } else if (readableMap.hasKey("statusBarColor")) {
                        statusBarColor = readableMap.getString("statusBarColor");
                    }
                    if (statusBarColor != null) {
                        options.putString("statusBarColor", statusBarColor);
                        fragment.getGarden().setStatusBarColor(Color.parseColor(statusBarColor));
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setStatusBarHidden(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setStatusBarHidden:" + readableMap);
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("statusBarHidden")) {
                        boolean hidden = readableMap.getBoolean("statusBarHidden");
                        options.putBoolean("statusBarHidden", hidden);
                        fragment.getGarden().setStatusBarHidden(hidden);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void updateTopBar(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "updateTopBar:" + readableMap);
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    fragment.getGarden().updateToolbar(readableMap);
                }
            }
        });
    }

    @ReactMethod
    public void updateTabBar(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "updateTabBar:" + readableMap);
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString(ARG_ACTION, ACTION_UPDATE_TAB_BAR);
                        bundle.putBundle(ARG_OPTIONS, Arguments.toBundle(readableMap));
                        tabBarFragment.updateTabBar(bundle);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void replaceTabIcon(final String sceneId, final int index, final ReadableMap icon, final ReadableMap selectedIcon) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString(ARG_ACTION, ACTION_SET_TAB_ICON);
                        bundle.putInt(ARG_INDEX, index);
                        bundle.putBundle(ARG_ICON, Arguments.toBundle(icon));
                        bundle.putBundle(ARG_ICON_SELECTED, Arguments.toBundle(selectedIcon));
                        tabBarFragment.updateTabBar(bundle);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setTabBadgeText(final String sceneId, final int index, final String text) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString(ARG_ACTION, ACTION_SET_BADGE_TEXT);
                        bundle.putInt(ARG_INDEX, index);
                        bundle.putString(ARG_BADGE_TEXT, text);
                        tabBarFragment.updateTabBar(bundle);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void showRedPointAtIndex(final int index, final String sceneId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString(ARG_ACTION, ACTION_SET_RED_POINT);
                        bundle.putInt(ARG_INDEX, index);
                        bundle.putBoolean(ARG_VISIBLE, true);
                        tabBarFragment.updateTabBar(bundle);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void hideRedPointAtIndex(final int index, final String sceneId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString(ARG_ACTION, ACTION_SET_RED_POINT);
                        bundle.putInt(ARG_INDEX, index);
                        bundle.putBoolean(ARG_VISIBLE, false);
                        tabBarFragment.updateTabBar(bundle);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setMenuInteractive(final String sceneId, final boolean enabled) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
                if (awesomeFragment != null) {
                    DrawerFragment drawerFragment = awesomeFragment.getDrawerFragment();
                    if (drawerFragment != null) {
                        drawerFragment.setDrawerLockMode(enabled ? DrawerLayout.LOCK_MODE_UNLOCKED : DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
                    }
                }
            }
        });
    }

    private AwesomeFragment findFragmentBySceneId(String sceneId) {
        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactActivity.getSupportFragmentManager();
            return (AwesomeFragment) FragmentHelper.findDescendantFragment(fragmentManager, sceneId);
        }
        return null;
    }

    private HybridFragment findHybridFragmentBySceneId(String sceneId) {
        AwesomeFragment fragment = findFragmentBySceneId(sceneId);
        if (fragment instanceof HybridFragment) {
            return (HybridFragment) fragment;
        }
        return null;
    }

}
