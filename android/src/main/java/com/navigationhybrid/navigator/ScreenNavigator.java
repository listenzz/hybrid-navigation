package com.navigationhybrid.navigator;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactAppCompatActivity;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactNavigationFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;

public class ScreenNavigator implements Navigator {

    final static String TAG = "ReactNative";

    private List<String> supportActions = Arrays.asList("present", "presentLayout", "dismiss", "showModal", "showModalLayout", "hideModal");

    @Override
    @NonNull
    public String name() {
        return "screen";
    }

    @Override
    @NonNull
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(@NonNull ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableMap screen = layout.getMap(name());
            if (screen == null) {
                throw new IllegalArgumentException("screen should be an object.");
            }
            String moduleName = screen.getString("moduleName");
            if (moduleName == null) {
                throw new IllegalArgumentException("moduleName is required.");
            }

            Bundle props = null;
            if (screen.hasKey("props")) {
                ReadableMap map = screen.getMap("props");
                props = Arguments.toBundle(map);
            }

            Bundle options = null;
            if (screen.hasKey("options")) {
                ReadableMap map = screen.getMap("options");
                options = Arguments.toBundle(map);
            }
            return getReactBridgeManager().createFragment(moduleName, props, options);
        }
        return null;
    }

    @Override
    public boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment instanceof HybridFragment && fragment.isAdded()) {
            HybridFragment screen = (HybridFragment) fragment;
            Bundle route = new Bundle();
            route.putString("layout", name());
            route.putString("sceneId", screen.getSceneId());
            route.putString("moduleName", screen.getModuleName());
            route.putString("mode", Navigator.Util.getMode(fragment));
            root.add(route);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof HybridFragment && fragment.isAdded()) {
            AwesomeFragment presented = FragmentHelper.getLatterFragment(fragment.requireFragmentManager(), fragment);
            if (presented != null) {
                return (HybridFragment) presented;
            }
            return (HybridFragment) fragment;
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras) {
        AwesomeFragment fragment = null;
        if (extras.hasKey("moduleName")) {
            String moduleName = extras.getString("moduleName");
            if (moduleName != null) {
                Bundle props = null;
                Bundle options = null;
                if (extras.hasKey("props")) {
                    props = Arguments.toBundle(extras.getMap("props"));
                }
                if (extras.hasKey("options")) {
                    options = Arguments.toBundle(extras.getMap("options"));
                }
                fragment = getReactBridgeManager().createFragment(moduleName, props, options);
            }
        }
        switch (action) {
            case "present":
                if (fragment != null && canPresentFragment(target)) {
                    int requestCode = extras.getInt("requestCode");
                    ReactNavigationFragment navFragment = new ReactNavigationFragment();
                    navFragment.setRootFragment(fragment);
                    target.presentFragment(navFragment, requestCode);
                }
                break;
            case "dismiss":
                AwesomeFragment presenting = target.getPresentingFragment();
                if (presenting != null) {
                    presenting.dismissFragment();
                } else {
                    target.dismissFragment();
                }
                break;
            case "showModal":
                if (fragment != null && canShowModal(target)) {
                    int requestCode = extras.getInt("requestCode");
                    target.showDialog(fragment, requestCode);
                }
                break;
            case "hideModal":
                target.dismissDialog();
                break;
            case "presentLayout":
                if (canPresentFragment(target)) {
                    ReadableMap layout = extras.getMap("layout");
                    fragment = getReactBridgeManager().createFragment(layout);
                    if (fragment != null) {
                        int requestCode = extras.getInt("requestCode");
                        target.presentFragment(fragment, requestCode);
                    }
                }
                break;
            case "showModalLayout":
                if (canShowModal(target)) {
                    ReadableMap modalLayout = extras.getMap("layout");
                    fragment = getReactBridgeManager().createFragment(modalLayout);
                    if (fragment != null) {
                        int requestCode = extras.getInt("requestCode");
                        target.showDialog(fragment, requestCode);
                    }
                }
                break;
        }
    }

    private boolean canPresentFragment(@NonNull AwesomeFragment fragment) {
        AwesomeFragment presented = fragment.getPresentedFragment();
        if (presented != null) {
            FLog.w(TAG, "can not present since the scene had present another scene already.");
            return false;
        }

        ReactContext reactContext = getReactBridgeManager().getCurrentReactContext();
        if (reactContext != null) {
            Activity activity = reactContext.getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                DialogFragment dialog = FragmentHelper.getDialogFragment(reactAppCompatActivity.getSupportFragmentManager());
                if (dialog != null) {
                    FLog.w(TAG, "can not present a scene over a modal.");
                    return false;
                }
            }
        }

        return true;
    }

    private boolean canShowModal(@NonNull AwesomeFragment fragment) {
        AwesomeFragment presented = fragment.getPresentedFragment();
        if (presented != null) {
            FLog.w(TAG, "can not show modal since the scene had present another scene already.");
            return false;
        }

        ReactContext reactContext = getReactBridgeManager().getCurrentReactContext();
        if (reactContext != null) {
            Activity activity = reactContext.getCurrentActivity();
            if (activity instanceof ReactAppCompatActivity) {
                ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                DialogFragment dialog = FragmentHelper.getDialogFragment(reactAppCompatActivity.getSupportFragmentManager());
                if (dialog != null && dialog != fragment) {
                    FLog.w(TAG, "can not show modal since the scene had show another modal already.");
                    return false;
                }
            }
        }
        return true;
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }
}
