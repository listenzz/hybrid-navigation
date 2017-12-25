package com.navigationhybrid;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

/**
 * Created by Listen on 2017/11/22.
 */

public class GardenModule extends ReactContextBaseJavaModule{

    private static final String TAG = "ReactNative";

    static Bundle mergeOptions(@NonNull Bundle options, @NonNull String key, @NonNull ReadableMap readableMap) {
        Bundle subBundle = options.getBundle(key);
        if (subBundle == null) {
            subBundle = new Bundle();
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(subBundle));
        writableMap.merge(readableMap);
        return Arguments.toBundle(writableMap);
    }

    private final Handler handler = new Handler(Looper.getMainLooper());

    public GardenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "GardenHybrid";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("DARK_CONTENT", Garden.TOP_BAR_STYLE_DARK_CONTENT);
        constants.put("LIGHT_CONTENT", Garden.TOP_BAR_STYLE_LIGHT_CONTENT);
        return constants;
    }

    @ReactMethod
    public void setStyle(final ReadableMap style) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Garden.setStyle(Arguments.toBundle(style));
            }
        });
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String navId, final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle buttonItem = mergeOptions(options, "leftBarButtonItem", readableMap);
                    options.putBundle("leftBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.garden.setLeftBarButtonItem(buttonItem);
                }
            }
        });
    }

    @ReactMethod
    public void setRightBarButtonItem(final String navId, final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle buttonItem = mergeOptions(options, "rightBarButtonItem", readableMap);
                    options.putBundle("rightBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.garden.setRightBarButtonItem(buttonItem);
                }
            }
        });
    }

    @ReactMethod
    public void setTitleItem(final String navId, final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactNavigationFragment fragment = findReactNavigationFragment(navId, sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle titleItem = mergeOptions(options, "titleItem", readableMap);
                    options.putBundle("titleItem", titleItem);
                    fragment.setOptions(options);

                    fragment.garden.setTitleItem(titleItem);
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
