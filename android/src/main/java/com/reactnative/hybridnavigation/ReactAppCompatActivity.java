package com.reactnative.hybridnavigation;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.common.logging.FLog;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;
import com.navigation.androidx.AwesomeActivity;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.Style;

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity, ReactBridgeManager.ReactModuleRegisterListener {

    protected static final String TAG = "Navigator";

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
        getReactBridgeManager().addReactModuleRegisterListener(this);
        ensureViewHierarchy(savedInstanceState);
    }

    private void ensureViewHierarchy(Bundle savedInstanceState) {
        if (!isReactModuleRegisterCompleted()) {
            return;
        }

        if (savedInstanceState == null) {
            createMainComponent();
            return;
        }

        if (getSupportFragmentManager().getFragments().size() > 0) {
            getReactBridgeManager().setViewHierarchyReady(true);
        }
    }

    private boolean styleInflated;

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        inflateStyle();
    }

    public void inflateStyle() {
        Style style = getStyle();
        GlobalStyle globalStyle = Garden.getGlobalStyle();
        if (style != null && globalStyle != null && !isFinishing()) {
            styleInflated = true;
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
            setActivityRootFragment(bridgeManager);
            return;
        }

        if (bridgeManager.hasStickyLayout()) {
            FLog.i(TAG, "Set root Fragment from sticky layout when create main component");
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getStickyLayout());
            if (fragment != null) {
                setActivityRootFragment(fragment);
            }
            return;
        }

        if (bridgeManager.hasRootLayout()) {
            FLog.i(TAG, "Set root Fragment from last root layout when create main component");
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getRootLayout());
            if (fragment != null) {
                setActivityRootFragment(fragment);
            }
            return;
        }

        FLog.w(TAG, "No layout to set when create main component");
    }

    protected String getMainComponentName() {
        return null;
    }

    @Override
    public void setActivityRootFragment(@NonNull AwesomeFragment rootFragment) {
        setActivityRootFragment(rootFragment, 0);
    }

    private void setActivityRootFragment(ReactBridgeManager bridgeManager) {
        int pendingTag = bridgeManager.getPendingTag();
        ReadableMap pendingLayout = bridgeManager.getPendingLayout();
        if (pendingTag == 0 || pendingLayout == null) {
            return;
        }

        AwesomeFragment fragment = bridgeManager.createFragment(pendingLayout);
        if (fragment == null) {
            FLog.e(TAG, "Could not create fragment from  pending layout.");
            return;
        }
        setActivityRootFragment(fragment, pendingTag);
    }

    protected void setActivityRootFragment(@NonNull AwesomeFragment rootFragment, int tag) {
        if (isFinishing()) {
            return;
        }

        if (getSupportFragmentManager().isStateSaved()) {
            FLog.i(TAG, "Schedule to set Activity root Fragment.");
            scheduleTaskAtStarted(() -> setActivityRootFragmentSync(rootFragment, tag));
            return;
        }

        FLog.i(TAG, "Set Activity root Fragment immediately.");
        setActivityRootFragmentSync(rootFragment, tag);
    }

    protected void setActivityRootFragmentSync(AwesomeFragment fragment, int tag) {
        if (!styleInflated) {
            inflateStyle();
            if (!styleInflated) {
                throw new IllegalStateException("Style hasn't inflated yet. Did you forgot to call `Garden.setStyle` before `Navigator.setRoot` ?");
            }
        }

        ReactContext reactContext = getCurrentReactContext();
        if (reactContext == null || !reactContext.hasActiveCatalystInstance()) {
            return;
        }

        // will
        HBDEventEmitter.sendEvent(HBDEventEmitter.EVENT_WILL_SET_ROOT, Arguments.createMap());

        // do
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        bridgeManager.setPendingLayout(null, 0);
        setActivityRootFragmentSync(fragment);
        bridgeManager.setViewHierarchyReady(true);

        // did
        WritableMap map = Arguments.createMap();
        map.putInt("tag", tag);
        HBDEventEmitter.sendEvent(HBDEventEmitter.EVENT_DID_SET_ROOT, map);
    }

    @Override
    protected void onPause() {
        activityDelegate.onPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setActivityRootFragment(getReactBridgeManager());
        activityDelegate.onResume();
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
        return activityDelegate.getReactInstanceManager();
    }

    @NonNull
    protected ReactBridgeManager getReactBridgeManager() {
        return activityDelegate.getReactBridgeManager();
    }

    protected boolean isReactModuleRegisterCompleted() {
        return getReactBridgeManager().isReactModuleRegisterCompleted();
    }

    @Nullable
    public ReactContext getCurrentReactContext() {
        return getReactBridgeManager().getCurrentReactContext();
    }
}
