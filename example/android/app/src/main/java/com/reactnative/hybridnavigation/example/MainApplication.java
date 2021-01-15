package com.reactnative.hybridnavigation.example;

import android.app.Application;

import androidx.appcompat.app.AppCompatDelegate;

import com.facebook.common.logging.FLog;
import com.facebook.drawee.view.DraweeView;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.soloader.SoLoader;
import com.reactnative.hybridnavigation.HybridNavigationPackage;
import com.reactnative.hybridnavigation.ReactBridgeManager;

import java.util.List;


public class MainApplication extends Application implements ReactApplication {

	private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
		@Override
		public boolean getUseDeveloperSupport() {
			return BuildConfig.DEBUG;
		}

		@Override
		protected List<ReactPackage> getPackages() {
			List<ReactPackage> packages = new PackageList(this).getPackages();
			packages.add(new HybridNavigationPackage());
			return packages;
		}

		@Override
		protected String getJSMainModuleName() {
			return "example/index";
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

		ReactBridgeManager bridgeManager = ReactBridgeManager.get();
		bridgeManager.install(getReactNativeHost());

		// register native modules
		bridgeManager.registerNativeModule("OneNative", OneNativeFragment.class);
		bridgeManager.registerNativeModule("NativeModal", NativeModalFragment.class);

		DraweeView.setGlobalLegacyVisibilityHandlingEnabled(true);
		FLog.setMinimumLoggingLevel(FLog.INFO);

		AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
	}

}