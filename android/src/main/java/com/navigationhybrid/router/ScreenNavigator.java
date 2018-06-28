package com.navigationhybrid.router;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactNavigationFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import me.listenzz.navigation.AwesomeFragment;

public class ScreenNavigator implements Navigator {

    private List<String> supportActions = Arrays.asList("present", "dismiss", "showModal", "hideModal");

    @Override
    public String name() {
        return "screen";
    }

    @Override
    public List<String> supportActions() {
        return supportActions;
    }

    @Override
    @Nullable
    public AwesomeFragment createFragment(ReadableMap layout) {
        if (layout.hasKey(name())) {
            ReadableMap screen = layout.getMap(name());
            String moduleName = screen.getString("moduleName");
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
    public boolean buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> graph) {
        if (fragment instanceof HybridFragment) {
            HybridFragment screen = (HybridFragment) fragment;
            Bundle bundle = new Bundle();
            bundle.putString("type", name());
            Bundle route = new Bundle();
            route.putString("moduleName", screen.getModuleName());
            route.putString("sceneId", screen.getSceneId());
            bundle.putBundle(name(), route);
            graph.add(bundle);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryChildFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof HybridFragment) {
            return (HybridFragment) fragment;
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment fragment, @NonNull String action,  @NonNull Bundle extras) {
        String moduleName = extras.getString("moduleName");
        AwesomeFragment target = null;
        if (moduleName != null) {
            Bundle props = extras.getBundle("props");
            Bundle options = extras.getBundle("options");
            target = getReactBridgeManager().createFragment(moduleName, props, options);
        }
        switch (action) {
            case "present":
                if (target != null) {
                    int requestCode = (int) extras.getDouble("requestCode", 0);
                    ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
                    reactNavigationFragment.setRootFragment(target);
                    fragment.presentFragment(reactNavigationFragment, requestCode);
                }
                break;
            case "dismiss":
                fragment.dismissFragment();
                break;
            case "showModal":
                if (target != null) {
                    int requestCode = (int) extras.getDouble("requestCode", 0);
                    fragment.showDialog(target, requestCode);
                }
                break;
            case "hideModal":
                fragment.dismissDialog();
                break;

        }
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.instance;
    }
}
