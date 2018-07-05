package com.navigationhybrid;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.KeyEvent;
import android.view.WindowManager;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;

import java.util.ArrayList;
import java.util.List;

import me.listenzz.navigation.AwesomeActivity;
import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.Style;


/**
 * Created by Listen on 2017/11/17.
 */

public class ReactAppCompatActivity extends AwesomeActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity, ReactBridgeManager.ReactModuleRegistryListener {

    protected static final String TAG = "ReactNative";

    private final ReactAppCompatActivityDelegate activityDelegate;

    protected ReactAppCompatActivity() {
        activityDelegate = createReactActivityDelegate();
    }

    protected ReactAppCompatActivityDelegate createReactActivityDelegate() {
        return new ReactAppCompatActivityDelegate(this, ReactBridgeManager.instance);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activityDelegate.onCreate(savedInstanceState);

        setStatusBarTranslucent(true);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        getReactBridgeManager().addReactModuleRegistryListener(this);

        if (savedInstanceState == null) {
            if (!isReactModuleInRegistry()) {
                createMainComponent();
            }
        }
    }

    @Override
    protected void onCustomStyle(Style style) {
        if (!isReactModuleInRegistry()) {
            GlobalStyle globalStyle = Garden.getGlobalStyle();
            if (globalStyle != null) {
                globalStyle.inflateStyle(this, style);
            }
        }
    }

    @Override
    protected void onDestroy() {
        getReactBridgeManager().removeReactModuleRegistryListener(this);
        super.onDestroy();
        activityDelegate.onDestroy();
    }

    @Override
    public void onReactModuleRegistryCompleted() {
        onCustomStyle(getStyle());
        createMainComponent();
    }

    private void createMainComponent() {
        onCreateMainComponent();
    }

    protected void onCreateMainComponent() {
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        if (getMainComponentName() != null) {
            AwesomeFragment awesomeFragment = bridgeManager.createFragment(getMainComponentName());
            ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
            reactNavigationFragment.setRootFragment(awesomeFragment);
            setActivityRootFragment(reactNavigationFragment);
        } else if (bridgeManager.hasPendingLayout()) {
            Log.i(TAG, "set root from pending layout when create main component");
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getRootLayout());
            bridgeManager.setPendingLayout(null);
            if (fragment != null) {
                setActivityRootFragment(fragment);
            }
        } else if (bridgeManager.hasStickyLayout()) {
            Log.i(TAG, "set root from sticky layout when create main component");
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getStickyLayout());
            if (fragment != null) {
                setActivityRootFragment(fragment);
            }
        } else if (bridgeManager.hasRootLayout()) {
            Log.i(TAG, "set root from last root layout when create main component");
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getRootLayout());
            if (fragment != null) {
                setActivityRootFragment(fragment);
            }
        } else {
            Log.w(TAG, "no root to set when create main component");
        }
    }

    protected String getMainComponentName() {
        return null;
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
        if (getReactBridgeManager().hasPendingLayout()) {
            Log.i(TAG, "set root from pending layout when resume");
            ReactBridgeManager bridgeManager = getReactBridgeManager();
            AwesomeFragment fragment = bridgeManager.createFragment(bridgeManager.getPendingLayout());
            bridgeManager.setPendingLayout(null);
            if (fragment != null) {
                setActivityRootFragment(fragment);
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        activityDelegate.onActivityResult(requestCode, resultCode, data);
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
        super.onBackPressed();
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
    }

    protected final ReactNativeHost getReactNativeHost() {
        return activityDelegate.getReactNativeHost();
    }

    protected final ReactInstanceManager getReactInstanceManager() {
        return activityDelegate.getReactInstanceManager();
    }

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return activityDelegate.getReactBridgeManager();
    }

    public boolean isReactModuleInRegistry() {
        return getReactBridgeManager().isReactModuleInRegistry();
    }

    public List<AwesomeFragment> getFragmentsAtAddedList() {
        List<AwesomeFragment> children = new ArrayList<>();
        List<Fragment> fragments = getSupportFragmentManager().getFragments();
        for (int i = 0, size = fragments.size(); i < size; i++) {
            Fragment fragment = fragments.get(i);
            if (fragment instanceof AwesomeFragment) {
                children.add((AwesomeFragment) fragment);
            }
        }
        return children;
    }

}
