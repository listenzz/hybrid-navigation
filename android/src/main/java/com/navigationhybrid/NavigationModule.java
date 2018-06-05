package com.navigationhybrid;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.DrawerFragment;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.TabBarFragment;


/**
 * Created by Listen on 2017/11/20.
 */
public class NavigationModule extends ReactContextBaseJavaModule {

    static final String TAG = "ReactNative";
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final ReactBridgeManager reactBridgeManager;

    NavigationModule(ReactApplicationContext reactContext, ReactBridgeManager reactBridgeManager) {
        super(reactContext);
        this.reactBridgeManager = reactBridgeManager;
    }

    @Override
    public String getName() {
        return "NavigationHybrid";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        HashMap<String, Object> constants = new HashMap<>();
        constants.put("RESULT_OK", Activity.RESULT_OK);
        constants.put("RESULT_CANCEL", Activity.RESULT_CANCELED);
        return constants;
    }

    @ReactMethod
    public void startRegisterReactComponent() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.startRegisterReactModule();
            }
        });
    }

    @ReactMethod
    public void endRegisterReactComponent() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.endRegisterReactModule();
            }
        });
    }

    @ReactMethod
    public void registerReactComponent(final String appKey, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.registerReactModule(appKey, options);
            }
        });
    }

    @ReactMethod
    public void signalFirstRenderComplete(final String sceneId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactFragment fragment = (ReactFragment) findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    fragment.signalFirstRenderComplete();
                }
            }
        });
    }

    @ReactMethod
    public void setRoot(final ReadableMap layout, final boolean sticky) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.setRootLayout(layout, sticky);
                Activity activity = getCurrentActivity();
                if (activity instanceof ReactAppCompatActivity) {
                    ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                    AwesomeFragment fragment = reactBridgeManager.createFragment(layout);
                    if (fragment != null) {
                        Log.i(TAG, "has active activity, set root directly");
                        reactAppCompatActivity.setActivityRootFragment(fragment);
                    }
                } else {
                    Log.w(TAG, "no active activity, schedule pending root");
                    reactBridgeManager.setPendingLayout(layout);
                }
            }
        });
    }

    @ReactMethod
    public void push(final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = getNavigationFragment(fragment);
                    if (navigationFragment != null) {
                        AwesomeFragment target = reactBridgeManager.createFragment(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                        navigationFragment.pushFragment(target);
                    }
                }
            }
        });
    }

    NavigationFragment getNavigationFragment(AwesomeFragment fragment) {
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

    @ReactMethod
    public void pop(final String sceneId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = getNavigationFragment(fragment);
                    if (navigationFragment != null) {
                        navigationFragment.popFragment();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void popTo(final String sceneId, final String targetId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = getNavigationFragment(fragment);
                    if (navigationFragment != null) {
                        AwesomeFragment target = (AwesomeFragment) navigationFragment.getChildFragmentManager().findFragmentByTag(targetId);
                        if (target != null) {
                            navigationFragment.popToFragment(target);
                        }
                    }
                }
            }
        });
    }

    @ReactMethod
    public void popToRoot(final String sceneId, boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = getNavigationFragment(fragment);
                    if (navigationFragment != null) {
                        navigationFragment.popToRootFragment();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void isRoot(final String sceneId, final Promise promise) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    promise.resolve(fragment.isNavigationRoot());
                }
            }
        });
    }

    @ReactMethod
    public void replace(final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = getNavigationFragment(fragment);
                    if (navigationFragment != null) {
                        AwesomeFragment target = reactBridgeManager.createFragment(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                        navigationFragment.replaceFragment(target);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void replaceToRoot(final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = getNavigationFragment(fragment);
                    if (navigationFragment != null) {
                        AwesomeFragment target = reactBridgeManager.createFragment(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                        navigationFragment.replaceToRootFragment(target);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void present(final String sceneId, final String moduleName, final int requestCode, final ReadableMap props, final ReadableMap options, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
                    AwesomeFragment awesomeFragment = reactBridgeManager.createFragment(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                    reactNavigationFragment.setRootFragment(awesomeFragment);
                    fragment.presentFragment(reactNavigationFragment, requestCode);
                }
            }
        });
    }

    @ReactMethod
    public void setResult(final String sceneId, final int resultCode, final ReadableMap result) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    fragment.setResult(resultCode, Arguments.toBundle(result));
                }
            }
        });
    }

    @ReactMethod
    public void dismiss(final String sceneId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    fragment.dismissFragment();
                }
            }
        });
    }

    @ReactMethod
    public void showModal(final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Activity activity = getCurrentActivity();
                if (activity instanceof ReactAppCompatActivity) {
                    ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                    FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
                    AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                    if (fragment != null) {
                        AwesomeFragment target = reactBridgeManager.createFragment(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                        target.show(fragmentManager, target.getSceneId());
                    }
                }
            }
        });

    }

    @ReactMethod
    public void hideModal(final String sceneId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    fragment.dismissDialog();
                }
            }
        });
    }


    @ReactMethod
    public void switchToTab(final String sceneId, final int index) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactFragment fragment = (ReactFragment) findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        AwesomeFragment presented = tabBarFragment.getPresentedFragment();
                        if (presented != null) {
                            presented.dismissFragment();
                        }
                        tabBarFragment.setSelectedIndex(index);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setTabBadge(final String sceneId, final int index, final String text) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                ReactFragment fragment = (ReactFragment) findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        AwesomeFragment presented = tabBarFragment.getPresentedFragment();
                        if (presented != null) {
                            presented.dismissFragment();
                        }
                        tabBarFragment.setBadge(index, text);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void toggleMenu(final String sceneId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
                if (awesomeFragment != null) {
                    DrawerFragment drawerFragment = awesomeFragment.getDrawerFragment();
                    if (drawerFragment != null) {
                        drawerFragment.toggleMenu();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void openMenu(final String sceneId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
                if (awesomeFragment != null) {
                    DrawerFragment drawerFragment = awesomeFragment.getDrawerFragment();
                    if (drawerFragment != null) {
                        drawerFragment.openMenu();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void closeMenu(final String sceneId) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
                if (awesomeFragment != null) {
                    DrawerFragment drawerFragment = awesomeFragment.getDrawerFragment();
                    if (drawerFragment != null) {
                        drawerFragment.closeMenu();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setMenuInteractive(final String sceneId, final boolean enabled) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment awesomeFragment = findFragmentBySceneId(sceneId);
                if (awesomeFragment != null) {
                    DrawerFragment drawerFragment = awesomeFragment.getDrawerFragment();
                    if (drawerFragment != null) {
                        drawerFragment.setDrawerLockMode(enabled ? DrawerLayout.LOCK_MODE_UNLOCKED : DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void currentRoute(Promise promise) {
        Activity activity = getCurrentActivity();
        if (activity == null || !(activity instanceof ReactAppCompatActivity)) {
            promise.reject("400", "Bad Request");
            return;
        }

        ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
        FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
        Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);
        HybridFragment current = getCurrentFragment(fragment);
        if (current != null) {
            Bundle bundle = new Bundle();
            bundle.putString("moduleName", current.getModuleName());
            bundle.putString("sceneId", current.getSceneId());
            promise.resolve(Arguments.fromBundle(bundle));
        } else {
            promise.reject("404", "Not Found");
        }
    }

    private HybridFragment getCurrentFragment(Fragment fragment) {
        if (fragment == null) {
            return null;
        }
        if (fragment instanceof DrawerFragment) {
            DrawerFragment drawer = (DrawerFragment) fragment;
            if (drawer.isMenuOpened()) {
                return getCurrentFragment(drawer.getMenuFragment());
            } else {
                return getCurrentFragment(drawer.getContentFragment());
            }
        } else if (fragment instanceof TabBarFragment) {
            TabBarFragment tabs = (TabBarFragment) fragment;
            return getCurrentFragment(tabs.getSelectedFragment());
        } else if (fragment instanceof NavigationFragment) {
            NavigationFragment stack = (NavigationFragment) fragment;
            return getCurrentFragment(stack.getTopFragment());
        } else if (fragment instanceof HybridFragment) {
            return (HybridFragment) fragment;
        }
        return null;
    }

    @ReactMethod
    public void routeGraph(Promise promise) {
        Activity activity = getCurrentActivity();
        if (activity == null || !(activity instanceof ReactAppCompatActivity)) {
            promise.reject("400", "Bad Request");
            return;
        }
        ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
        ArrayList<Bundle> container = new ArrayList<>();
        List<AwesomeFragment> fragments = reactAppCompatActivity.getFragmentsAtAddedList();
        for (int i = 0; i < fragments.size(); i++) {
            AwesomeFragment fragment = fragments.get(i);
            buildRouteGraph(fragment, container);
        }
        promise.resolve(Arguments.fromList(container));
    }

    private void buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> container) {
        if (fragment instanceof DrawerFragment) {
            DrawerFragment drawer = (DrawerFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            buildRouteGraph(drawer.getContentFragment(), children);
            buildRouteGraph(drawer.getMenuFragment(), children);
            Bundle bundle = new Bundle();
            bundle.putString("type", "drawer");
            bundle.putParcelableArrayList("drawer", children);
            container.add(bundle);
        } else if (fragment instanceof TabBarFragment) {
            TabBarFragment tabs = (TabBarFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = tabs.getChildFragments();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                buildRouteGraph(child, children);
            }
            Bundle bundle = new Bundle();
            bundle.putString("type", "tabs");
            bundle.putInt("selectedIndex", tabs.getSelectedIndex());
            bundle.putParcelableArrayList("tabs", children);
            container.add(bundle);
        } else if (fragment instanceof NavigationFragment) {
            NavigationFragment stack = (NavigationFragment) fragment;
            ArrayList<Bundle> children = new ArrayList<>();
            List<AwesomeFragment> fragments = stack.getChildFragmentsAtAddedList();
            for (int i = 0; i < fragments.size(); i++) {
                AwesomeFragment child = fragments.get(i);
                buildRouteGraph(child, children);
            }
            Bundle bundle = new Bundle();
            bundle.putString("type", "stack");
            bundle.putParcelableArrayList("stack", children);
            container.add(bundle);

        } else if (fragment instanceof HybridFragment) {
            HybridFragment screen = (HybridFragment) fragment;
            Bundle bundle = new Bundle();
            bundle.putString("type", "screen");
            Bundle route = new Bundle();
            route.putString("moduleName", screen.getModuleName());
            route.putString("sceneId", screen.getSceneId());
            bundle.putBundle("screen", route);
            container.add(bundle);
        } else {
            Log.w(TAG, "fragment do not add to route graph!!");
        }
    }


    private HybridFragment findFragmentBySceneId(String sceneId) {
        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactAppCompatActivity.getSupportFragmentManager();
            return findFragmentBySceneId(fragmentManager, sceneId);
        }
        return null;
    }

    private HybridFragment findFragmentBySceneId(FragmentManager fragmentManager, String sceneId) {
        return (HybridFragment) FragmentHelper.findDescendantFragment(fragmentManager, sceneId);
    }

}
