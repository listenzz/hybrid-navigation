package com.reactnative.hybridnavigation.navigator;

import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.navigation.androidx.StackFragment;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TransitionAnimation;
import com.reactnative.hybridnavigation.HybridFragment;
import com.reactnative.hybridnavigation.Navigator;
import com.reactnative.hybridnavigation.ReactBridgeManager;
import com.reactnative.hybridnavigation.ReactStackFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StackNavigator implements Navigator {

    private final List<String> supportActions = Arrays.asList("push", "pushLayout", "pop", "popTo", "popToRoot", "redirectTo");

    @Override
    @NonNull
    public String name() {
        return "stack";
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

        ReadableMap stack = layout.getMap(name());
        if (stack == null) {
            throw new IllegalArgumentException("stack should be an object.");
        }

        ReadableArray children = stack.getArray("children");
        if (children == null) {
            throw new IllegalArgumentException("children is required, and it is an array.");
        }

        ReadableMap root = children.getMap(0);
        AwesomeFragment rootFragment = getReactBridgeManager().createFragment(root);
        if (rootFragment == null) {
            throw new IllegalArgumentException("can't create stack component with " + layout);
        }

        ReactStackFragment stackFragment = new ReactStackFragment();
        stackFragment.setRootFragment(rootFragment);
        return stackFragment;
    }

    @Nullable
    @Override
    public Bundle buildRouteGraph(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof StackFragment) || !fragment.isAdded()) {
            return null;
        }

        StackFragment stack = (StackFragment) fragment;
        ArrayList<Bundle> children = buildChildrenGraph(stack);
        Bundle graph = new Bundle();
        graph.putString("layout", name());
        graph.putString("sceneId", stack.getSceneId());
        graph.putParcelableArrayList("children", children);
        graph.putString("mode", Navigator.Util.getMode(fragment));
        return graph;
    }

    @NonNull
    private ArrayList<Bundle> buildChildrenGraph(StackFragment stack) {
        ArrayList<Bundle> children = new ArrayList<>();
        List<AwesomeFragment> fragments = stack.getChildAwesomeFragments();
        for (int i = 0; i < fragments.size(); i++) {
            AwesomeFragment child = fragments.get(i);
            Bundle graph = getReactBridgeManager().buildRouteGraph(child);
            if (graph != null) {
                children.add(graph);
            }
        }
        return children;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (!(fragment instanceof StackFragment) || !fragment.isAdded()) {
            return null;
        }
        StackFragment stack = (StackFragment) fragment;
        return getReactBridgeManager().primaryFragment(stack.getTopFragment());
    }
    
    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Callback callback) {
        StackFragment stackFragment = getStackFragment(target);
        if (stackFragment == null) {
            callback.invoke(null, false);
            return;
        }

        switch (action) {
            case "push":
                handlePush(stackFragment, extras, callback);
                break;
            case "pop":
                stackFragment.popFragment(() -> callback.invoke(null, true));
                break;
            case "popTo":
                handlePopTo(stackFragment, extras, callback);
                break;
            case "popToRoot":
                stackFragment.popToRootFragment(() -> callback.invoke(null,true));
                break;
            case "redirectTo":
                handleRedirectTo(stackFragment, extras, target, callback);
                break;
            case "pushLayout":
                handlePushLayout(stackFragment, extras, callback);
                break;
        }
    }

    private void handlePushLayout(@NonNull StackFragment stackFragment, @NonNull ReadableMap extras, @NonNull Callback callback) {
        ReadableMap layout = extras.getMap("layout");
        AwesomeFragment fragment = getReactBridgeManager().createFragment(layout);
        if (fragment == null) {
            callback.invoke(null, false);
            return;
        }
        stackFragment.pushFragment(fragment, () -> callback.invoke(null, true));
    }

    private void handleRedirectTo(@NonNull StackFragment stackFragment, @NonNull ReadableMap extras, @NonNull AwesomeFragment target, @NonNull Callback callback) {
        AwesomeFragment fragment = createFragmentWithExtras(extras);
        if (fragment == null) {
            callback.invoke(null, false);
            return;
        }
        stackFragment.redirectToFragment(fragment, () -> callback.invoke(null, true), TransitionAnimation.Redirect, target);
    }

    private void handlePopTo(@NonNull StackFragment stackFragment, @NonNull ReadableMap extras, @NonNull Callback callback) {
        String moduleName = extras.getString("moduleName");
        if (moduleName == null) {
            callback.invoke(null, false);
            return;
        }
        
        FragmentManager fragmentManager = stackFragment.getChildFragmentManager();
        AwesomeFragment fragment = findFragmentForPopTo(moduleName, inclusive(extras), fragmentManager);
        if (fragment == null) {
            callback.invoke(null, false);
            return;
        }

        stackFragment.popToFragment(fragment, () -> callback.invoke(null, true));
    }
    
    private boolean inclusive(@NonNull ReadableMap extras) {
        if (extras.hasKey("inclusive")) {
            return extras.getBoolean("inclusive");
        }
        return false;
    }

    @Nullable
    private AwesomeFragment findFragmentForPopTo(String moduleName, boolean inclusive, FragmentManager fragmentManager) {
        int count = fragmentManager.getBackStackEntryCount();
        for (int i = count - 1; i > -1; i--) {
            FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(i);
            if (TextUtils.isEmpty(entry.getName())) {
                continue;
            }

            Fragment fragment = fragmentManager.findFragmentByTag(entry.getName());
            if (!(fragment instanceof HybridFragment)) {
                continue;
            }

            HybridFragment hybridFragment = (HybridFragment) fragment;
            boolean match = moduleName.equals(hybridFragment.getModuleName()) || moduleName.equals(hybridFragment.getSceneId());
            if (!match) {
                continue;
            }

            if (inclusive && i > 0) {
                FragmentManager.BackStackEntry e = fragmentManager.getBackStackEntryAt(i - 1);
                return (AwesomeFragment) fragmentManager.findFragmentByTag(e.getName());
            }
            return hybridFragment;
        }

        return null;
    }

    private void handlePush(@NonNull StackFragment stackFragment, @NonNull ReadableMap extras, @NonNull Callback callback) {
        AwesomeFragment fragment = createFragmentWithExtras(extras);
        if (fragment == null) {
            callback.invoke(null, false);
            return;
        }
        stackFragment.pushFragment(fragment, () -> callback.invoke(null, true));
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
        return getReactBridgeManager().createFragment(moduleName, props, options);
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

    private StackFragment getStackFragment(AwesomeFragment fragment) {
        if (fragment == null) {
            return null;
        }

        StackFragment stackFragment = fragment.getStackFragment();
        if (stackFragment != null) {
            return stackFragment;
        }

        return stackFragmentFromDrawerIfExist(fragment);
    }

    @Nullable
    private StackFragment stackFragmentFromDrawerIfExist(AwesomeFragment fragment) {
        DrawerFragment drawerFragment = fragment.getDrawerFragment();
        if (drawerFragment == null) {
            return null;
        }

        TabBarFragment tabBarFragment = drawerFragment.requireContentFragment().getTabBarFragment();
        if (tabBarFragment != null) {
            return tabBarFragment.requireSelectedFragment().getStackFragment();
        }

        return drawerFragment.requireContentFragment().getStackFragment();
    }

    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }
}
