package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.navigation.androidx.AwesomeActivity;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.TabBarFragment;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NavigationModule extends ReactContextBaseJavaModule {

    static final String TAG = "Navigation";
    private final ReactBridgeManager bridgeManager;

    NavigationModule(ReactApplicationContext reactContext, ReactBridgeManager bridgeManager) {
        super(reactContext);
        this.bridgeManager = bridgeManager;
        FLog.i(TAG, "NavigationModule#onCreate");
    }

    @Override
    public void invalidate() {
        FLog.i(TAG, "NavigationModule#invalidate");
        UiThreadUtil.runOnUiThread(() -> {
            bridgeManager.invalidate();
            clearFragments();
        });
    }

    private void clearFragments() {
        AwesomeActivity activity = getActiveActivity();
        if (activity != null) {
            activity.clearFragments();
        }
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
            AwesomeActivity activity = getActiveActivity();
            if (activity == null) {
                return;
            }
            
            activity.scheduleTaskAtStarted(() -> {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment instanceof ReactFragment) {
                    ReactFragment reactFragment = (ReactFragment) fragment;
                    reactFragment.signalFirstRenderComplete();
                }
            });
        });
    }

    @ReactMethod
    public void setRoot(final ReadableMap layout, final boolean sticky, final Callback callback) {
        UiThreadUtil.runOnUiThread(() -> {
            ReactContext reactContext = getReactApplicationContext();
            if (reactContext == null || !reactContext.hasActiveCatalystInstance()) {
                FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `setRoot`");
                return;
            }

            if (bridgeManager.getPendingCallback() != null) {
                bridgeManager.getPendingCallback().invoke(null, false);
            }

            bridgeManager.setViewHierarchyReady(false);
            bridgeManager.setRootLayout(layout, sticky);
            bridgeManager.setPendingLayout(layout, callback);

            if (!bridgeManager.isReactModuleRegisterCompleted()) {
                return;
            }

            ReactAppCompatActivity activity = getActiveActivity();
            if (activity != null && !activity.getSupportFragmentManager().isStateSaved()) {
                FLog.i(TAG, "Have active Activity and React module was registered, set root Fragment immediately.");
                activity.setActivityRootFragment(layout);
            }
        });
    }

    @ReactMethod
    public void dispatch(final String sceneId, final String action, final ReadableMap extras, Callback callback) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeActivity activity = getActiveActivity();
            if (activity == null) {
                callback.invoke(null, false);
                return;
            }

            activity.scheduleTaskAtStarted(() -> {
                AwesomeFragment target = findFragmentBySceneId(sceneId);
                if (target == null) {
                    callback.invoke(null, false);
                    FLog.w(TAG, "Can't find target scene for action:" + action + ", maybe the scene is gone.\nextras: " + extras);
                    return;
                }

                if (!target.isAdded() || FragmentHelper.isRemoving(target)) {
                    callback.invoke(null, false);
                    return;
                }

                bridgeManager.handleNavigation(target, action, extras, callback);
            });
        });
    }

    @ReactMethod
    public void currentTab(final String sceneId, final Callback callback) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeActivity activity = getActiveActivity();
            if (activity == null) {
                callback.invoke(null, -1);
                return;
            }
            
            activity.scheduleTaskAtStarted(() -> {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment == null) {
                    callback.invoke(null, -1);
                    return;
                }

                TabBarFragment tabs = fragment.getTabBarFragment();
                if (tabs == null) {
                    callback.invoke(null, -1);
                    return;
                }

                callback.invoke(null, tabs.getSelectedIndex());
            });
        });
    }

    @ReactMethod
    public void isStackRoot(final String sceneId, final Callback callback) {
        UiThreadUtil.runOnUiThread(() -> {
            AwesomeActivity activity = getActiveActivity();
            if (activity == null) {
                callback.invoke(null, -1);
                return;
            }
            
            activity.scheduleTaskAtStarted(() -> {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment == null) {
                    callback.invoke(null, false);
                    return;
                }
                callback.invoke(null, fragment.isStackRoot());
            });
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
    public void findSceneIdByModuleName(@NonNull String moduleName, Callback callback) {
        final Runnable task = new Runnable() {
            @Override
            public void run() {
                AwesomeActivity activity = getActiveActivity();
                if (activity == null || !bridgeManager.isViewHierarchyReady()) {
                    UiThreadUtil.runOnUiThread(this, 16);
                    return;
                }
                
                activity.scheduleTaskAtStarted(() -> {
                    FragmentManager fragmentManager = activity.getSupportFragmentManager();
                    Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);
                    if (!(fragment instanceof AwesomeFragment)) {
                        callback.invoke(null, null);
                        return;
                    }

                    String sceneId = findSceneIdByModuleName(moduleName, (AwesomeFragment) fragment);
                    FLog.i(TAG, "The sceneId found by " + moduleName + " : " + sceneId);
                    callback.invoke(null, sceneId);
                });
            }
        };

        UiThreadUtil.runOnUiThread(task);
    }

    private String findSceneIdByModuleName(@NonNull String moduleName, AwesomeFragment parent) {
        String sceneId = findSceneIdFromParent(moduleName, parent);
        if (sceneId != null) {
            return sceneId;
        }
        return findSceneIdFromChildren(moduleName, parent.getChildAwesomeFragments());
    }

    private String findSceneIdFromChildren(@NonNull String moduleName, List<AwesomeFragment> children) {
        for (int i = 0; i < children.size(); i++) {
            AwesomeFragment child = children.get(i);
            String sceneId = findSceneIdByModuleName(moduleName, child);
            if (sceneId != null) {
                return sceneId;
            }
        }
        return null;
    }

    @Nullable
    private String findSceneIdFromParent(@NonNull String moduleName, AwesomeFragment fragment) {
        if (!(fragment instanceof HybridFragment)) {
            return null;
        }

        HybridFragment hybridFragment = (HybridFragment) fragment;
        if (moduleName.equals(hybridFragment.getModuleName())) {
            return hybridFragment.getSceneId();
        }

        return null;
    }

    @ReactMethod
    public void currentRoute(final Callback callback) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                AwesomeActivity activity = getActiveActivity();
                if (activity == null || !bridgeManager.isViewHierarchyReady()) {
                    UiThreadUtil.runOnUiThread(this, 16);
                    return;
                }

                activity.scheduleTaskAtStarted(() -> {
                    FragmentManager fragmentManager = activity.getSupportFragmentManager();
                    HybridFragment current = bridgeManager.primaryFragment(fragmentManager);
                    if (current == null) {
                        UiThreadUtil.runOnUiThread(this, 16);
                        return;
                    }

                    Bundle bundle = new Bundle();
                    bundle.putString("moduleName", current.getModuleName());
                    bundle.putString("sceneId", current.getSceneId());
                    bundle.putString("mode", Navigator.Util.getMode(current));
                    callback.invoke(null, Arguments.fromBundle(bundle));
                });
            }
        };

        UiThreadUtil.runOnUiThread(task);
    }

    @ReactMethod
    public void routeGraph(final Callback callback) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                AwesomeActivity activity = getActiveActivity();
                if (activity == null || !bridgeManager.isViewHierarchyReady()) {
                    UiThreadUtil.runOnUiThread(this, 16);
                    return;
                }
                
                activity.scheduleTaskAtStarted(() -> {
                    FragmentManager fragmentManager = activity.getSupportFragmentManager();
                    ArrayList<Bundle> graph = bridgeManager.buildRouteGraph(fragmentManager);
                    if (graph.size() == 0) {
                        UiThreadUtil.runOnUiThread(this, 16);
                        return;
                    }

                    callback.invoke(null, Arguments.fromList(graph));
                });
            }
        };

        UiThreadUtil.runOnUiThread(task);
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
        if (reactContext == null || !reactContext.hasActiveCatalystInstance()) {
            return null;
        }

        Activity activity = reactContext.getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            return (ReactAppCompatActivity) activity;
        }

        return null;
    }
}
