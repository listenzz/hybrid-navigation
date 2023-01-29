package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_ITEM;
import static com.reactnative.hybridnavigation.Constants.ACTION_UPDATE_TAB_BAR;
import static com.reactnative.hybridnavigation.Constants.ARG_ACTION;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.Parameters.toBundle;
import static com.reactnative.hybridnavigation.Parameters.toList;

import android.app.Activity;
import android.content.res.Resources;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.FragmentManager;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.JavaOnlyMap;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.PixelUtil;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.TabBarFragment;

import java.util.HashMap;
import java.util.Map;

public class GardenModule extends ReactContextBaseJavaModule {

    private static final String TAG = "Navigation";
    private final ReactBridgeManager bridgeManager;

    public GardenModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
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
        constants.put("TOOLBAR_HEIGHT", 56);
        Resources resources = getReactApplicationContextIfActiveOrWarn().getResources();
        int resourceId = resources.getIdentifier("status_bar_height", "dimen", "android");
        float statusBarHeight = PixelUtil.toDIPFromPixel(resources.getDimensionPixelSize(resourceId));
        constants.put("STATUSBAR_HEIGHT", statusBarHeight);
        return constants;
    }

    @ReactMethod
    public void setStyle(final ReadableMap style) {
        UiThreadUtil.runOnUiThread(() -> {
            FLog.i(TAG, "GardenModule#setStyle");
            Garden.createGlobalStyle(toBundle(style));

            ReactAppCompatActivity activity = getActiveActivity();
            if (activity != null) {
                activity.inflateStyle();
            }
        });
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String sceneId, @Nullable final ReadableMap readableMap) {
        updateOptions(sceneId, readableMap, "leftBarButtonItem");
    }

    @ReactMethod
    public void setRightBarButtonItem(final String sceneId, @Nullable final ReadableMap readableMap) {
        updateOptions(sceneId, readableMap, "rightBarButtonItem");
    }

    @ReactMethod
    public void setLeftBarButtonItems(final String sceneId, @Nullable final ReadableArray readableArray) {
        updateOptions(sceneId, readableArray, "leftBarButtonItems");
    }

    @ReactMethod
    public void setRightBarButtonItems(final String sceneId, @Nullable final ReadableArray readableArray) {
        updateOptions(sceneId, readableArray, "rightBarButtonItems");
    }

    @ReactMethod
    public void setTitleItem(final String sceneId, final ReadableMap readableMap) {
        updateOptions(sceneId, readableMap, "titleItem");
    }

    @ReactMethod
    public void updateOptions(final String sceneId, final ReadableMap readableMap) {
        FLog.i(TAG, "update options:" + readableMap);
        UiThreadUtil.runOnUiThread(() -> {
            HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
            if (fragment != null) {
                fragment.getGarden().updateOptions(readableMap);
            }
        });
    }

    private void updateOptions(String sceneId, @Nullable ReadableMap readableMap, String key) {
        WritableMap writableMap = new JavaOnlyMap();
        if (readableMap == null) {
            writableMap.putNull(key);
        } else {
            writableMap.putMap(key, readableMap);
        }
        updateOptions(sceneId, writableMap);
    }

    private void updateOptions(String sceneId, @Nullable ReadableArray readableArray, String key) {
        WritableMap writableMap = new JavaOnlyMap();
        if (readableArray == null) {
            writableMap.putNull(key);
        } else {
            writableMap.putArray(key, readableArray);
        }
        updateOptions(sceneId, writableMap);
    }

    @ReactMethod
    public void updateTabBar(final String sceneId, final ReadableMap readableMap) {
        FLog.i(TAG, "updateTabBar:" + readableMap);
        UiThreadUtil.runOnUiThread(() -> {
            TabBarFragment tabBarFragment = getTabBarFragment(sceneId);
            if (tabBarFragment == null) {
                return;
            }

            Bundle bundle = new Bundle();
            bundle.putString(ARG_ACTION, ACTION_UPDATE_TAB_BAR);
            bundle.putBundle(ARG_OPTIONS, toBundle(readableMap));
            tabBarFragment.updateTabBar(bundle);
        });
    }

    @ReactMethod
    public void setTabItem(final String sceneId, @NonNull final ReadableArray options) {
        FLog.i(TAG, "setTabItem:" + options);
        UiThreadUtil.runOnUiThread(() -> {
            TabBarFragment tabBarFragment = getTabBarFragment(sceneId);
            if (tabBarFragment == null) {
                return;
            }

            Bundle bundle = new Bundle();
            bundle.putString(ARG_ACTION, ACTION_SET_TAB_ITEM);
            bundle.putSerializable(ARG_OPTIONS, toList(options));
            tabBarFragment.updateTabBar(bundle);
        });
    }

    @Nullable
    private TabBarFragment getTabBarFragment(String sceneId) {
        AwesomeFragment fragment = findFragmentBySceneId(sceneId);
        if (fragment != null) {
            return fragment.getTabBarFragment();
        }
        return null;
    }

    @ReactMethod
    public void setMenuInteractive(final String sceneId, final boolean enabled) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment == null) {
                return;
            }

            DrawerFragment drawerFragment = fragment.getDrawerFragment();
            if (drawerFragment == null) {
                return;
            }

            drawerFragment.setDrawerLockMode(enabled ? DrawerLayout.LOCK_MODE_UNLOCKED : DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
        });
    }

    private AwesomeFragment findFragmentBySceneId(String sceneId) {
        if (!bridgeManager.isViewHierarchyReady()) {
            FLog.w(TAG, "View hierarchy is not ready now.");
            return null;
        }

        ReactAppCompatActivity activity = getActiveActivity();
        if (activity == null) {
            return null;
        }

        FragmentManager fragmentManager = activity.getSupportFragmentManager();
        return FragmentHelper.findAwesomeFragment(fragmentManager, sceneId);
    }

    @Nullable
    private ReactAppCompatActivity getActiveActivity() {
        ReactContext reactContext = getReactApplicationContext();
        if (reactContext == null || !reactContext.hasActiveReactInstance()) {
            return null;
        }

        Activity activity = reactContext.getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            return (ReactAppCompatActivity) activity;
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
