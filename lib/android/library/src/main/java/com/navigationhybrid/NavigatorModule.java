package com.navigationhybrid;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;


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
                reactBridgeManager.registerReactModule(appKey, Arguments.toBundle(options));
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
               } else {
                   Log.w(TAG, "ReactNavigationFragment is null. navId:" + navId + " sceneId:" + sceneId);
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
                } else {
                    Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
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
                } else {
                    Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
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
                } else {
                    Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
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
                } else {
                    Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
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
                } else {
                    Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
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
                } else {
                    Log.w(TAG, "navigator is null. navId:" + navId + " sceneId:" + sceneId);
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
