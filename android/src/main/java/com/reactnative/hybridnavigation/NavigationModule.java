package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
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
public class NavigationModule extends ReactContextBaseJavaModule implements LifecycleEventListener, LifecycleOwner {

    static final String TAG = "Navigator";
    static final Handler sHandler = new Handler(Looper.getMainLooper());

    private final ReactBridgeManager bridgeManager;
    private final ReactApplicationContext reactContext;
    private final UiTaskExecutor uiTaskExecutor;
    private final LifecycleRegistry lifecycleRegistry;

    NavigationModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
        lifecycleRegistry = new LifecycleRegistry(this);
        lifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
        uiTaskExecutor = new UiTaskExecutor(this, sHandler);
        FLog.i(TAG, "NavigationModule#onCreate");
    }

    @Override
    public void onHostResume() {
        FLog.i(TAG, "NavigationModule#onHostResume");
        lifecycleRegistry.setCurrentState(Lifecycle.State.STARTED);
    }

    @Override
    public void onHostPause() {
        FLog.i(TAG, "NavigationModule#onHostPause");
        lifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
    }

    @Override
    public void onHostDestroy() {
        FLog.i(TAG, "NavigationModule#onHostDestroy");
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        lifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
        reactContext.removeLifecycleEventListener(this);

        FLog.i(TAG, "NavigationModule#onCatalystInstanceDestroy");
        sHandler.removeCallbacksAndMessages(null);
        sHandler.post(() -> {
            List<ReactBridgeManager.ReactBridgeReloadListener> listeners = bridgeManager.getReactBridgeReloadListeners();
            for (ReactBridgeManager.ReactBridgeReloadListener listener : listeners) {
                listener.onReload();
            }
            listeners.clear();
            bridgeManager.setPendingLayout(null, 0);
            bridgeManager.setReactModuleRegisterCompleted(false);
            bridgeManager.setViewHierarchyReady(false);
            Activity activity = getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                reactAppCompatActivity.clearFragments();
            }
        });
    }

    @NonNull
    @Override
    public String getName() {
        return "NavigationModule";
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
        uiTaskExecutor.submit(() -> {
            AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
            if (awesomeFragment instanceof ReactFragment) {
                ReactFragment fragment = (ReactFragment) awesomeFragment;
                fragment.signalFirstRenderComplete();
            }
        });
    }

    @ReactMethod
    public void setRoot(final ReadableMap layout, final boolean sticky, final int tag) {
        uiTaskExecutor.submit(() -> {
            ReactContext reactContext = getReactApplicationContext();
            if (!reactContext.hasActiveCatalystInstance()) {
                FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `setRoot`");
                return;
            }

            if (bridgeManager.getPendingTag() != 0) {
                FLog.e(TAG, "The previous tag: " + bridgeManager.getPendingTag() + " layout: " + bridgeManager.getPendingLayout());
                FLog.e(TAG, "Current tag: " + tag + " layout: " + layout);
                throw new IllegalStateException("The previous `setRoot` hasn't been processed yet, you should `await Navigator.setRoot()` to complete.");
            }

            bridgeManager.setViewHierarchyReady(false);
            bridgeManager.setRootLayout(layout, sticky);
            bridgeManager.setPendingLayout(layout, tag);

            Activity activity = getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity && bridgeManager.isReactModuleRegisterCompleted()) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                AwesomeFragment fragment = bridgeManager.createFragment(layout);
                if (fragment != null) {
                    FLog.i(TAG, "Have active Activity and React module was registered, set root Fragment immediately.");
                    reactAppCompatActivity.setActivityRootFragment(fragment, tag);
                }
            }
        });
    }

    @ReactMethod
    public void dispatch(final String sceneId, final String action, final ReadableMap extras, Promise promise) {
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
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
        uiTaskExecutor.submit(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                promise.resolve(fragment.isNavigationRoot());
            }
        });
    }

    @ReactMethod
    public void setResult(final String sceneId, final int resultCode, final ReadableMap result) {
        uiTaskExecutor.submit(() -> {
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
                    FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `currentRoute`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(() -> uiTaskExecutor.submit(this), 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);
                if (fragment instanceof AwesomeFragment) {
                    String sceneId = findSceneIdByModuleName(moduleName, (AwesomeFragment) fragment);
                    FLog.i(TAG, "The sceneId found by " + moduleName + " : " + sceneId);
                    promise.resolve(sceneId);
                } else {
                    promise.resolve(null);
                }
            }
        };
        uiTaskExecutor.submit(task);
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
                    FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `currentRoute`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(() -> uiTaskExecutor.submit(this), 16);
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
                    sHandler.postDelayed(() -> uiTaskExecutor.submit(this), 16);
                }
            }
        };

        uiTaskExecutor.submit(task);
    }

    @ReactMethod
    public void routeGraph(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                ReactContext reactContext = getReactApplicationContext();

                if (!reactContext.hasActiveCatalystInstance()) {
                    FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `routeGraph`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(() -> uiTaskExecutor.submit(this), 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                ArrayList<Bundle> graph = bridgeManager.buildRouteGraph(fragmentManager);
                if (graph.size() > 0) {
                    promise.resolve(Arguments.fromList(graph));
                } else {
                    sHandler.postDelayed(() -> uiTaskExecutor.submit(this), 16);
                }
            }
        };

        uiTaskExecutor.submit(task);
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
