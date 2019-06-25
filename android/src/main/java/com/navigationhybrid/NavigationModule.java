package com.navigationhybrid;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.navigator.Navigator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import me.listenzz.navigation.AwesomeActivity;
import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;


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
        return "NavigationHybrid";
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        Log.i(TAG, "NavigationModule#onCatalystInstanceDestroy");
        sHandler.removeCallbacksAndMessages(null);
        sHandler.post(() -> {
            bridgeManager.setReactModuleRegisterCompleted(false);
            bridgeManager.setViewHierarchyReady(false);
            Activity activity = getCurrentActivity();
            if (activity instanceof AwesomeActivity) {
                LocalBroadcastManager.getInstance(activity).sendBroadcast(new Intent(Constants.INTENT_RELOAD_JS_BUNDLE));
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
    public void setRoot(final ReadableMap layout, final boolean sticky) {
        sHandler.post(() -> {
            if (bridgeManager.getCurrentReactContext() == null) {
                Log.w(TAG, "current react context is null, skip action `setRoot`");
                return;
            }
            bridgeManager.setViewHierarchyReady(false);
            bridgeManager.setRootLayout(layout, sticky);
            Activity activity = getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity && bridgeManager.isReactModuleRegisterCompleted()) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                AwesomeFragment fragment = bridgeManager.createFragment(layout);
                if (fragment != null) {
                    Log.i(TAG, "have active activity and react module was registered, set root directly");
                    reactAppCompatActivity.setActivityRootFragment(fragment);
                }
            } else {
                Log.w(TAG, "have no active activity or react module was not registered, schedule pending root");
                bridgeManager.setPendingLayout(layout);
            }
        });
    }

    @ReactMethod
    public void dispatch(final String sceneId, final String action, final ReadableMap extras) {
        sHandler.post(() -> {
            AwesomeFragment target = findFragmentBySceneId(sceneId);
            if (target != null && target.isAdded()) {
                bridgeManager.handleNavigation(target, action, extras);
            } else {
                Log.w(TAG, "Can't find target scene for action:" + action + ", maybe the scene is gone.\nextras: " + extras);
            }
        });
    }

    @ReactMethod
    public void reload() {
        sHandler.post(() ->
                bridgeManager.getReactInstanceManager().recreateReactContextInBackground()
        );
    }

    @ReactMethod
    public void delay(int ms, final Promise promise) {
        sHandler.postDelayed(() -> promise.resolve(Arguments.createMap()), ms);
    }

    @ReactMethod
    public void foreground(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                if (bridgeManager.getCurrentReactContext() == null) {
                    Log.w(TAG, "current react context is null, skip action `currentRoute`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                reactAppCompatActivity.scheduleTaskAtStarted(() -> promise.resolve(Arguments.createMap()));
            }
        };

        sHandler.post(task);
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
    public void currentRoute(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                if (bridgeManager.getCurrentReactContext() == null) {
                    Log.w(TAG, "current react context is null, skip action `currentRoute`");
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
                HybridFragment current = getPrimaryFragment(fragment);

                if (current != null) {
                    Bundle bundle = new Bundle();
                    bundle.putString("moduleName", current.getModuleName());
                    bundle.putString("sceneId", current.getSceneId());
                    bundle.putString("mode", Navigator.Util.getMode(current));
                    promise.resolve(Arguments.fromBundle(bundle));
                } else {
                    promise.reject("404", "No current route", new IllegalStateException("No current route."));
                }
            }
        };

        sHandler.post(task);
    }

    @Nullable
    private HybridFragment getPrimaryFragment(@Nullable Fragment fragment) {
        if (fragment instanceof AwesomeFragment) {
            return bridgeManager.primaryFragment((AwesomeFragment) fragment);
        }
        return null;
    }

    @ReactMethod
    public void routeGraph(final Promise promise) {
        Runnable task = new Runnable() {
            @Override
            public void run() {
                if (bridgeManager.getCurrentReactContext() == null) {
                    Log.w(TAG, "current react context is null, skip action `routeGraph`");
                    return;
                }

                Activity activity = getCurrentActivity();
                if (!bridgeManager.isViewHierarchyReady() || !(activity instanceof ReactAppCompatActivity)) {
                    sHandler.postDelayed(this, 16);
                    return;
                }

                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();

                ArrayList<Bundle> root = new ArrayList<>();
                ArrayList<Bundle> modal = new ArrayList<>();
                List<AwesomeFragment> fragments = FragmentHelper.getFragmentsAtAddedList(fragmentManager);
                for (int i = 0; i < fragments.size(); i++) {
                    AwesomeFragment fragment = fragments.get(i);
                    buildRouteGraph(fragment, root, modal);
                }
                root.addAll(modal);

                if (root.size() > 0) {
                    promise.resolve(Arguments.fromList(root));
                } else {
                    promise.reject("404", "No route graph", new IllegalStateException("No route graph."));
                }
            }
        };

        sHandler.post(task);
    }

    private void buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        bridgeManager.buildRouteGraph(fragment, root, modal);
    }

    private AwesomeFragment findFragmentBySceneId(String sceneId) {
        if (!bridgeManager.isViewHierarchyReady() || bridgeManager.getCurrentReactContext() == null) {
            Log.w(TAG, "View hierarchy is not ready now.");
            return null;
        }

        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
            return (AwesomeFragment) FragmentHelper.findDescendantFragment(fragmentManager, sceneId);
        }
        return null;
    }
}
