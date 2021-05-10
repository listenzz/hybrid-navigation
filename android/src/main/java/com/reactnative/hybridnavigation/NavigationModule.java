package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.TabBarFragment;
import com.reactnative.hybridnavigation.navigator.Navigator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * Created by Listen on 2017/11/20.
 */
public class NavigationModule extends ReactContextBaseJavaModule {

    static final String TAG = "ReactNative";
    static final Handler sHandler = new Handler(Looper.getMainLooper());

    private final ReactBridgeManager bridgeManager;

    NavigationModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
    }

    @NonNull
    @Override
    public String getName() {
        return "NavigationModule";
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        FLog.i(TAG, "NavigationModule#onCatalystInstanceDestroy");
        sHandler.removeCallbacksAndMessages(null);
        sHandler.post(() -> {
            List<ReactBridgeManager.ReactBridgeReloadListener> listeners = bridgeManager.getReactBridgeReloadListeners();
            for (ReactBridgeManager.ReactBridgeReloadListener listener : listeners) {
                listener.onReload();
            }
            listeners.clear();
            bridgeManager.setReactModuleRegisterCompleted(false);
            bridgeManager.setViewHierarchyReady(false);
            Activity activity = getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                reactAppCompatActivity.clearFragments();
            }
        });
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        HashMap<String, Object> constants = new HashMap<>();
        constants.put("RESULT_OK", Activity.RESULT_OK);
        constants.put("RESULT_CANCEL", Activity.RESULT_CANCELED);
        return constants;
    }

    @ReactMethod
    public void startRegisterReactComponent() {
        sHandler.post(bridgeManager::startRegisterReactModule);
    }

    @ReactMethod
    public void endRegisterReactComponent() {
        sHandler.post(bridgeManager::endRegisterReactModule);
    }

    @ReactMethod
    public void registerReactComponent(final String appKey, final ReadableMap options) {
        sHandler.post(() -> bridgeManager.registerReactModule(appKey, options));
    }

    @ReactMethod
    public void signalFirstRenderComplete(final String sceneId) {
        sHandler.post(() -> {
            AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
            if (awesomeFragment instanceof ReactFragment) {
                ReactFragment fragment = (ReactFragment) awesomeFragment;
                fragment.signalFirstRenderComplete();
            }
        });
    }

    @ReactMethod
    public void setRoot(final ReadableMap layout, final boolean sticky, final int tag) {
        sHandler.post(() -> {
            ReactContext reactContext = getReactApplicationContext();
            if (!reactContext.hasActiveCatalystInstance()) {
                FLog.w(TAG, "ReactContext has not active catalyst instance, skip action `setRoot`");
                return;
            }

            if (bridgeManager.getPendingTag() != 0) {
                throw new IllegalStateException("The previous `setRoot` has not been processed yet, you should `await Navigator.setRoot()` to complete.");
            }

            bridgeManager.setViewHierarchyReady(false);
            bridgeManager.setRootLayout(layout, sticky);
            Activity activity = getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity && bridgeManager.isReactModuleRegisterCompleted()) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                AwesomeFragment fragment = bridgeManager.createFragment(layout);
                if (fragment != null) {
                    FLog.i(TAG, "Have active activity and react module was registered, set root directly");
                    reactAppCompatActivity.setActivityRootFragment(fragment, tag);
                }
            } else {
                FLog.w(TAG, "Have no active activity or react module was not registered, schedule pending root");
                bridgeManager.setPendingLayout(layout, tag);
            }
        });
    }

    @ReactMethod
    public void dispatch(final String sceneId, final String action, final ReadableMap extras, Promise promise) {
        sHandler.post(() -> {
            AwesomeFragment target = findFragmentBySceneId(sceneId);
            if (target != null && target.isAdded()) {
                bridgeManager.handleNavigation(target, action, extras, promise);
            } else {
                promise.resolve(false);
                FLog.w(TAG, "Can't find target scene for action:" + action + ", maybe the scene is gone.\nextras: " + extras);
            }
        });
    }

    @ReactMethod
    public void currentTab(final String sceneId, final Promise promise) {
        sHandler.post(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                TabBarFragment tabs = fragment.getTabBarFragment();
                if (tabs != null) {
                    promise.resolve(tabs.getSelectedIndex());
                    return;
                }
            }
            promise.resolve(-1);
        });
    }

    @ReactMethod
    public void isNavigationRoot(final String sceneId, final Promise promise) {
        sHandler.post(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                promise.resolve(fragment.isNavigationRoot());
            }
        });
    }

    @ReactMethod
    public void setResult(final String sceneId, final int resultCode, final ReadableMap result) {
        sHandler.post(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                fragment.setResult(resultCode, Arguments.toBundle(result));
            }
        });

    }

    @ReactMethod
    public void findSceneIdByModuleName(@NonNull String moduleName, Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                ReactContext reactContext = getReactApplicationContext();
                if (!reactContext.hasActiveCatalystInstance()) {
                    FLog.w(TAG, "ReactContext has not active catalyst instance, skip action `currentRoute`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);

                if (fragment != null) {
                    if (fragment instanceof AwesomeFragment) {
                        String sceneId = findSceneIdByModuleName(moduleName, (AwesomeFragment) fragment);
                        FLog.i(TAG, "通过 " + moduleName + " 找到的 sceneId:" + sceneId);
                        promise.resolve(sceneId);
                    } else {
                        promise.resolve(null);
                    }
                } else {
                    sHandler.postDelayed(this, 16);
                }
            }
        };
        sHandler.post(task);
    }

    private String findSceneIdByModuleName(@NonNull String moduleName, AwesomeFragment fragment) {
        String sceneId = null;
        if (fragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) fragment;
            if (moduleName.equals(hybridFragment.getModuleName())) {
                sceneId = hybridFragment.getSceneId();
            }
        }

        if (sceneId == null) {
            List<AwesomeFragment> children = fragment.getChildFragments();
            int index = 0;
            int count = children.size();
            while (index < count && sceneId == null) {
                AwesomeFragment child = children.get(index);
                sceneId = findSceneIdByModuleName(moduleName, child);
                index++;
            }
        }

        return sceneId;
    }

    @ReactMethod
    public void currentRoute(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                ReactContext reactContext = getReactApplicationContext();
                if (!reactContext.hasActiveCatalystInstance()) {
                    FLog.w(TAG, "ReactContext has not active catalyst instance, skip action `currentRoute`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                HybridFragment current = bridgeManager.primaryFragment(fragmentManager);

                if (current != null) {
                    Bundle bundle = new Bundle();
                    bundle.putString("moduleName", current.getModuleName());
                    bundle.putString("sceneId", current.getSceneId());
                    bundle.putString("mode", Navigator.Util.getMode(current));
                    promise.resolve(Arguments.fromBundle(bundle));
                } else {
                    sHandler.postDelayed(this, 16);
                }
            }
        };

        sHandler.post(task);
    }

    @ReactMethod
    public void routeGraph(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                ReactContext reactContext = getReactApplicationContext();

                if (!reactContext.hasActiveCatalystInstance()) {
                    FLog.w(TAG, "ReactContext has not active catalyst instance, skip action `routeGraph`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                ArrayList<Bundle> graph = bridgeManager.buildRouteGraph(fragmentManager);
                if (graph.size() > 0) {
                    promise.resolve(Arguments.fromList(graph));
                } else {
                    sHandler.postDelayed(this, 16);
                }
            }
        };

        sHandler.post(task);
    }

    private AwesomeFragment findFragmentBySceneId(String sceneId) {
        ReactContext reactContext = getReactApplicationContext();
        if (!(bridgeManager.isViewHierarchyReady() && reactContext.hasActiveCatalystInstance())) {
            FLog.w(TAG, "View hierarchy is not ready now.");
            return null;
        }

        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
            return FragmentHelper.findAwesomeFragment(fragmentManager, sceneId);
        }
        return null;
    }
}
