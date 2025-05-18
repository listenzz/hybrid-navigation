package com.reactnative.hybridnavigation;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.PresentationStyle;

import java.util.List;

public interface Navigator {

    String MODE_NORMAL = "normal";
    String MODE_MODAL = "modal";
    String MODE_PRESENT = "present";

    class Util {
        public static String getMode(@NonNull AwesomeFragment fragment) {
            if (fragment.getPresentationStyle() == PresentationStyle.OverFullScreen) {
                return MODE_MODAL;
            } else if (fragment.getPresentingFragment() != null) {
                return MODE_PRESENT;
            } else {
                return MODE_NORMAL;
            }
        }
    }

    @NonNull
    String name();

    @NonNull
    List<String> supportActions();

    @Nullable
    AwesomeFragment createFragment(@NonNull ReadableMap layout);

    @Nullable
    Bundle buildRouteGraph(@NonNull AwesomeFragment fragment);

    @Nullable
    HybridFragment primaryFragment(@NonNull AwesomeFragment fragment);

    void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Callback callback);

}
