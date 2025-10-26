package com.reactnative.hybridnavigation.navigator;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.PresentableActivity;
import com.navigation.androidx.PresentationStyle;
import com.navigation.androidx.TransitionAnimation;
import com.reactnative.hybridnavigation.HybridFragment;
import com.reactnative.hybridnavigation.Navigator;
import com.reactnative.hybridnavigation.ReactManager;
import com.reactnative.hybridnavigation.ReactStackFragment;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;

public class ScreenNavigator implements Navigator {

    final static String TAG = "Navigation";

    private final List<String> supportActions = Arrays.asList("present", "presentLayout", "dismiss", "showModal", "showModalLayout", "hideModal");

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
        if (!layout.hasKey(name())) {
            return null;
        }

        ReadableMap screen = layout.getMap(name());
        if (screen == null) {
            throw new IllegalArgumentException("screen should be an object.");
        }

        String moduleName = screen.getString("moduleName");
        if (moduleName == null) {
            throw new IllegalArgumentException("moduleName is required.");
        }

        Bundle props = buildProps(screen);
        Bundle options = buildOptions(screen);

        return getReactManager().createFragment(moduleName, props, options);
    }

    @Override
    public Bundle buildRouteGraph(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof HybridFragment hybridFragment) || !fragment.isAdded()) {
            return null;
        }

		Bundle route = new Bundle();
        route.putString("layout", name());
        route.putString("sceneId", hybridFragment.getSceneId());
        route.putString("moduleName", hybridFragment.getModuleName());
        route.putString("mode", Navigator.Util.getMode(fragment));
        return route;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof HybridFragment) || !fragment.isAdded()) {
            return null;
        }

        AwesomeFragment presented = FragmentHelper.getFragmentAfter(fragment);
		return (HybridFragment) Objects.requireNonNullElse(presented, fragment);
	}

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Callback callback) {
        switch (action) {
            case "present":
                handlePresent(target, extras, callback);
                break;
            case "dismiss":
                handleDismiss(target, callback);
                break;
            case "showModal":
                handleShowModal(target, extras, callback);
                break;
            case "hideModal":
                handleHideModal(target, callback);
                break;
            case "presentLayout":
                handlePresentLayout(target, extras, callback);
                break;
            case "showModalLayout":
                handleShowModalLayout(target, extras, callback);
                break;

        }
    }

    private void handleShowModalLayout(@NonNull AwesomeFragment presenting, @NonNull ReadableMap extras, @NonNull Callback callback) {
        AwesomeFragment presented = presenting.getPresentedFragment();
        if (presented != null) {
            callback.invoke(null, false);
            return;
        }

        ReadableMap layout = extras.getMap("layout");
        presented = getReactManager().createFragment(layout);
        if (presented == null) {
            callback.invoke(null, false);
            return;
        }
        presented.setPresentationStyle(PresentationStyle.OverFullScreen);
        int requestCode = extras.getInt("requestCode");
        presenting.presentFragment(presented, requestCode, () -> callback.invoke(null, true), TransitionAnimation.None);
    }

    private void handlePresentLayout(@NonNull AwesomeFragment presenting, @NonNull ReadableMap extras, @NonNull Callback callback) {
        AwesomeFragment presented = presenting.getPresentedFragment();
        if (presented != null) {
            callback.invoke(null, false);
            return;
        }

        ReadableMap layout = extras.getMap("layout");
        presented = getReactManager().createFragment(layout);
        if (presented == null) {
            callback.invoke(null, false);
            return;
        }
        int requestCode = extras.getInt("requestCode");
        presenting.presentFragment(presented, requestCode, () -> callback.invoke(null, true));
    }

    private void handleShowModal(@NonNull AwesomeFragment presenting, @NonNull ReadableMap extras, @NonNull Callback callback) {
        AwesomeFragment presented = presenting.getPresentedFragment();
        if (presented != null) {
            callback.invoke(null, false);
            return;
        }

        presented = createFragmentWithExtras(extras);
        if (presented == null) {
            callback.invoke(null, false);
            return;
        }

        Bundle args = FragmentHelper.getArguments(presented);
        args.putString(PresentableActivity.ARG_PRESENTING_SCENE_ID, presenting.getSceneId());
        presented.setArguments(args);
        presented.setPresentationStyle(PresentationStyle.OverFullScreen);

        int requestCode = extras.getInt("requestCode");
        presenting.presentFragment(presented, requestCode, () -> callback.invoke(null, true), TransitionAnimation.None);
    }

    private void handleHideModal(@NonNull AwesomeFragment presented, @NonNull Callback callback) {
        presented.dismissFragment(() -> callback.invoke(null, true), TransitionAnimation.None);
    }

    private void handleDismiss(@NonNull AwesomeFragment presented, @NonNull Callback callback) {
        presented.dismissFragment(() -> callback.invoke(null, true));
    }

    private void handlePresent(@NonNull AwesomeFragment presenting, @NonNull ReadableMap extras, @NonNull Callback callback) {
        AwesomeFragment presented = presenting.getPresentedFragment();
        if (presented != null) {
            callback.invoke(null, false);
            return;
        }

        presented = createFragmentWithExtras(extras);
        if (presented == null) {
            callback.invoke(null, false);
            return;
        }

        Bundle args = FragmentHelper.getArguments(presented);
        args.putString(PresentableActivity.ARG_PRESENTING_SCENE_ID, presenting.getSceneId());
        presented.setArguments(args);

        int requestCode = extras.getInt("requestCode");
        ReactStackFragment stackFragment = new ReactStackFragment();
        stackFragment.setRootFragment(presented);
        presenting.presentFragment(stackFragment, requestCode, () -> callback.invoke(null, true));
    }

    private AwesomeFragment createFragmentWithExtras(@NonNull ReadableMap extras) {
        if (!extras.hasKey("moduleName")) {
            return null;
        }

        String moduleName = extras.getString("moduleName");
        if (moduleName == null) {
            return null;
        }

        Bundle props = buildProps(extras);
        Bundle options = buildOptions(extras);
        return getReactManager().createFragment(moduleName, props, options);
    }

    @Nullable
    private Bundle buildOptions(@NonNull ReadableMap extras) {
        if (extras.hasKey("options")) {
            return Arguments.toBundle(extras.getMap("options"));
        }
        return null;
    }

    @Nullable
    private Bundle buildProps(@NonNull ReadableMap extras) {
        if (extras.hasKey("props")) {
            return Arguments.toBundle(extras.getMap("props"));
        }
        return null;
    }

    private ReactManager getReactManager() {
        return ReactManager.get();
    }
}
