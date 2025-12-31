package com.reactnative.hybridnavigation;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.BaseReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;

import java.util.HashMap;
import java.util.Map;

public class HybridNavigationPackage extends BaseReactPackage {

	@Nullable
	@Override
	public NativeModule getModule(@NonNull String name, @NonNull ReactApplicationContext context) {
		return switch (name) {
			case NativeEvent.NAME -> new NativeEvent(context);
			case NativeNavigation.NAME ->
				new NativeNavigation(context, ReactManager.get());
			case NativeGarden.NAME ->
				new NativeGarden(context, ReactManager.get());
			default -> null;
		};
	}

	@NonNull
	@Override
	public ReactModuleInfoProvider getReactModuleInfoProvider() {
		return new ReactModuleInfoProvider() {
			@NonNull
			@Override
			public Map<String, ReactModuleInfo> getReactModuleInfos() {
				Map<String, ReactModuleInfo> map = new HashMap<>();
				map.put(NativeNavigation.NAME, new ReactModuleInfo(
					NativeNavigation.NAME,       // name
					NativeNavigation.NAME,       // className
					false, // canOverrideExistingModule
					false, // needsEagerInit
					false, // isCXXModule
					true   // isTurboModule
				));
				map.put(NativeGarden.NAME, new ReactModuleInfo(
					NativeGarden.NAME,       // name
					NativeGarden.NAME,       // className
					false, // canOverrideExistingModule
					false, // needsEagerInit
					false, // isCXXModule
					true   // isTurboModule
				));
				map.put(NativeEvent.NAME, new ReactModuleInfo(
					NativeEvent.NAME,       // name
					NativeEvent.NAME,       // className
					false, // canOverrideExistingModule
					false, // needsEagerInit
					false, // isCXXModule
					true   // isTurboModule
				));
				return map;
			}
		};
	}
}
