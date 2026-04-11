package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Parameters.mergeOptions;
import static com.reactnative.hybridnavigation.Parameters.toBundle;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.BarStyle;
import com.navigation.androidx.Style;

public class Garden {

	private static GlobalStyle globalStyle;

	static void createGlobalStyle(Bundle options) {
		globalStyle = new GlobalStyle(options);
	}

	@NonNull
	static GlobalStyle getGlobalStyle() {
		if (globalStyle == null) {
			globalStyle = new GlobalStyle(new Bundle());
		}
		return globalStyle;
	}

	private final HybridFragment fragment;

	private final Style style;

	boolean backInteractive = true;

	boolean swipeBackEnabled;

	boolean hidesBottomBarWhenPushed;

	Garden(@NonNull HybridFragment fragment, Style style) {
		this.fragment = fragment;
		this.style = style;

		Bundle options = fragment.getOptions();
		this.swipeBackEnabled = options.getBoolean("swipeBackEnabled", true);
		Bundle tabItem = options.getBundle("tabItem");
		this.hidesBottomBarWhenPushed = tabItem == null || tabItem.getBoolean("hideTabBarWhenPush", true);

		if (options.get("fitsOpaqueNavigationBarAndroid") != null) {
			boolean fitsOpaqueNavigationBar = options.getBoolean("fitsOpaqueNavigationBarAndroid");
			style.setFitsOpaqueNavigationBar(fitsOpaqueNavigationBar);
		}

		String screenColor = options.getString("screenBackgroundColor");
		if (!TextUtils.isEmpty(screenColor)) {
			style.setScreenBackgroundColor(Color.parseColor(screenColor));
		}

		applyOptions(options);
	}

	private void applyOptions(@NonNull Bundle options) {
		String statusBarStyle = options.getString("statusBarStyle");
		if (statusBarStyle != null) {
			if (statusBarStyle.equals("dark-content")) {
				style.setStatusBarStyle(BarStyle.DarkContent);
			} else {
				style.setStatusBarStyle(BarStyle.LightContent);
			}
		}

		String navigationBarColor = options.getString("navigationBarColorAndroid");
		if (!TextUtils.isEmpty(navigationBarColor)) {
			style.setNavigationBarColor(Color.parseColor(navigationBarColor));
		}

		if (options.get("navigationBarHiddenAndroid") != null) {
			style.setNavigationBarHidden(options.getBoolean("navigationBarHiddenAndroid"));
		}

		if (options.get("displayCutoutWhenLandscapeAndroid") != null) {
			style.setDisplayCutoutWhenLandscape(options.getBoolean("displayCutoutWhenLandscapeAndroid"));
		}

		if (options.get("statusBarHidden") != null) {
			style.setStatusBarHidden(options.getBoolean("statusBarHidden"));
		}

		if (options.get("backInteractive") != null) {
			this.backInteractive = options.getBoolean("backInteractive");
		}
	}

	void updateOptions(@NonNull ReadableMap readableMap) {
		Bundle patches = toBundle(readableMap);
		applyOptions(patches);

		if (readableMap.hasKey("screenBackgroundColor")) {
			String color = readableMap.getString("screenBackgroundColor");
			style.setScreenBackgroundColor(Color.parseColor(color));
			View root = fragment.requireView();
			root.setBackground(new ColorDrawable(Color.parseColor(color)));
		}

		if (shouldUpdateStatusBar(readableMap)) {
			fragment.setNeedsStatusBarAppearanceUpdate();
		}

		if (shouldUpdateNavigationBar(readableMap)) {
			fragment.setNeedsNavigationBarAppearanceUpdate();
		}

		Bundle options = mergeOptions(fragment.getOptions(), patches);
		fragment.setOptions(options);
	}

	private boolean shouldUpdateStatusBar(@NonNull ReadableMap readableMap) {
		String[] keys = new String[]{"statusBarStyle", "statusBarHidden", "displayCutoutWhenLandscapeAndroid"};
		for (String key : keys) {
			if (readableMap.hasKey(key)) {
				return true;
			}
		}
		return false;
	}

	private boolean shouldUpdateNavigationBar(@NonNull ReadableMap readableMap) {
		String[] keys = new String[]{"navigationBarColorAndroid", "navigationBarHiddenAndroid", "screenBackgroundColor"};
		for (String key : keys) {
			if (readableMap.hasKey(key)) {
				return true;
			}
		}
		return false;
	}
}
