package com.navigationhybrid;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
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
import me.listenzz.navigation.Style;


/**
 * Created by Listen on 2017/11/17.
 */

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity {

    protected static final String TAG = "ReactNative";

    private static final String GLOBAL_STYLE_OPTIONS_KEY = "GlobalStyle";

    private final ReactAppCompatActivityDelegate activityDelegate;

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    private Handler handler = new Handler();

    private Runnable createMainComponentTask;

    protected ReactAppCompatActivity() {
        activityDelegate = new ReactAppCompatActivityDelegate(this, ReactBridgeManager.instance);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentUnderStatusBar(true);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        activityDelegate.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            if (isReactModuleInRegistry()) {
                scheduleCreateMainComponent();
            } else {
                createMainComponent();
            }
        } else {
            Bundle options = savedInstanceState.getBundle(GLOBAL_STYLE_OPTIONS_KEY);
            if (options != null) {
                Garden.setStyleOptions(options);
                onCustomStyle(getStyle());
            }
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        Bundle style = Garden.getStyleOptions();
        if (style != null) {
            outState.putBundle(GLOBAL_STYLE_OPTIONS_KEY, style);
        }
    }

    @Override
    protected void onCustomStyle(Style style) {
        Garden.getGlobalStyle().inflateStyle(this, style);
    }

    private void scheduleCreateMainComponent() {
        createMainComponentTask = new Runnable() {
            @Override
            public void run() {
                createMainComponentTask = null;
                if (isReactModuleInRegistry()) {
                    scheduleCreateMainComponent();
                } else {
                    createMainComponent();
                }
            }
        };
        handler.post(createMainComponentTask);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (createMainComponentTask != null) {
            handler.removeCallbacks(createMainComponentTask);
        }
        activityDelegate.onDestroy();
    }

    private void createMainComponent() {
        onCustomStyle(getStyle());
        onCreateMainComponent();
    }

    protected void onCreateMainComponent() {
        if (getMainComponentName() != null) {
            ReactNavigationFragment reactNavigationFragment = ReactNavigationFragment.newInstance(getMainComponentName(), null, null);
            setRootFragment(reactNavigationFragment);
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

    public @NonNull
    ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }
}
