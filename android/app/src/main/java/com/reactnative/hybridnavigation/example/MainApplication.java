package com.reactnative.hybridnavigation.example;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDelegate;

import com.facebook.common.logging.FLog;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactHost;
import com.facebook.react.ReactNativeApplicationEntryPoint;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.defaults.DefaultReactHost;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.reactnative.hybridnavigation.ReactManager;

import java.util.List;

public class MainApplication extends Application implements ReactApplication {
    private final ReactNativeHost reactNativeHost = new DefaultReactNativeHost(this) {
        @Override
        public List<ReactPackage> getPackages() {
            List<ReactPackage> packages = new PackageList(this).getPackages();
            // Packages that cannot be autolinked yet can be added manually here, for example:
            return packages;
        }

		@NonNull
        @Override
        public String getJSMainModuleName() {
            return "index";
        }

        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        public boolean isNewArchEnabled() {
            return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
        }

        @Override
        public boolean isHermesEnabled() {
            return BuildConfig.IS_HERMES_ENABLED;
        }
    };

	@NonNull
    @Override
    public ReactHost getReactHost() {
        return DefaultReactHost.getDefaultReactHost(getApplicationContext(), reactNativeHost, null);
    }

    @Override
    public void onCreate() {
        super.onCreate();
		ReactNativeApplicationEntryPoint.loadReactNative(this);

        ReactManager reactManager = ReactManager.get();
        reactManager.install(getReactHost());

        // register native modules
        reactManager.registerNativeModule("NativeModule", NativeFragment.class);
        FLog.setMinimumLoggingLevel(FLog.INFO);

        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
    }
}
