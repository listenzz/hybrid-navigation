package com.navigationhybrid;

import android.app.Activity;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;

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
    public void setTopBarStyle(final String style) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setTopBarStyle(style);
            }
        });
    }

    @ReactMethod
    public void setStatusBarColor(final String color) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setStatusBarColor(Color.parseColor(color));
            }
        });
    }

    @ReactMethod
    public void setHideBackTitle(boolean hidden) {
        // only for ios
    }

    @ReactMethod
    public void setBackIcon(final ReadableMap icon) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setBackIcon(Arguments.toBundle(icon));
            }
        });
    }

    @ReactMethod
    public void setTopBarBackgroundColor(final String color) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setTopBarBackgroundColor(Color.parseColor(color));
            }
        });
    }

    @ReactMethod
    public void setTopBarTintColor(final String color) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setTopBarTintColor(Color.parseColor(color));
            }
        });
    }

    @ReactMethod
    public void setTitleTextColor(final String color) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setTitleTextColor(Color.parseColor(color));
            }
        });
    }

    @ReactMethod
    public void setTitleTextSize(final int dp) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setTitleTextSize(dp);
            }
        });
    }

    @ReactMethod
    public void setTitleAlignment(final String alignment) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setTitleAlignment(alignment);
            }
        });
    }

    @ReactMethod
    public void setBarButtonItemTintColor(final String color) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setBarButtonItemTintColor(Color.parseColor(color));
            }
        });
    }

    @ReactMethod
    public void setBarButtonItemTextSize(final int dp) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setBarButtonItemTextSize(dp);
            }
        });
    }


    // -------

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

    @ReactMethod
    public void setRightBarButtonItem(final String navId, final String sceneId, final ReadableMap item) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
                if (fragment != null && fragment.getView() != null) {
                    fragment.garden.setRightBarButtonItem(Arguments.toBundle(item));
                }
            }
        });
    }

    @ReactMethod
    public void setTitleItem(final String navId, final String sceneId, final ReadableMap item) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
                if (fragment != null && fragment.getView() != null) {
                    fragment.garden.setTitleItem(Arguments.toBundle(item));
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
