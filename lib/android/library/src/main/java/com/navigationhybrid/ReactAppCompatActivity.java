package com.navigationhybrid;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;

/**
 * Created by Listen on 2017/11/17.
 */

public class ReactAppCompatActivity extends AppCompatActivity implements DefaultHardwareBackBtnHandler, PermissionAwareActivity {

    private static final String TAG = "ReactNative";

    private final ReactAppCompatActivityDelegate activityDelegate;

    protected ReactAppCompatActivity() {
        activityDelegate = new ReactAppCompatActivityDelegate(this, ReactBridgeManager.instance);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activityDelegate.onCreate(savedInstanceState);
        getSupportFragmentManager().addOnBackStackChangedListener(new FragmentManager.OnBackStackChangedListener() {
            @Override
            public void onBackStackChanged() {
                FragmentManager fragmentManager =  getSupportFragmentManager();
                int count = fragmentManager.getBackStackEntryCount();
                for (int i = 0; i < count; i++) {
                    FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(i);
                    Log.d(TAG, "Entry index:" + entry.getId() + " tag:" + entry.getName());
                }
            }
        });
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
    protected void onDestroy() {
        super.onDestroy();
        activityDelegate.onDestroy();
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
        FragmentManager fragmentManager = getSupportFragmentManager();
        int count = fragmentManager.getBackStackEntryCount();
        if (count <= 1) {
            ActivityCompat.finishAfterTransition(this);
            return;
        }

        FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(count -1);
        if (entry.getName() != null) {
            Fragment fragment = fragmentManager.findFragmentByTag(entry.getName());
            if (fragment instanceof NavigationFragment) {
                NavigationFragment navigationFragment = (NavigationFragment) fragment;
                Navigator navigator = navigationFragment.getNavigator();
                if (navigator.canPop()) {
                    navigator.pop();
                    return;
                } else if (navigator.canDismiss()) {
                    navigator.dismiss();
                    return;
                }
            }
        }
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
