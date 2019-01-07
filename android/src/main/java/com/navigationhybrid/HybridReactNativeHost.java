package com.navigationhybrid;

import android.app.Activity;
import android.app.Application;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactInstanceManagerBuilder;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeDeltaClient;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactMarker;
import com.facebook.react.bridge.ReactMarkerConstants;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.devsupport.interfaces.DevBundleDownloadListener;


import me.listenzz.navigation.AwesomeActivity;

public abstract class HybridReactNativeHost extends ReactNativeHost {

    private static final String TAG = "ReactNative";

    protected HybridReactNativeHost(Application application) {
        super(application);
    }

    @Override
    protected ReactInstanceManager createReactInstanceManager() {
        ReactMarker.logMarker(ReactMarkerConstants.BUILD_REACT_INSTANCE_MANAGER_START);
        ReactInstanceManagerBuilder builder = ReactInstanceManager.builder()
                .setApplication(getApplication())
                .setJSMainModulePath(getJSMainModuleName())
                .setUseDeveloperSupport(getUseDeveloperSupport())
                .setRedBoxHandler(getRedBoxHandler())
                .setJavaScriptExecutorFactory(getJavaScriptExecutorFactory())
                .setJSIModulesPackage(getJSIModulePackage())
                .setInitialLifecycleState(LifecycleState.BEFORE_CREATE)
                .setDevBundleDownloadListener(devBundleDownloadListener);

        for (ReactPackage reactPackage : getPackages()) {
            builder.addPackage(reactPackage);
        }

        String jsBundleFile = getJSBundleFile();
        if (jsBundleFile != null) {
            builder.setJSBundleFile(jsBundleFile);
        } else {
            builder.setBundleAssetName(Assertions.assertNotNull(getBundleAssetName()));
        }
        ReactInstanceManager reactInstanceManager = builder.build();
        ReactMarker.logMarker(ReactMarkerConstants.BUILD_REACT_INSTANCE_MANAGER_END);
        return reactInstanceManager;
    }


    private DevBundleDownloadListener devBundleDownloadListener = new DevBundleDownloadListener() {

        @Override
        public void onSuccess(@Nullable NativeDeltaClient nativeDeltaClient) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    ReactContext reactContext = getReactInstanceManager().getCurrentReactContext();
                    if (reactContext != null) {
                        Activity activity = reactContext.getCurrentActivity();
                        if (activity instanceof AwesomeActivity) {
                            ((AwesomeActivity) activity).clearFragments();
                        }
                    }
                }
            });
        }

        @Override
        public void onProgress(@Nullable String status, @Nullable Integer done, @Nullable Integer total) {

        }

        @Override
        public void onFailure(Exception cause) {
            Log.e(TAG, "dev bundle download failure: " + cause.getMessage(), cause);
        }
    };
}
