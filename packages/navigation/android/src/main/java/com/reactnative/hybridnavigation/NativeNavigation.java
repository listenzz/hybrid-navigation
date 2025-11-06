package com.reactnative.hybridnavigation;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.module.annotations.ReactModule;
import com.navigation.androidx.AwesomeActivity;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.TabBarFragment;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ReactModule(name = NativeNavigation.NAME)
public class NativeNavigation extends NativeNavigationSpec {
	static final String TAG = "Navigation";
	public static final String NAME = "HBDNativeNavigation";
	private final ReactManager reactManager;

	public NativeNavigation(ReactApplicationContext reactContext, ReactManager reactManager) {
		super(reactContext);
		this.reactManager = reactManager;
		FLog.i(TAG, "NavigationModule#onCreate");
	}

	@Override
	@NonNull
	public String getName() {
		return NAME;
	}

	@Override
	public void invalidate() {
		FLog.i(TAG, "NavigationModule#invalidate");
		UiThreadUtil.runOnUiThread(() -> {
			reactManager.invalidate();
			clearFragments();
		});
	}

	@Override
	protected Map<String, Object> getTypedExportedConstants() {
		HashMap<String, Object> constants = new HashMap<>();
		constants.put("RESULT_OK", Activity.RESULT_OK);
		constants.put("RESULT_CANCEL", Activity.RESULT_CANCELED);
		constants.put("RESULT_BLOCK", -2);
		return constants;
	}

	@Override
	public void startRegisterReactComponent() {
		UiThreadUtil.runOnUiThread(reactManager::startRegisterReactModule);
	}

	@Override
	public void endRegisterReactComponent() {
		UiThreadUtil.runOnUiThread(reactManager::endRegisterReactModule);
	}

	@Override
	public void registerReactComponent(String appKey, ReadableMap options) {
		UiThreadUtil.runOnUiThread(() -> reactManager.registerReactModule(appKey, options));
	}

	@Override
	public void signalFirstRenderComplete(String sceneId) {
		UiThreadUtil.runOnUiThread(() -> {
			AwesomeActivity activity = getActiveActivity();
			if (activity == null) {
				return;
			}

			activity.scheduleTaskAtStarted(() -> {
				AwesomeFragment fragment = findFragmentBySceneId(sceneId);
				if (fragment instanceof ReactFragment reactFragment) {
					reactFragment.signalFirstRenderComplete();
				}
			});
		});
	}

	@Override
	public void setRoot(ReadableMap layout, boolean sticky, Callback callback) {
		FLog.i(TAG, "NavigationModule#setRoot isOnUiThread: " + UiThreadUtil.isOnUiThread());
		UiThreadUtil.runOnUiThread(() -> {
			ReactContext reactContext = getReactApplicationContext();
			if (!reactContext.hasActiveReactInstance()) {
				FLog.w(TAG, "ReactContext hasn't active CatalystInstance, skip action `setRoot`");
				return;
			}

			if (reactManager.getPendingCallback() != null) {
				reactManager.getPendingCallback().invoke(null, false);
			}

			reactManager.setViewHierarchyReady(false);
			reactManager.setRootLayout(layout, sticky);
			reactManager.setPendingLayout(layout, callback);

			if (!reactManager.isReactModuleRegisterCompleted()) {
				return;
			}

			ReactAppCompatActivity activity = getActiveActivity();
			if (activity != null && !activity.getSupportFragmentManager().isStateSaved()) {
				FLog.i(TAG, "Have active Activity and React module was registered, set root Fragment immediately.");
				activity.setActivityRootFragment(layout);
			}
		});
	}

	@Override
	public void setResult(String sceneId, double resultCode, @Nullable ReadableMap data) {
		UiThreadUtil.runOnUiThread(() -> {
			AwesomeFragment fragment = findFragmentBySceneId(sceneId);
			if (fragment != null) {
				fragment.setResult((int) resultCode, Arguments.toBundle(data));
			}
		});
	}

	@Override
	public void dispatch(String sceneId, String action, ReadableMap params, Callback callback) {
		FLog.i(TAG, "NavigationModule#dispatch isOnUiThread: " + UiThreadUtil.isOnUiThread());
		FLog.i(TAG, "NavigationModule#dispatch thread name: " + Thread.currentThread().getName());
		UiThreadUtil.runOnUiThread(() -> {
			AwesomeActivity activity = getActiveActivity();
			if (activity == null) {
				callback.invoke(null, false);
				return;
			}

			activity.scheduleTaskAtStarted(() -> {
				AwesomeFragment target = findFragmentBySceneId(sceneId);
				if (target == null) {
					callback.invoke(null, false);
					FLog.w(TAG, "Can't find target scene for action:" + action + ", maybe the scene is gone.\nparams: " + params);
					return;
				}

				if (!target.isAdded() || FragmentHelper.isRemoving(target)) {
					callback.invoke(null, false);
					return;
				}

				reactManager.handleNavigation(target, action, params, callback);
			});
		});
	}

