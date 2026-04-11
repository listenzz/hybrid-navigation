package com.reactnative.hybridnavigation.example;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.core.splashscreen.SplashScreen;

import com.facebook.react.bridge.UiThreadUtil;
import com.navigation.androidx.AwesomeFragment;
import com.reactnative.hybridnavigation.ReactAppCompatActivity;

public class MainActivity extends ReactAppCompatActivity {

    private boolean keepSplashScreenOnScreen = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        SplashScreen splashScreen = SplashScreen.installSplashScreen(this);
        splashScreen.setOnExitAnimationListener(view -> view.remove()); // 移除 fade 动画
        splashScreen.setKeepOnScreenCondition(() -> keepSplashScreenOnScreen);
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null || getCurrentReactContext() != null) {
            keepSplashScreenOnScreen = false;
        }
    }

    @Override
    public void setActivityRootFragment(@NonNull AwesomeFragment fragment) {
        super.setActivityRootFragment(fragment);
        hideSplash();
    }

    private void hideSplash() {
        if (!keepSplashScreenOnScreen) {
            return;
        }
        // 如果发现有白屏，请调整 delayInMs 参数
        UiThreadUtil.runOnUiThread(() -> keepSplashScreenOnScreen = false, 500);
    }

    @Override
    protected boolean handleBackPressed() {
        // 按返回键并不真正退出 APP，而是把它移到后台
        moveTaskToBack(false);
        return true;
    }

}
