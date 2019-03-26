package com.navigationhybrid.navigator;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;

import java.util.ArrayList;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;

public interface Navigator {

    String MODE_NORMAL = "normal";
    String MODE_MODAL = "modal";
    String MODE_PRESENT = "present";

    class Util {
        public static String getMode(@NonNull AwesomeFragment fragment) {
            if (fragment.isInDialog()) {
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

    boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal);

    @Nullable
    HybridFragment primaryFragment(@NonNull AwesomeFragment fragment);

    void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras);

}
