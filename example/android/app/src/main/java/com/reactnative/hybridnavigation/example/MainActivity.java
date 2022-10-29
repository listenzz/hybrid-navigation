package com.reactnative.hybridnavigation.example;

import android.os.Bundle;

import androidx.annotation.NonNull;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;
import com.navigation.androidx.AwesomeFragment;
import com.reactnative.hybridnavigation.ReactAppCompatActivity;

public class MainActivity extends ReactAppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.AppTheme);
        super.onCreate(savedInstanceState);
        launchSplash(savedInstanceState);
    }

    @Override
    public void setActivityRootFragment(@NonNull AwesomeFragment fragment) {
        super.setActivityRootFragment(fragment);
        hideSplash();
    }

    private SplashFragment splashFragment;

    private void launchSplash(Bundle savedInstanceState) {
        if (savedInstanceState != null) {
            String tag = savedInstanceState.getString("splash_tag");
            if (tag != null) {
                splashFragment = (SplashFragment) getSupportFragmentManager().findFragmentByTag(tag);
            }
        }
        
        if (splashFragment != null) {
            splashFragment.hideAsDialog();
            splashFragment = null;
        }
        
        // 当 Activity 销毁后重建，譬如旋转屏幕的时候，如果 React Native 已经启动完成，则不再显示闪屏
        ReactContext reactContext = getCurrentReactContext();
        if (splashFragment == null && reactContext == null) {
            splashFragment = new SplashFragment();
            FLog.i(TAG, "MainActivity#launchSplash showAsDialog");
            showAsDialog(splashFragment, 0);
        }
    }

    private void hideSplash() {
        if (splashFragment == null) {
            return;
        }
        // 如果发现有白屏，请调整 delayInMs 参数
        UiThreadUtil.runOnUiThread(() -> {
            if (splashFragment != null) {
                FLog.i(TAG, "MainActivity#hideSplash hideAsDialog");
                splashFragment.hideAsDialog();
                splashFragment = null;
            }
        }, 500);
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        if (splashFragment != null) {
            FLog.i(TAG, "MainActivity#onSaveInstanceState");
            outState.putString("splash_tag", splashFragment.getSceneId());
        }
    }

    @Override
    protected boolean handleBackPressed() {
        // 按返回键并不真正退出 APP，而是把它移到后台
        moveTaskToBack(false);
        return true;
    }

}