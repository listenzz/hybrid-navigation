package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.os.Bundle;

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
import com.facebook.react.bridge.UiThreadUtil;
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

    static final String TAG = "Navigator";
    private final ReactBridgeManager bridgeManager;
    
    NavigationModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
        FLog.i(TAG, "NavigationModule#onCreate");
    }
    
    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        FLog.i(TAG, "NavigationModule#onCatalystInstanceDestroy");
        UiThreadUtil.runOnUiThread(() -> {
            List<ReactBridgeManager.ReactBridgeReloadListener> listeners = bridgeManager.getReactBridgeReloadListeners();
            for (ReactBridgeManager.ReactBridgeReloadListener listener : listeners) {
                listener.onReload();
            }
            listeners.clear();
            bridgeManager.setPendingLayout(null, 0);
            bridgeManager.setReactModuleRegisterCompleted(false);
            bridgeManager.setViewHierarchyReady(false);
            
            ReactContext reactContext = getReactApplicationContextIfActiveOrWarn();
            if (reactContext != null) {
                Activity activity = reactContext.getCurrentActivity();
                if (activity instanceof ReactAppCompatActivity) {
                    ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                    reactAppCompatActivity.clearFragments();
                }
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
        UiThreadUtil.runOnUiThread(bridgeManager::startRegisterReactModule);
    }

    @ReactMethod
    public void endRegisterReactComponent() {
        UiThreadUtil.runOnUiThread(bridgeManager::endRegisterReactModule);
    }

    @ReactMethod
    public void registerReactComponent(final String appKey, final ReadableMap options) {
        UiThreadUtil.runOnUiThread(() -> bridgeManager.registerReactModule(appKey, options));
    }

    @ReactMethod
    public void signalFirstRenderComplete(final String sceneId) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
            if (awesomeFragment instanceof ReactFragment) {
                ReactFragment fragment = (ReactFragment) awesomeFragment;
                fragment.signalFirstRenderComplete();
            }
        });
    }

    @ReactMethod
    public void setRoot(final ReadableMap layout, final boolean sticky, final int tag) {
        UiThreadUtil.runOnUiThread(() -> {
            ReactContext reactContext = getReactApplicationContextIfActiveOrWarn();
            if (reactContext == null) {
                FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `setRoot`");
                return;
            }

            bridgeManager.setViewHierarchyReady(false);
            bridgeManager.setRootLayout(layout, sticky);
            bridgeManager.setPendingLayout(layout, tag);
            
            Activity activity = reactContext.getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity && bridgeManager.isReactModuleRegisterCompleted()) {
                ReactAppCompatActivity reactActivity = (ReactAppCompatActivity) activity;
                AwesomeFragment fragment = bridgeManager.createFragment(layout);
                if (fragment != null) {
                    FLog.i(TAG, "Have active Activity and React module was registered, set root Fragment immediately.");
                    reactActivity.setActivityRootFragment(fragment, tag);
                }
            }
        });
    }

    @ReactMethod
    public void dispatch(final String sceneId, final String action, final ReadableMap extras, Promise promise) {
        UiThreadUtil.runOnUiThread(() -> {
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
        UiThreadUtil.runOnUiThread(() -> {
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
    public void isStackRoot(final String sceneId, final Promise promise) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                promise.resolve(fragment.isStackRoot());
            }
        });
    }

    @ReactMethod
    public void setResult(final String sceneId, final int resultCode, final ReadableMap result) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeFragment fragment = findFragmentBySceneId(sceneId);
            if (fragment != null) {
                fragment.setResult(resultCode, Arguments.toBundle(result));
            }
        });
    }

    @ReactMethod
    public void findSceneIdByModuleName(@NonNull String moduleName, Promise promise) {
       final Runnable task = new Runnable() {
            @Override
            public void run() {
                ReactContext reactContext = getReactApplicationContextIfActiveOrWarn();
                if (reactContext == null) {
                    return;
                }

                Activity activity = reactContext.getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    UiThreadUtil.runOnUiThread(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                reactAppCompatActivity.scheduleTaskAtStarted(() -> {
                    FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                    Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);
                    if (fragment instanceof AwesomeFragment) {
                        String sceneId = findSceneIdByModuleName(moduleName, (AwesomeFragment) fragment);
                        FLog.i(TAG, "The sceneId found by " + moduleName + " : " + sceneId);
                        promise.resolve(sceneId);
                    } else {
                        promise.resolve(null);
                    }
                });
            }
        };
       
        UiThreadUtil.runOnUiThread(task);
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
                ReactContext reactContext = getReactApplicationContextIfActiveOrWarn();
                if (reactContext == null) {
                    return;
                }

                Activity activity = reactContext.getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    UiThreadUtil.runOnUiThread(this, 16);
                    return;
                }
                
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                reactAppCompatActivity.scheduleTaskAtStarted(() -> {
                    FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                    HybridFragment current = bridgeManager.primaryFragment(fragmentManager);

                    if (current != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString("moduleName", current.getModuleName());
                        bundle.putString("sceneId", current.getSceneId());
                        bundle.putString("mode", Navigator.Util.getMode(current));
                        promise.resolve(Arguments.fromBundle(bundle));
                    } else {
                        UiThreadUtil.runOnUiThread(this, 16);
                    }
                });
            }
        };

        UiThreadUtil.runOnUiThread(task);
    }

    @ReactMethod
    public void routeGraph(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                ReactContext reactContext = getReactApplicationContextIfActiveOrWarn();
                if (reactContext == null) {
                    return;
                }

                Activity activity = reactContext.getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    UiThreadUtil.runOnUiThread(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                reactAppCompatActivity.scheduleTaskAtStarted(() -> {
                    FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                    ArrayList<Bundle> graph = bridgeManager.buildRouteGraph(fragmentManager);
                    if (graph.size() > 0) {
                        promise.resolve(Arguments.fromList(graph));
                    } else {
                        UiThreadUtil.runOnUiThread(this, 16);
                    }
                });
            }
        };

        UiThreadUtil.runOnUiThread(task);
    }

    private AwesomeFragment findFragmentBySceneId(String sceneId) {
        ReactContext reactContext = getReactApplicationContextIfActiveOrWarn();
        if (reactContext == null) {
            return null;
        }
        
        if (!bridgeManager.isViewHierarchyReady()) {
            FLog.w(TAG, "View hierarchy is not ready now.");
            return null;
        }

        Activity activity = reactContext.getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
            return FragmentHelper.findAwesomeFragment(fragmentManager, sceneId);
        }
        return null;
    }
}
