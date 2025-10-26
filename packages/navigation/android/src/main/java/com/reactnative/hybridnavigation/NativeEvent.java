package com.reactnative.hybridnavigation;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = NativeEvent.NAME)
public class NativeEvent extends NativeEventSpec {
	public NativeEvent(ReactApplicationContext reactContext) {
		super(reactContext);
	}

	public static NativeEvent getInstance() {
		ReactManager reactManager = ReactManager.get();
		ReactContext reactContext = reactManager.getCurrentReactContext();
		assert reactContext != null;
		return reactContext.getNativeModule(NativeEvent.class);
	}

}
