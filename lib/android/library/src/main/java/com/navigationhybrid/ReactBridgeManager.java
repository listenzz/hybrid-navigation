package com.navigationhybrid;

import android.support.annotation.NonNull;
import android.util.Log;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.ReactContext;

import java.util.HashMap;

/**
 * Created by Listen on 2017/11/17.
 */

public class ReactBridgeManager {
    private static final String TAG = "ReactNative";

    public static ReactBridgeManager instance = new ReactBridgeManager();

    private HashMap<String, Class<? extends NavigationFragment>> nativeModules = new HashMap<>();
    private HashMap<String, String> reactModules = new HashMap<>();

    public ReactBridgeManager() {

    }

    public void install(@NonNull ReactNativeHost reactNativeHost) {
        this.reactNativeHost = reactNativeHost;
        this.setup();
    }

    public void registerNativeModule(String moduleName, Class<? extends NavigationFragment> clazz) {
        nativeModules.put(moduleName, clazz);
    }

    public boolean hasNativeModule(String moduleName) {
        return nativeModules.containsKey(moduleName);
    }

    public Class<? extends NavigationFragment> nativeModuleClassForName(String moduleName) {
        return nativeModules.get(moduleName);
    }

    public void registerReactModule(String moduleName, String componentName) {
        reactModules.put(moduleName, componentName);
    }

    public boolean hasReactModule(String moduleName) {
        return reactModules.containsKey(moduleName);
    }

    public String reactModuleComponentForName(String moduleName) {
        return reactModules.get(moduleName);
    }

    public void clearReactModules() {
        reactModules.clear();
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
