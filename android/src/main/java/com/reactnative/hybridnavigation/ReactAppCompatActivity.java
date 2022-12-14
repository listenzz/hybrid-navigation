package com.reactnative.hybridnavigation;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import com.facebook.common.logging.FLog;
import com.facebook.infer.annotation.Assertions;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;
import com.navigation.androidx.AwesomeActivity;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.Style;

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity, ReactBridgeManager.ReactModuleRegisterListener {

    protected static final String TAG = "Navigation";

    private final ReactAppCompatActivityDelegate activityDelegate;

    protected ReactAppCompatActivity() {
        activityDelegate = createReactActivityDelegate();
    }

    protected ReactAppCompatActivityDelegate createReactActivityDelegate() {
        return new ReactAppCompatActivityDelegate(this, ReactBridgeManager.get());
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activityDelegate.onCreate(savedInstanceState);
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        bridgeManager.addReactModuleRegisterListener(this);
        
        if (isReactModuleRegisterCompleted()) {
            onReactModuleRegisterCompleted();
        }
    }
    
    public void inflateStyle() {
        Style style = getStyle();
        GlobalStyle globalStyle = Garden.getGlobalStyle();
        if (style != null && !isFinishing()) {
            FLog.i(TAG, "ReactAppCompatActivity#inflateStyle");
            globalStyle.inflateStyle(this, style);
        }
    }

    @Override
    protected void onDestroy() {
        getReactBridgeManager().removeReactModuleRegisterListener(this);
        super.onDestroy();
        activityDelegate.onDestroy();
    }

    @Override
    public void onReactModuleRegisterCompleted() {
        FLog.i(TAG, "ReactAppCompatActivity#onReactModuleRegisterCompleted");
        ReactContext reactContext = Assertions.assertNotNull(getCurrentReactContext());
        if (isResumed && reactContext.getCurrentActivity() == null) {
            activityDelegate.onResume();
        }
        inflateStyle();
        createMainComponent();
    }

    private void createMainComponent() {
        onCreateMainComponent();
    }

    protected void onCreateMainComponent() {
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        if (getMainComponentName() != null) {
            AwesomeFragment fragment = bridgeManager.createFragment(getMainComponentName());
            ReactStackFragment stackFragment = new ReactStackFragment();
            stackFragment.setRootFragment(fragment);
            setActivityRootFragment(stackFragment);
            return;
        }

        if (bridgeManager.hasPendingLayout()) {
            FLog.i(TAG, "Set root Fragment from pending layout when create main component");
            setActivityRootFragment(bridgeManager.getPendingLayout());
            return;
        }

        if (bridgeManager.hasStickyLayout()) {
            FLog.i(TAG, "Set root Fragment from sticky layout when create main component");
            setActivityRootFragment(bridgeManager.getStickyLayout());
            return;
        }

        if (bridgeManager.hasRootLayout()) {
            FLog.i(TAG, "Set root Fragment from last root layout when create main component");
            setActivityRootFragment(bridgeManager.getRootLayout());
            return;
        }

        FLog.w(TAG, "No layout to set when create main component");
    }

    protected String getMainComponentName() {
        return null;
    }

    protected void setActivityRootFragment(ReadableMap layout) {
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        AwesomeFragment fragment = bridgeManager.createFragment(layout);
        if (fragment == null) {
            throw new IllegalArgumentException("无法创建 Fragment. " + layout);
        }
        setActivityRootFragment(fragment);
    }

    @Override
    protected void setActivityRootFragmentSync(AwesomeFragment fragment) {
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        HBDEventEmitter.sendEvent(HBDEventEmitter.EVENT_WILL_SET_ROOT, Arguments.createMap());
        super.setActivityRootFragmentSync(fragment);
        bridgeManager.setViewHierarchyReady(true);
        Callback callback = bridgeManager.getPendingCallback();
        if (callback != null) {
            callback.invoke(null, true);
            bridgeManager.setPendingLayout(null, null);
        }
        HBDEventEmitter.sendEvent(HBDEventEmitter.EVENT_DID_SET_ROOT, Arguments.createMap());
    }

    boolean isResumed = false;

    @Override
    protected void onResume() {
        super.onResume();
        isResumed = true;
        if (getCurrentReactContext() != null) {
            activityDelegate.onResume();
        }

        ReactBridgeManager bridgeManager = getReactBridgeManager();
        if (bridgeManager.hasPendingLayout()) {
            FLog.i(TAG, "Set root Fragment from pending layout when resume.");
            setActivityRootFragment(bridgeManager.getPendingLayout());
        }
    }

    @Override
    protected void onPause() {
        isResumed = false;
        if (getCurrentReactContext() != null) {
            activityDelegate.onPause();
        }
        super.onPause();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        activityDelegate.onActivityResult(requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return activityDelegate.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return activityDelegate.onKeyUp(keyCode, event) || super.onKeyUp(keyCode, event);
    }

    @Override
    public boolean onKeyLongPress(int keyCode, KeyEvent event) {
        return activityDelegate.onKeyLongPress(keyCode, event) || super.onKeyLongPress(keyCode, event);
    }

    @Override
    public void onBackPressed() {
        if (!activityDelegate.onBackPressed()) {
            super.onBackPressed();
        }
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        scheduleTaskAtStarted(ReactAppCompatActivity.super::onBackPressed);
    }

    @Override
    public void onNewIntent(Intent intent) {
        if (!activityDelegate.onNewIntent(intent)) {
            super.onNewIntent(intent);
        }
    }

    @Override
    public void requestPermissions(String[] permissions, int requestCode, PermissionListener listener) {
        activityDelegate.requestPermissions(permissions, requestCode, listener);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        activityDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    protected final ReactNativeHost getReactNativeHost() {
        return activityDelegate.getReactNativeHost();
    }

    protected final ReactInstanceManager getReactInstanceManager() {
        return getReactNativeHost().getReactInstanceManager();
    }

    public ReactContext getCurrentReactContext() {
        return getReactInstanceManager().getCurrentReactContext();
    }

    @NonNull
    protected ReactBridgeManager getReactBridgeManager() {
        return activityDelegate.getReactBridgeManager();
    }

    protected boolean isReactModuleRegisterCompleted() {
        return getReactBridgeManager().isReactModuleRegisterCompleted();
    }
}
