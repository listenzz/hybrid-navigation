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

    @NonNull
    String name();

    @NonNull
    List<String> supportActions();

    @Nullable
    AwesomeFragment createFragment(@NonNull ReadableMap layout);

    boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal);

    HybridFragment primaryFragment(@NonNull AwesomeFragment fragment);

    void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull ReadableMap extras);

}
