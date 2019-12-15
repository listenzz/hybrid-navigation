package com.navigationhybrid.playground;

import android.os.Bundle;

import com.facebook.react.bridge.UiThreadUtil;
import com.navigation.androidx.AwesomeFragment;
import com.navigationhybrid.ReactAppCompatActivity;

public class MainActivity extends ReactAppCompatActivity {

    private SplashFragment splashFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.AppTheme);

        super.onCreate(savedInstanceState);

        if (savedInstanceState == null || !isReactModuleRegisterCompleted()) {
            splashFragment = new SplashFragment();
            showDialogInternal(splashFragment, 0);
        }
    }

    @Override
    protected void setRootFragmentInternal(AwesomeFragment fragment, int tag) {
        super.setRootFragmentInternal(fragment, tag);
        if (splashFragment != null) {
            // 如果发现有白屏，请调整 delayInMs 参数
            UiThreadUtil.runOnUiThread(() -> {
                splashFragment.dismissDialog();
                splashFragment = null;
            }, 200);
        }
    }

    @Override
    protected boolean handleBackPressed() {
        // 按返回键并不真正退出 APP，而是把它移到后台
        moveTaskToBack(false);
        return true;
    }

}
