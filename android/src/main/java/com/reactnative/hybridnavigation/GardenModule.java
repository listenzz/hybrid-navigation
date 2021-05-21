package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.TabBarFragment;

import java.util.HashMap;
import java.util.Map;

import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_BADGE;
import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_ICON;
import static com.reactnative.hybridnavigation.Constants.ACTION_UPDATE_TAB_BAR;
import static com.reactnative.hybridnavigation.Constants.ARG_ACTION;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;

/**
 * Created by Listen on 2017/11/22.
 */

public class GardenModule extends ReactContextBaseJavaModule implements LifecycleEventListener, LifecycleOwner {

    private static final String TAG = "Navigation";

    static final Handler sHandler = NavigationModule.sHandler;
    private final UiTaskExecutor uiTaskExecutor;
    private final LifecycleRegistry lifecycleRegistry;
    private final ReactApplicationContext reactContext;
    private final ReactBridgeManager bridgeManager;

    public GardenModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
        lifecycleRegistry = new LifecycleRegistry(this);
        lifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
        uiTaskExecutor = new UiTaskExecutor(this, sHandler);
        FLog.i(TAG, "GardenModule#onCreate");
    }

    @Override
    public void onHostResume() {
        FLog.i(TAG, "GardenModule#onHostResume");
        lifecycleRegistry.setCurrentState(Lifecycle.State.STARTED);
    }

    @Override
    public void onHostPause() {
        FLog.i(TAG, "GardenModule#onHostPause");
        lifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
    }

    @Override
    public void onHostDestroy() {
        FLog.i(TAG, "GardenModule#onHostDestroy");
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        FLog.i(TAG, "GardenModule#onCatalystInstanceDestroy");
        lifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
        reactContext.removeLifecycleEventListener(this);
    }

    @NonNull
    @Override
    public String getName() {
        return "GardenModule";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("TOOLBAR_HEIGHT", Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP ? 56 : 48);
        return constants;
    }

    @ReactMethod
    public void setStyle(final ReadableMap style) {
        sHandler.post(() -> {
            FLog.i(TAG, "GardenModule#setStyle");
            Garden.createGlobalStyle(Arguments.toBundle(style));

            ReactContext context = getReactApplicationContext();
            if (context.hasActiveCatalystInstance()) {
                ReactAppCompatActivity activity = (ReactAppCompatActivity) getCurrentActivity();
                if (activity != null) {
                    activity.inflateStyle();
                }
            }
        });
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String sceneId, @Nullable final ReadableMap readableMap) {
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
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
        FLog.i(TAG, "update options:" + readableMap);
        uiTaskExecutor.submit(() -> {
            HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
            if (fragment != null && fragment.getView() != null) {
                fragment.getGarden().updateOptions(readableMap);
            }
        });
    }

    @ReactMethod
    public void updateTabBar(final String sceneId, final ReadableMap readableMap) {
        FLog.i(TAG, "updateTabBar:" + readableMap);
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
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
        ReactContext reactContext = getReactApplicationContext();
        if (!(bridgeManager.isViewHierarchyReady() && reactContext.hasActiveCatalystInstance())) {
            FLog.w(TAG, "View hierarchy is not ready now.");
            return null;
        }

        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactActivity.getSupportFragmentManager();
            return FragmentHelper.findAwesomeFragment(fragmentManager, sceneId);
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
