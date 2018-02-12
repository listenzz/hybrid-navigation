package com.navigationhybrid;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.KeyEvent;
import android.view.WindowManager;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;

import me.listenzz.navigation.AwesomeActivity;
import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.Style;


/**
 * Created by Listen on 2017/11/17.
 */

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity, ReactBridgeManager.ReactModuleRegistryListener {

    protected static final String TAG = "ReactNative";

    private static final String GLOBAL_STYLE_OPTIONS_KEY = "GlobalStyle";

    private final ReactAppCompatActivityDelegate activityDelegate;

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    protected ReactAppCompatActivity() {
        activityDelegate = new ReactAppCompatActivityDelegate(this, ReactBridgeManager.instance);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStatusBarTranslucent(true);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        activityDelegate.onCreate(savedInstanceState);

        bridgeManager.addReactModuleRegistryListener(this);

        if (savedInstanceState == null) {
            if (!isReactModuleInRegistry()) {
                createMainComponent();
            }
        } else {
            Bundle options = savedInstanceState.getBundle(GLOBAL_STYLE_OPTIONS_KEY);
            if (options != null) {
                Garden.createGlobalStyle(options);
                onCustomStyle(getStyle());
            }
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        GlobalStyle globalStyle = Garden.getGlobalStyle();
        if (globalStyle != null) {
            Bundle style = globalStyle.getOptions();
            if (style != null) {
                outState.putBundle(GLOBAL_STYLE_OPTIONS_KEY, style);
            }
        }
    }

    @Override
    protected void onCustomStyle(Style style) {
        GlobalStyle globalStyle = Garden.getGlobalStyle();
        if (globalStyle != null) {
            globalStyle.inflateStyle(this, style);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        activityDelegate.onDestroy();
        bridgeManager.removeReactModuleRegistryListener(this);
    }

    @Override
    public void onReactModuleRegistryCompleted() {
        createMainComponent();
    }

    private void createMainComponent() {
        onCustomStyle(getStyle());
        onCreateMainComponent();
    }

    protected void onCreateMainComponent() {
        if (getMainComponentName() != null) {
            AwesomeFragment awesomeFragment = bridgeManager.createFragment(getMainComponentName());
            ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
            reactNavigationFragment.setRootFragment(awesomeFragment);
            setRootFragment(reactNavigationFragment);
        } else if (bridgeManager.hasRootLayout()) {
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getRootLayout());
            if (fragment != null) {
                setRootFragment(fragment);
            }
        }
    }

    protected String getMainComponentName() {
        return null;
    }

    public boolean isReactModuleInRegistry() {
        return bridgeManager.isReactModuleInRegistry();
    }

    @Override
    protected void onPause() {
        super.onPause();
        activityDelegate.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        activityDelegate.onResume();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        activityDelegate.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        Log.i(TAG, "onKeyUp keyCode:" + keyCode);
        return activityDelegate.onKeyUp(keyCode, event) || super.onKeyUp(keyCode, event);
    }

    @Override
    public void onBackPressed() {
        if (!activityDelegate.onBackPressed()) {
            Log.i(TAG, getClass().getSimpleName() + "#onBackPressed");
            super.onBackPressed();
        }
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        Log.i(TAG, getClass().getSimpleName() + "#invokeDefaultOnBackPressed");
        super.onBackPressed();
    }

    @Override
    public void onNewIntent(Intent intent) {
        if (!activityDelegate.onNewIntent(intent)) {
            super.onNewIntent(intent);
        }
    }

    @Override
    public void requestPermissions(
            String[] permissions,
            int requestCode,
            PermissionListener listener) {
        activityDelegate.requestPermissions(permissions, requestCode, listener);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        activityDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    protected final ReactNativeHost getReactNativeHost() {
        return activityDelegate.getReactNativeHost();
    }

    protected final ReactInstanceManager getReactInstanceManager() {
        return activityDelegate.getReactInstanceManager();
    }

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }


}
