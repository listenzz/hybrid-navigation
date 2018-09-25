package com.navigationhybrid;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;


/**
 * Created by Listen on 2017/11/20.
 */
public class NavigationModule extends ReactContextBaseJavaModule {

    static final String TAG = "ReactNative";
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final ReactBridgeManager reactBridgeManager;

    NavigationModule(ReactApplicationContext reactContext, ReactBridgeManager reactBridgeManager) {
        super(reactContext);
        this.reactBridgeManager = reactBridgeManager;
    }

    @Override
    public String getName() {
        return "NavigationHybrid";
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
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.startRegisterReactModule();
            }
        });
    }

    @ReactMethod
    public void endRegisterReactComponent() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.endRegisterReactModule();
            }
        });
    }

    @ReactMethod
    public void registerReactComponent(final String appKey, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.registerReactModule(appKey, options);
            }
        });
    }

    @ReactMethod
    public void signalFirstRenderComplete(final String sceneId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactFragment fragment = (ReactFragment) findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    fragment.signalFirstRenderComplete();
                }
            }
        });
    }

    @ReactMethod
    public void setRoot(final ReadableMap layout, final boolean sticky) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.setRootLayout(layout, sticky);
                Activity activity = getCurrentActivity();
                if (activity instanceof ReactAppCompatActivity) {
                    ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                    AwesomeFragment fragment = reactBridgeManager.createFragment(layout);
                    if (fragment != null) {
                        Log.i(TAG, "has active activity, set root directly");
                        reactAppCompatActivity.setActivityRootFragment(fragment);
                    }
                } else {
                    Log.w(TAG, "no active activity, schedule pending root");
                    reactBridgeManager.setPendingLayout(layout);
                }
            }
        });
    }

    @ReactMethod
    public void dispatch(final String sceneId, final String action, final ReadableMap extras) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                reactBridgeManager.handleNavigation(fragment, action, extras);
            }
        });
    }

    @ReactMethod
    public void isNavigationRoot(final String sceneId, final Promise promise) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    promise.resolve(fragment.isNavigationRoot());
                }
            }
        });
    }

    @ReactMethod
    public void setResult(final String sceneId, final int resultCode, final ReadableMap result) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    fragment.setResult(resultCode, Arguments.toBundle(result));
                }
            }
        });
    }

    @ReactMethod
    public void currentRoute(final Promise promise) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Activity activity = getCurrentActivity();
                if (activity == null || !(activity instanceof ReactAppCompatActivity)) {
                    promise.reject("1", "UI 层级还没有准备好");
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
                    promise.resolve(Arguments.fromBundle(bundle));
                } else {
                    promise.reject("2", "UI 层级还没有准备好");
                }
            }
        });
    }

    private HybridFragment getPrimaryFragment(Fragment fragment) {
        if (fragment != null && fragment instanceof AwesomeFragment) {
            return reactBridgeManager.primaryChildFragment((AwesomeFragment) fragment);
        }
        return null;
    }

    @ReactMethod
    public void routeGraph(final Promise promise) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Activity activity = getCurrentActivity();
                if (activity == null || !(activity instanceof ReactAppCompatActivity)) {
                    promise.reject("1", "UI 层级还没有准备好");
                    return;
                }
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                ArrayList<Bundle> root = new ArrayList<>();
                ArrayList<Bundle> modal = new ArrayList<>();
                List<AwesomeFragment> fragments = reactAppCompatActivity.getFragmentsAtAddedList();
                for (int i = 0; i < fragments.size(); i++) {
                    AwesomeFragment fragment = fragments.get(i);
                    buildRouteGraph(fragment, root, modal);
                }
                root.addAll(modal);
                if (root.size() > 0) {
                    promise.resolve(Arguments.fromList(root));
                } else {
                    promise.reject("2", "UI 层级还没有准备好");
                }
            }
        });
    }

    private void buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> root, ArrayList<Bundle> modal) {
        reactBridgeManager.buildRouteGraph(fragment, root, modal);
    }

    private HybridFragment findFragmentBySceneId(String sceneId) {
        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
            return findFragmentBySceneId(fragmentManager, sceneId);
        }
        return null;
    }

    private HybridFragment findFragmentBySceneId(FragmentManager fragmentManager, String sceneId) {
        return (HybridFragment) FragmentHelper.findDescendantFragment(fragmentManager, sceneId);
    }

}