	@Override
	public void currentTab(String sceneId, Callback callback) {
		UiThreadUtil.runOnUiThread(() -> {
			AwesomeActivity activity = getActiveActivity();
			if (activity == null) {
				callback.invoke(null, -1);
				return;
			}

			activity.scheduleTaskAtStarted(() -> {
				AwesomeFragment fragment = findFragmentBySceneId(sceneId);
				if (fragment == null) {
					callback.invoke(null, -1);
					return;
				}

				TabBarFragment tabs = fragment.getTabBarFragment();
				if (tabs == null) {
					callback.invoke(null, -1);
					return;
				}

				callback.invoke(null, tabs.getSelectedIndex());
			});
		});
	}

	@Override
	public void isStackRoot(String sceneId, Callback callback) {
		UiThreadUtil.runOnUiThread(() -> {
			AwesomeActivity activity = getActiveActivity();
			if (activity == null) {
				callback.invoke(null, -1);
				return;
			}

			activity.scheduleTaskAtStarted(() -> {
				AwesomeFragment fragment = findFragmentBySceneId(sceneId);
				if (fragment == null) {
					callback.invoke(null, false);
					return;
				}
				callback.invoke(null, fragment.isStackRoot());
			});
		});
	}

	@Override
	public void findSceneIdByModuleName(String moduleName, Callback callback) {
		final Runnable task = new Runnable() {
			@Override
			public void run() {
				AwesomeActivity activity = getActiveActivity();
				if (activity == null || !reactManager.isViewHierarchyReady()) {
					UiThreadUtil.runOnUiThread(this, 16);
					return;
				}

				activity.scheduleTaskAtStarted(() -> {
					FragmentManager fragmentManager = activity.getSupportFragmentManager();
					Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);
					if (!(fragment instanceof AwesomeFragment)) {
						callback.invoke(null, null);
						return;
					}

					String sceneId = findSceneIdByModuleName(moduleName, (AwesomeFragment) fragment);
					FLog.i(TAG, "The sceneId found by " + moduleName + " : " + sceneId);
					callback.invoke(null, sceneId);
				});
			}
		};

		UiThreadUtil.runOnUiThread(task);
	}

	@Override
	public void currentRoute(Callback callback) {
		Runnable task = new Runnable() {
			@Override
			public void run() {
				AwesomeActivity activity = getActiveActivity();
				if (activity == null || !reactManager.isViewHierarchyReady()) {
					UiThreadUtil.runOnUiThread(this, 16);
					return;
				}

				activity.scheduleTaskAtStarted(() -> {
					FragmentManager fragmentManager = activity.getSupportFragmentManager();
					HybridFragment current = reactManager.primaryFragment(fragmentManager);
					if (current == null) {
						UiThreadUtil.runOnUiThread(this, 16);
						return;
					}

					Bundle bundle = new Bundle();
					bundle.putString("moduleName", current.getModuleName());
					bundle.putString("sceneId", current.getSceneId());
					bundle.putString("mode", Navigator.Util.getMode(current));
					bundle.putString("presentingId", current.getPresentingSceneId());
					bundle.putInt("requestCode", current.getRequestCode());
					callback.invoke(null, Arguments.fromBundle(bundle));
				});
			}
		};

		UiThreadUtil.runOnUiThread(task);
	}

	@Override
	public void routeGraph(Callback callback) {
		Runnable task = new Runnable() {
			@Override
			public void run() {
				AwesomeActivity activity = getActiveActivity();
				if (activity == null || !reactManager.isViewHierarchyReady()) {
					UiThreadUtil.runOnUiThread(this, 16);
					return;
				}

				activity.scheduleTaskAtStarted(() -> {
					FragmentManager fragmentManager = activity.getSupportFragmentManager();
					ArrayList<Bundle> graph = reactManager.buildRouteGraph(fragmentManager);
					if (graph.isEmpty()) {
						UiThreadUtil.runOnUiThread(this, 16);
						return;
					}

					callback.invoke(null, Arguments.fromList(graph));
				});
			}
		};

		UiThreadUtil.runOnUiThread(task);
	}

	private void clearFragments() {
		AwesomeActivity activity = getActiveActivity();
		if (activity != null) {
			activity.clearFragments();
		}
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

	private String findSceneIdByModuleName(@NonNull String moduleName, AwesomeFragment parent) {
		String sceneId = findSceneIdFromParent(moduleName, parent);
		if (sceneId != null) {
			return sceneId;
		}
		return findSceneIdFromChildren(moduleName, parent.getChildAwesomeFragments());
	}

	@Nullable
	private String findSceneIdFromParent(@NonNull String moduleName, AwesomeFragment fragment) {
		if (!(fragment instanceof HybridFragment hybridFragment)) {
			return null;
		}

		if (moduleName.equals(hybridFragment.getModuleName())) {
			return hybridFragment.getSceneId();
		}

		return null;
	}

	private String findSceneIdFromChildren(@NonNull String moduleName, List<AwesomeFragment> children) {
		for (int i = 0; i < children.size(); i++) {
			AwesomeFragment child = children.get(i);
			String sceneId = findSceneIdByModuleName(moduleName, child);
			if (sceneId != null) {
				return sceneId;
			}
		}
		return null;
	}
}
