package com.navigationhybrid;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;
import com.navigationhybrid.androidnavigation.AwesomeActivity;

/**
 * Created by Listen on 2017/11/17.
 */

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity, ReactBridgeManager.ReactModuleRegistryListener {

    protected static final String TAG = "ReactNative";

    private static final String GLOBAL_STYLE_KEY = "GlobalStyle";

    private final ReactAppCompatActivityDelegate activityDelegate;

    final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;

    Handler handler = new Handler();

    private Runnable createMainComponentTask;

    protected ReactAppCompatActivity() {
        activityDelegate = new ReactAppCompatActivityDelegate(this, ReactBridgeManager.instance);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activityDelegate.onCreate(savedInstanceState);
        bridgeManager.addReactModuleRegistryListener(this);
        if (savedInstanceState == null) {
            if (isReactModuleInRegistry()) {
                scheduleCreateMainComponent();
            } else {
                onCreateMainComponent();
            }
        } else {
            Bundle style = savedInstanceState.getBundle(GLOBAL_STYLE_KEY);
            if (style != null) {
                Garden.setStyle(getApplicationContext(), style);
            }
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        Bundle style = Garden.getStyle();
        if (style != null) {
            outState.putBundle(GLOBAL_STYLE_KEY, style);
        }
    }

    private void scheduleCreateMainComponent() {
        createMainComponentTask = new Runnable() {
            @Override
            public void run() {
                createMainComponentTask = null;
                if (isReactModuleInRegistry()) {
                    scheduleCreateMainComponent();
                } else {
                    onCreateMainComponent();
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
        bridgeManager.removeReactModuleRegistryListener(this);
        activityDelegate.onDestroy();
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
    public void onReactModuleRegistryCompleted() {

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
            Log.i(TAG, getClass().getSimpleName() +  "#onBackPressed");
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
    public void onRequestPermissionsResult(
            int requestCode,
            String[] permissions,
            int[] grantResults) {
        activityDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    protected final ReactNativeHost getReactNativeHost() {
        return activityDelegate.getReactNativeHost();
    }

    protected final ReactInstanceManager getReactInstanceManager() {
        return activityDelegate.getReactInstanceManager();
    }

}
