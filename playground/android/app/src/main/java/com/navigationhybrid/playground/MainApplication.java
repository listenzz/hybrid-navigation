package com.navigationhybrid.playground;

import android.app.Application;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.navigationhybrid.NavigationHybridPackage;
import com.navigationhybrid.ReactBridgeManager;

import java.util.Arrays;
import java.util.List;

/**
 * Created by Listen on 2017/11/17.
 */

public class MainApplication extends Application implements ReactApplication{

    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                    new MainReactPackage(),
                    new NavigationHybridPackage()
            );
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, false);
        ReactBridgeManager.install(getReactNativeHost());
        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        bridgeManager.registerNativeModule("NativeNavigation", NativeNavigationFragment.class);
        bridgeManager.registerNativeModule("Navigation", NativeNavigationFragment.class);
    }
}
