package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ACTION_SET_TAB_ITEM;
import static com.reactnative.hybridnavigation.Constants.ACTION_UPDATE_TAB_BAR;
import static com.reactnative.hybridnavigation.Constants.ARG_ACTION;
import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;
import static com.reactnative.hybridnavigation.Parameters.toBundle;
import static com.reactnative.hybridnavigation.Parameters.toList;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.JavaOnlyMap;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.TabBarFragment;

import java.util.HashMap;
import java.util.Map;

@ReactModule(name = NativeGarden.NAME)
public class NativeGarden extends NativeGardenSpec {
	private static final String TAG = "Navigation";
	private final ReactManager reactManager;

	NativeGarden(ReactApplicationContext reactContext, ReactManager reactManager) {
		super(reactContext);
		this.reactManager = reactManager;
	}

	@Override
	protected Map<String, Object> getTypedExportedConstants() {
		final Map<String, Object> constants = new HashMap<>();
		constants.put("TOOLBAR_HEIGHT", 56);
		return constants;
	}

	@Override
	public void setStyle(ReadableMap style) {
		UiThreadUtil.runOnUiThread(() -> {
			FLog.i(TAG, "GardenModule#setStyle");
			Garden.createGlobalStyle(toBundle(style));

			ReactAppCompatActivity activity = getActiveActivity();
			if (activity != null) {
				activity.inflateStyle();
			}
		});
	}

	@Override
	public void setTitleItem(String sceneId, ReadableMap item) {
		updateOptions(sceneId, item, "titleItem");
	}

	@Override
	public void setLeftBarButtonItem(String sceneId, @Nullable ReadableMap item) {
		updateOptions(sceneId, item, "leftBarButtonItem");
	}

	@Override
	public void setRightBarButtonItem(String sceneId, @Nullable ReadableMap item) {
		updateOptions(sceneId, item, "rightBarButtonItem");
	}

	@Override
	public void setLeftBarButtonItems(String sceneId, @Nullable ReadableArray items) {
		updateOptions(sceneId, items, "leftBarButtonItems");
	}

	@Override
	public void setRightBarButtonItems(String sceneId, @Nullable ReadableArray items) {
		updateOptions(sceneId, items, "rightBarButtonItems");
	}

	@Override
	public void updateOptions(String sceneId, ReadableMap options) {
		FLog.i(TAG, "update options:" + options);
		UiThreadUtil.runOnUiThread(() -> {
			HybridFragment fragment = findHybridFragmentBySceneId(sceneId);
			if (fragment != null) {
				fragment.getGarden().updateOptions(options);
			}
		});
	}

	@Override
	public void updateTabBar(String sceneId, ReadableMap item) {
		FLog.i(TAG, "updateTabBar:" + item);
		UiThreadUtil.runOnUiThread(() -> {
			TabBarFragment tabBarFragment = getTabBarFragment(sceneId);
			if (tabBarFragment == null) {
				return;
			}

			Bundle bundle = new Bundle();
			bundle.putString(ARG_ACTION, ACTION_UPDATE_TAB_BAR);
			bundle.putBundle(ARG_OPTIONS, toBundle(item));
			tabBarFragment.updateTabBar(bundle);
		});
	}

	@Override
	public void setTabItem(String sceneId, ReadableArray options) {
		FLog.i(TAG, "setTabItem:" + options);
		UiThreadUtil.runOnUiThread(() -> {
			TabBarFragment tabBarFragment = getTabBarFragment(sceneId);
			if (tabBarFragment == null) {
				return;
			}

			Bundle bundle = new Bundle();
			bundle.putString(ARG_ACTION, ACTION_SET_TAB_ITEM);
			bundle.putSerializable(ARG_OPTIONS, toList(options));
			tabBarFragment.updateTabBar(bundle);
		});
	}

	@Override
	public void setMenuInteractive(String sceneId, boolean enabled) {
		UiThreadUtil.runOnUiThread(() -> {
			AwesomeFragment fragment = findFragmentBySceneId(sceneId);
			if (fragment == null) {
				return;
			}

			DrawerFragment drawerFragment = fragment.getDrawerFragment();
			if (drawerFragment == null) {
				return;
			}

			drawerFragment.setMenuInteractive(enabled);
		});
	}

	private void updateOptions(String sceneId, @Nullable ReadableMap readableMap, String key) {
		WritableMap writableMap = new JavaOnlyMap();
		if (readableMap == null) {
			writableMap.putNull(key);
		} else {
			writableMap.putMap(key, readableMap);
		}
		updateOptions(sceneId, writableMap);
	}

	private void updateOptions(String sceneId, @Nullable ReadableArray readableArray, String key) {
		WritableMap writableMap = new JavaOnlyMap();
		if (readableArray == null) {
			writableMap.putNull(key);
		} else {
			writableMap.putArray(key, readableArray);
		}
		updateOptions(sceneId, writableMap);
	}

	@Nullable
	private ReactAppCompatActivity getActiveActivity() {
		ReactContext reactContext = getReactApplicationContext();
		if (!reactContext.hasActiveReactInstance()) {
			return null;
		}

		Activity activity = reactContext.getCurrentActivity();
		if (activity instanceof ReactAppCompatActivity) {
			return (ReactAppCompatActivity) activity;
		}

		return null;
	}

	private HybridFragment findHybridFragmentBySceneId(String sceneId) {
		AwesomeFragment fragment = findFragmentBySceneId(sceneId);
		if (fragment instanceof HybridFragment) {
			return (HybridFragment) fragment;
		}
		return null;
	}

	private AwesomeFragment findFragmentBySceneId(String sceneId) {
		if (!reactManager.isViewHierarchyReady()) {
			FLog.w(TAG, "View hierarchy is not ready now.");
			return null;
		}

		ReactAppCompatActivity activity = getActiveActivity();
		if (activity == null) {
			return null;
		}

		FragmentManager fragmentManager = activity.getSupportFragmentManager();
		return FragmentHelper.findAwesomeFragment(fragmentManager, sceneId);
	}

	@Nullable
	private TabBarFragment getTabBarFragment(String sceneId) {
		AwesomeFragment fragment = findFragmentBySceneId(sceneId);
		if (fragment != null) {
			return fragment.getTabBarFragment();
		}
		return null;
	}

}
