package com.navigationhybrid;

import android.support.annotation.NonNull;
import android.util.Log;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.ReactContext;

/**
 * Created by Listen on 2017/11/17.
 */

public class ReactBridgeManager {
    private static final String TAG = "ReactNative";

    public static ReactBridgeManager instance = new ReactBridgeManager();

    public static void install(@NonNull ReactNativeHost reactNativeHost) {
        instance.reactNativeHost = reactNativeHost;
        instance.setup();
    }

    public boolean isInitialized() {
        return isInitialized;
    }

    ReactNativeHost getReactNativeHost() {
        checkReactNativeHost();
        return reactNativeHost;
    }

    public ReactInstanceManager getReactInstanceManager() {
        checkReactNativeHost();
        return reactNativeHost.getReactInstanceManager();
    }

    private ReactNativeHost reactNativeHost;
    private boolean isInitialized;

    private void setup() {
        Log.w(TAG, "bridge manager setup");
        final ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        reactInstanceManager.addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
            @Override
            public void onReactContextInitialized(ReactContext context) {
                // reactInstanceManager.removeReactInstanceEventListener(this);
                isInitialized = true;
                Log.w(TAG, "react context initialized");
            }
        });
        reactInstanceManager.createReactContextInBackground();
    }

    private void checkReactNativeHost() {
        if (reactNativeHost == null) {
            throw new IllegalStateException("must call install first");
        }
    }

}
