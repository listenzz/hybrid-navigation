package com.navigationhybrid.navigator;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigationhybrid.HBDEventEmitter;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactNavigationFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.navigationhybrid.HBDEventEmitter.EVENT_NAVIGATION;
import static com.navigationhybrid.HBDEventEmitter.KEY_ON;
import static com.navigationhybrid.HBDEventEmitter.KEY_REQUEST_CODE;
import static com.navigationhybrid.HBDEventEmitter.KEY_RESULT_CODE;
import static com.navigationhybrid.HBDEventEmitter.KEY_SCENE_ID;
import static com.navigationhybrid.HBDEventEmitter.ON_COMPONENT_RESULT;


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
                if (fragment != null) {
                    int requestCode = extras.getInt("requestCode");
                    ReactNavigationFragment navFragment = new ReactNavigationFragment();
                    navFragment.setRootFragment(fragment);
                    if (FragmentHelper.canPresentFragment(target, target.requireActivity())) {
                        target.presentFragment(navFragment, requestCode);
                    } else {
                        cancelAction(target, requestCode);
                    }
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
                if (fragment != null) {
                    int requestCode = extras.getInt("requestCode");
                    if (FragmentHelper.canShowDialog(target, target.requireActivity())) {
                        target.showDialog(fragment, requestCode);
                    } else {
                        cancelAction(target, requestCode);
                    }
                }
                break;
            case "hideModal":
                target.hideDialog();
                break;
            case "presentLayout":
                ReadableMap layout = extras.getMap("layout");
                fragment = getReactBridgeManager().createFragment(layout);
                if (fragment != null) {
                    int requestCode = extras.getInt("requestCode");
                    if (FragmentHelper.canPresentFragment(target, target.requireActivity())) {
                        target.presentFragment(fragment, requestCode);
                    } else {
                        cancelAction(target, requestCode);
                    }
                }
                break;
            case "showModalLayout":
                ReadableMap modalLayout = extras.getMap("layout");
                fragment = getReactBridgeManager().createFragment(modalLayout);
                if (fragment != null) {
                    int requestCode = extras.getInt("requestCode");
                    if (FragmentHelper.canShowDialog(target, target.requireActivity())) {
                        target.showDialog(fragment, requestCode);
                    } else {
                        cancelAction(target, requestCode);
                    }
                }
                break;
        }
    }

    private void cancelAction(AwesomeFragment target, int requestCode) {
        Bundle result = new Bundle();
        result.putInt(KEY_REQUEST_CODE, requestCode);
        result.putInt(KEY_RESULT_CODE, Activity.RESULT_CANCELED);
        result.putString(KEY_SCENE_ID, target.getSceneId());
        result.putString(KEY_ON, ON_COMPONENT_RESULT);
        HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(result));
    }


    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }
}
