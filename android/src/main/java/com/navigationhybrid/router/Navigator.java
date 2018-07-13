package com.navigationhybrid.router;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;

import java.util.ArrayList;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;

public interface Navigator {

    String name();

    List<String> supportActions();

    @Nullable
    AwesomeFragment createFragment(ReadableMap layout);

    boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> graph, ArrayList<Bundle> modalContainer);

    HybridFragment primaryChildFragment(@NonNull AwesomeFragment fragment);

    void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull Bundle extras);

}
