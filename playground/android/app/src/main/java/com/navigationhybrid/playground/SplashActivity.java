package com.navigationhybrid.playground;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;

import com.navigationhybrid.ReactBridgeManager;

/**
 * Created by Listen on 2018/2/9.
 */

public class SplashActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (ReactBridgeManager.get().isReactModuleRegisterCompleted()) {
            new Handler().postDelayed(() -> startMainActivity(), 1500);
        } else {
            ReactBridgeManager.get().addReactModuleRegisterListener(new ReactBridgeManager.ReactModuleRegisterListener() {
                @Override
                public void onReactModuleRegisterCompleted() {
                    ReactBridgeManager.get().removeReactModuleRegisterListener(this);
                    startMainActivity();
                }
            });
        }
    }

    private void startMainActivity() {
        startActivity(new Intent(this, MainActivity.class));
        overridePendingTransition(R.anim.nav_fade_in, R.anim.nav_fade_out);
        finish();
    }
}
