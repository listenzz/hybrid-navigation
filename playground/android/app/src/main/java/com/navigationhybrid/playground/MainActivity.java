package com.navigationhybrid.playground;

import android.os.Bundle;
import android.util.Log;

import com.navigationhybrid.NavigationFragment;
import com.navigationhybrid.Navigator;
import com.navigationhybrid.ReactAppCompatActivity;
import com.navigationhybrid.ReactBridgeManager;

import java.util.UUID;

public class MainActivity extends ReactAppCompatActivity {

    public static final String TAG = "ReactNative";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        final ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        Log.w(TAG, "isReactModuleInRegistry:" + bridgeManager.isReactModuleInRegistry());
        if (savedInstanceState == null) {
            if (bridgeManager.isReactModuleInRegistry()) {
                bridgeManager.addReactModuleRegistryListener(new ReactBridgeManager.ReactModuleRegistryListener() {
                    @Override
                    public void onReactModuleRegistryCompleted() {
                        bridgeManager.removeReactModuleRegisryListener(this);
                        setup();
                    }
                });
            } else {
                setup();
            }
        }
    }

    void setup() {
        Navigator navigator = new Navigator(UUID.randomUUID().toString(), UUID.randomUUID().toString(), getSupportFragmentManager(), R.id.content);
        NavigationFragment fragment = navigator.createFragment("ReactNavigation", navigator.sceneId, null, null);
        navigator.setRoot(fragment, false);
    }

}
