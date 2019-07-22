package com.navigationhybrid;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

import java.util.HashMap;
import java.util.Map;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DrawerFragment;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.TabBarFragment;

import static com.navigationhybrid.Constants.ACTION_SET_TAB_BADGE;
import static com.navigationhybrid.Constants.ACTION_SET_TAB_ICON;
import static com.navigationhybrid.Constants.ACTION_UPDATE_TAB_BAR;
import static com.navigationhybrid.Constants.ARG_ACTION;
import static com.navigationhybrid.Constants.ARG_OPTIONS;
import static com.navigationhybrid.Constants.TOP_BAR_STYLE_DARK_CONTENT;
import static com.navigationhybrid.Constants.TOP_BAR_STYLE_LIGHT_CONTENT;

/**
 * Created by Listen on 2017/11/22.
 */

public class GardenModule extends ReactContextBaseJavaModule {

    private static final String TAG = "ReactNative";



    static final Handler sHandler = NavigationModule.sHandler;

    private final ReactBridgeManager bridgeManager;

    public GardenModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
    }

    @NonNull
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
        sHandler.post(() -> {
            Context context = bridgeManager.getCurrentReactContext();
            if (context != null) {
                Garden.createGlobalStyle(Arguments.toBundle(style));
                ReactAppCompatActivity activity = (ReactAppCompatActivity) getCurrentActivity();
                if (activity != null && !activity.isFinishing() && ReactBridgeManager.get().isReactModuleRegisterCompleted()) {
                    activity.inflateStyle();
                }
            }
        });
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String sceneId, @Nullable final ReadableMap readableMap) {
        sHandler.post(() -> {
            HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
            if (fragment != null && fragment.getView() != null) {
                Bundle options = fragment.getOptions();
                if (readableMap != null) {
                    Bundle buttonItem = Utils.mergeOptions(options, "leftBarButtonItem", readableMap);
                    options.putBundle("leftBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setLeftBarButtonItem(buttonItem);
                } else {
                    options.putBundle("leftBarButtonItem", null);
                    fragment.setOptions(options);
                    fragment.getGarden().setLeftBarButtonItem(null);
                }
            }
        });
    }

    @ReactMethod
    public void setRightBarButtonItem(final String sceneId, @Nullable final ReadableMap readableMap) {
        sHandler.post(() -> {
            HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
            if (fragment != null && fragment.getView() != null) {
                Bundle options = fragment.getOptions();
                if (readableMap != null) {
                    Bundle buttonItem = Utils.mergeOptions(options, "rightBarButtonItem", readableMap);
                    options.putBundle("rightBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setRightBarButtonItem(buttonItem);
                } else {
                    options.putBundle("rightBarButtonItem", null);
                    fragment.setOptions(options);
                    fragment.getGarden().setRightBarButtonItem(null);
                }
            }
        });
    }

    @ReactMethod
    public void setTitleItem(final String sceneId, final ReadableMap readableMap) {
        sHandler.post(() -> {
            HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
            if (fragment != null && fragment.getView() != null) {
                Bundle options = fragment.getOptions();
                Bundle titleItem = Utils.mergeOptions(options, "titleItem", readableMap);
                options.putBundle("titleItem", titleItem);
                fragment.setOptions(options);
                fragment.getGarden().setTitleItem(titleItem);
            }
        });
    }

    @ReactMethod
    public void updateOptions(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "update options:" + readableMap);
        sHandler.post(() -> {
            HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
            if (fragment != null && fragment.getView() != null) {
                fragment.getGarden().updateOptions(readableMap);
            }
        });
    }

    @ReactMethod
    public void updateTabBar(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "updateTabBar:" + readableMap);
        sHandler.post(() -> {
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
        });
    }

    @ReactMethod
    public void setTabIcon(@NonNull final String sceneId, @NonNull final ReadableArray options) {
        sHandler.post(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null && fragment.getView() != null) {
                TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                if (tabBarFragment != null) {
                    Bundle bundle = new Bundle();
                    bundle.putString(ARG_ACTION, ACTION_SET_TAB_ICON);
                    bundle.putParcelableArrayList(ARG_OPTIONS, Arguments.toList(options));
                    tabBarFragment.updateTabBar(bundle);
                }
            }
        });
    }

    @ReactMethod
    public void setTabBadge(@NonNull final String sceneId, @NonNull final ReadableArray options) {
        sHandler.post(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                if (tabBarFragment != null) {
                    Bundle bundle = new Bundle();
                    bundle.putString(ARG_ACTION, ACTION_SET_TAB_BADGE);
                    bundle.putParcelableArrayList(ARG_OPTIONS, Arguments.toList(options));
                    tabBarFragment.updateTabBar(bundle);
                }
            }
        });
    }

    @ReactMethod
    public void setMenuInteractive(final String sceneId, final boolean enabled) {
        sHandler.post(() -> {
            AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
            if (awesomeFragment != null) {
                DrawerFragment drawerFragment = awesomeFragment.getDrawerFragment();
                if (drawerFragment != null) {
                    drawerFragment.setDrawerLockMode(enabled ? DrawerLayout.LOCK_MODE_UNLOCKED : DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
                }
            }
        });
    }

    private AwesomeFragment findFragmentBySceneId(String sceneId) {
        if (!bridgeManager.isViewHierarchyReady() || bridgeManager.getCurrentReactContext() == null) {
            Log.w(TAG, "View hierarchy is not ready now.");
            return null;
        }

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
