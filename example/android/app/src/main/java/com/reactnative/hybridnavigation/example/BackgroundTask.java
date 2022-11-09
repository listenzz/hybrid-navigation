package com.reactnative.hybridnavigation.example;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.Map;

public class BackgroundTask extends ReactContextBaseJavaModule  {
    
    private final ReactContext reactContext;
    
    public BackgroundTask(ReactContext reactContext) {
        this.reactContext = reactContext;
    }
    

    @NonNull
    @Override
    public String getName() {
        return "BackgroundTask";
    }

    @ReactMethod
    public void addListener(String eventType) {
        // do nothing
    }

    @ReactMethod
    public void removeListeners(int count) {
        // do nothing
    }

    public static final String BACKGROUND_TASK_EVENT = "BACKGROUND_TASK_EVENT";

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("BACKGROUND_TASK_EVENT", BACKGROUND_TASK_EVENT);
        // ...
        return constants;
    }
    
    @ReactMethod
    public void scheduleTask() {
        UiThreadUtil.runOnUiThread(() -> {
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(BACKGROUND_TASK_EVENT, Arguments.createMap());
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(BACKGROUND_TASK_EVENT, Arguments.createMap());
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(BACKGROUND_TASK_EVENT, Arguments.createMap());
        }, 3000);
    }
    
}
