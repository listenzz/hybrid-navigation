package com.navigationhybrid;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.FragmentManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.HashMap;
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

public class NavigatorModule extends ReactContextBaseJavaModule {

    static final String TAG = "ReactNative";

    private final Handler handler = new Handler(Looper.getMainLooper());

    private final ReactBridgeManager reactBridgeManager;


    NavigatorModule(ReactApplicationContext reactContext, ReactBridgeManager reactBridgeManager) {
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
    public void setRoot(final ReadableMap layout) {
        Runnable setRootTask = new Runnable() {
            @Override
            public void run() {
                reactBridgeManager.setRootLayout(layout);
                Activity activity = getCurrentActivity();
                if (activity instanceof ReactAppCompatActivity) {
                    ReactAppCompatActivity reactAppCompatActivity = (ReactAppCompatActivity) activity;
                    AwesomeFragment awesomeFragment = reactBridgeManager.createFragment(layout);
                    if (awesomeFragment != null) {
                        reactAppCompatActivity.setRootFragment(awesomeFragment);
                    }
                } else {
                    handler.post(this);
                }
            }
        };
        handler.post(setRootTask);
    }

    @ReactMethod
    public void push(final String sceneId, final String moduleName, final ReadableMap props, final ReadableMap options, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = fragment.getNavigationFragment();
                    if (navigationFragment != null) {
                        AwesomeFragment target = reactBridgeManager.createFragment(moduleName, Arguments.toBundle(props), Arguments.toBundle(options));
                        navigationFragment.pushFragment(target);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void pop(final String sceneId, final boolean animated) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                AwesomeFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null) {
                    NavigationFragment navigationFragment = fragment.getNavigationFragment();
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
                    NavigationFragment navigationFragment = fragment.getNavigationFragment();
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
                    NavigationFragment navigationFragment = fragment.getNavigationFragment();
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
                HybridFragment fragment = (HybridFragment) findFragmentBySceneId(sceneId);
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
                    NavigationFragment navigationFragment = fragment.getNavigationFragment();
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
                    NavigationFragment navigationFragment = fragment.getNavigationFragment();
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
