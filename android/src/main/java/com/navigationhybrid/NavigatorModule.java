package com.navigationhybrid;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;


/**
 * Created by Listen on 2017/11/20.
 */

public class NavigatorModule extends ReactContextBaseJavaModule{

    static final String TAG = "ReactNative";

    private final Handler handler = new Handler(Looper.getMainLooper());

    private final ReactBridgeManager reactBridgeManager;

    NavigatorModule(ReactApplicationContext reactContext, ReactBridgeManager reactBridgeManager) {
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
    public void signalFirstRenderComplete(final String navId, final String sceneId) {
       handler.post(new Runnable() {
           @Override
           public void run() {
               ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
               if (fragment != null) {
                   fragment.signalFirstRenderComplete();
               }
           }
       });
    }

    @ReactMethod
    public void push(final String navId, final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.push(moduleName, Arguments.toBundle(props), Arguments.toBundle(options), animated);
                }
            }
        });
    }

    @ReactMethod
    public void pop(final String navId, final String sceneId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.pop(animated);
                }
            }
        });
    }

    @ReactMethod
    public void popTo(final String navId, final String sceneId, final String targetId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.popTo(targetId, animated);
                }
            }
        });
    }

    @ReactMethod
    public void popToRoot(final String navId, final String sceneId, boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.popToRoot();
                }
            }
        });
    }

    @ReactMethod
    public void isRoot(final String navId, final String sceneId, final Promise promise) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    promise.resolve(navigator.isRoot());
                }
            }
        });
    }

    @ReactMethod
    public void replace(final String navId, final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.replace(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                }
            }
        });
    }

    @ReactMethod
    public void replaceToRoot(final String navId, final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.replaceToRoot(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                }
            }
        });
    }

    @ReactMethod
    public void present(final String navId, final String sceneId, final String moduleName, final int requestCode, final ReadableMap props, final ReadableMap options, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.present(moduleName, requestCode, Arguments.toBundle(props), Arguments.toBundle(options), animated);
                }
            }
        });
    }

    @ReactMethod
    public void setResult(final String navId, final String sceneId, final int resultCode, final ReadableMap result) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.setResult(resultCode, Arguments.toBundle(result));
                }
            }
        });
    }

    @ReactMethod
    public void dismiss(final String navId, final String sceneId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Navigator navigator = findNavigator(navId, sceneId);
                if (navigator != null) {
                    navigator.dismiss(animated);
                }
            }
        });
    }

    private Navigator findNavigator(String navId, String sceneId) {
        Activity activity = getCurrentActivity();
        if (activity instanceof AppCompatActivity) {
            AppCompatActivity appCompatActivity = (AppCompatActivity) activity;
            FragmentManager fragmentManager = appCompatActivity.getSupportFragmentManager();
            Fragment fragment = fragmentManager.findFragmentByTag(sceneId);
            if (fragment == null) {
                fragment = fragmentManager.findFragmentByTag(navId);
            }
            if (fragment != null && fragment instanceof NavigationFragment) {
                NavigationFragment navigationFragment = (NavigationFragment) fragment;
                return navigationFragment.getNavigator();
            }
        }
        Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
        return null;
    }

    private ReactNavigationFragment findReactNavigationFragment(String navId, String sceneId) {
        Activity activity = getCurrentActivity();
        if (activity instanceof AppCompatActivity) {
            AppCompatActivity appCompatActivity = (AppCompatActivity) activity;
            FragmentManager fragmentManager = appCompatActivity.getSupportFragmentManager();
            Fragment fragment =  fragmentManager.findFragmentByTag(sceneId);
            if (fragment == null) {
                fragment =  fragmentManager.findFragmentByTag(navId);
            }
            if (fragment != null && fragment instanceof ReactNavigationFragment) {
                return (ReactNavigationFragment) fragment;
            }
        }
        return null;
    }

}
