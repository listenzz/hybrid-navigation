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
 * Created by Listen on 2017/11/22.
 */

public class GardenModule extends ReactContextBaseJavaModule{

    private static final String TAG = "ReactNative";

    private final Handler handler = new Handler(Looper.getMainLooper());

    public GardenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "GardenHybrid";
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String navId, final String sceneId, final ReadableMap item) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
                if (fragment != null && fragment.getView() != null) {
                    fragment.garden.setLeftBarButtonItem(Arguments.toBundle(item));
                }
            }
        });
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
