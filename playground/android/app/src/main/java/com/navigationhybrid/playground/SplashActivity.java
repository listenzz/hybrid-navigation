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
        if (!ReactBridgeManager.instance.isReactModuleInRegistry()) {
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    startMainActivity();
                }
            }, 500);
        } else {
            ReactBridgeManager.instance.addReactModuleRegistryListener(new ReactBridgeManager.ReactModuleRegistryListener() {
                @Override
                public void onReactModuleRegistryCompleted() {
                    ReactBridgeManager.instance.removeReactModuleRegistryListener(this);
                    startMainActivity();
                }
            });
        }
    }

    private void startMainActivity() {
        startActivity(new Intent(this, MainActivity.class));
        finish();
    }
}
