package com.navigationhybrid.navigator;

import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.DrawerFragment;
import com.navigation.androidx.NavigationFragment;
import com.navigation.androidx.TabBarFragment;
import com.navigationhybrid.HybridFragment;
import com.navigationhybrid.ReactBridgeManager;
import com.navigationhybrid.ReactNavigationFragment;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StackNavigator implements Navigator {

    private List<String> supportActions = Arrays.asList("push", "pushLayout", "pop", "popTo", "popToRoot", "redirectTo");

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
        if (layout.hasKey(name())) {
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
            if (rootFragment != null) {
                ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
                reactNavigationFragment.setRootFragment(rootFragment);
                return reactNavigationFragment;
            } else {
                throw new IllegalArgumentException("can't create stack component with " + layout);
            }
        }
        return null;
    }

    @Override
    public boolean buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment instanceof NavigationFragment && fragment.isAdded()) {
            NavigationFragment stack = (NavigationFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = stack.getChildFragments();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                if (!child.getShowsDialog()) {
                    getReactBridgeManager().buildRouteGraph(child, children, modal);
                }
            }
            Bundle graph = new Bundle();
            graph.putString("layout", name());
            graph.putString("sceneId", stack.getSceneId());
            graph.putParcelableArrayList("children", children);
            graph.putString("mode", Navigator.Util.getMode(fragment));
            root.add(graph);
            return true;
        }
        return false;
    }

    @Override
    public HybridFragment primaryFragment(@NonNull AwesomeFragment fragment) {
        if (fragment instanceof NavigationFragment && fragment.isAdded()) {
            NavigationFragment stack = (NavigationFragment) fragment;
            return getReactBridgeManager().primaryFragment(stack.getTopFragment());
        }
        return null;
    }

    @Override
    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Promise promise) {
        NavigationFragment navigationFragment = getNavigationFragment(target);
        if (navigationFragment == null) {
            promise.resolve(false);
            return;
        }

        AwesomeFragment fragment = null;

        switch (action) {
            case "push":
                fragment = createFragmentWithExtras(extras);
                if (fragment != null) {
                    navigationFragment.pushFragment(fragment, true, () -> promise.resolve(true));
                } else {
                    promise.resolve(false);
                }
                break;
            case "pop":
                navigationFragment.popFragment(true, () -> promise.resolve(true));
                break;
            case "popTo":
                String moduleName = extras.getString("moduleName");
                FragmentManager fragmentManager = navigationFragment.getChildFragmentManager();
                int count = fragmentManager.getBackStackEntryCount();
                for (int i = count - 1; i > -1; i--) {
                    FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(i);
                    if (!TextUtils.isEmpty(entry.getName())) {
                        Fragment f = fragmentManager.findFragmentByTag(entry.getName());
                        if (f instanceof HybridFragment) {
                            HybridFragment hybridFragment = (HybridFragment) f;
                            if (moduleName != null
                                    && (moduleName.equals(hybridFragment.getModuleName()) || moduleName.equals(hybridFragment.getSceneId()))) {
                                fragment = hybridFragment;
                                break;
                            }
                        }
                    }
                }

                if (fragment != null) {
                    navigationFragment.popToFragment(fragment, true, () -> promise.resolve(true));
                } else {
                    promise.resolve(false);
                }
                break;
            case "popToRoot":
                navigationFragment.popToRootFragment(true, () -> promise.resolve(true));
                break;
            case "redirectTo":
                fragment = createFragmentWithExtras(extras);
                if (fragment != null) {
                    navigationFragment.redirectToFragment(fragment, target, true, () -> promise.resolve(true));
                } else {
                    promise.resolve(false);
                }
                break;
            case "pushLayout":
                ReadableMap layout = extras.getMap("layout");
                fragment = getReactBridgeManager().createFragment(layout);
                if (fragment != null) {
                    navigationFragment.pushFragment(fragment, true, () -> promise.resolve(true));
                } else {
                    promise.resolve(false);
                }
                break;
        }
    }

    private AwesomeFragment createFragmentWithExtras(@NonNull ReadableMap extras) {
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
        return fragment;
    }

    private NavigationFragment getNavigationFragment(AwesomeFragment fragment) {
        if (fragment != null) {
            NavigationFragment navigationFragment = fragment.getNavigationFragment();
            if (navigationFragment == null && fragment.getDrawerFragment() != null) {
                DrawerFragment drawerFragment = fragment.getDrawerFragment();
                TabBarFragment tabBarFragment = drawerFragment.getContentFragment().getTabBarFragment();
                if (tabBarFragment != null) {
                    navigationFragment = tabBarFragment.getSelectedFragment().getNavigationFragment();
                } else {
                    navigationFragment = drawerFragment.getContentFragment().getNavigationFragment();
                }
            }
            return navigationFragment;
        }
        return null;
    }


    private ReactBridgeManager getReactBridgeManager() {
        return ReactBridgeManager.get();
    }
}
