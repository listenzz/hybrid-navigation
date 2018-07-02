package com.navigationhybrid;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentManager;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.BarStyle;
import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.DrawerFragment;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.TabBar;
import me.listenzz.navigation.TabBarFragment;

import static com.navigationhybrid.Constants.TOP_BAR_STYLE_DARK_CONTENT;
import static com.navigationhybrid.Constants.TOP_BAR_STYLE_LIGHT_CONTENT;

/**
 * Created by Listen on 2017/11/22.
 */

public class GardenModule extends ReactContextBaseJavaModule {

    private static final String TAG = "ReactNative";

    static Bundle mergeOptions(@NonNull Bundle options, @NonNull String key, @NonNull ReadableMap readableMap) {
        Bundle subBundle = options.getBundle(key);
        if (subBundle == null) {
            subBundle = new Bundle();
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(subBundle));
        writableMap.merge(readableMap);
        return Arguments.toBundle(writableMap);
    }

    private final Handler handler = new Handler(Looper.getMainLooper());

    public GardenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "GardenHybrid";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("DARK_CONTENT", TOP_BAR_STYLE_DARK_CONTENT);
        constants.put("LIGHT_CONTENT", TOP_BAR_STYLE_LIGHT_CONTENT);
        constants.put("TOOLBAR_HEIGHT", 56);
        return constants;
    }

    @ReactMethod
    public void setStyle(final ReadableMap style) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Context context = getReactApplicationContext();
                if (context != null) {
                    Garden.createGlobalStyle(Arguments.toBundle(style));
                }
            }
        });
    }

    @ReactMethod
    public void setLeftBarButtonItem(final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle buttonItem = mergeOptions(options, "leftBarButtonItem", readableMap);
                    options.putBundle("leftBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setLeftBarButtonItem(buttonItem);
                }
            }
        });
    }

    @ReactMethod
    public void setRightBarButtonItem(final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle buttonItem = mergeOptions(options, "rightBarButtonItem", readableMap);
                    options.putBundle("rightBarButtonItem", buttonItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setRightBarButtonItem(buttonItem);
                }
            }
        });
    }

    @ReactMethod
    public void setTitleItem(final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    Bundle titleItem = mergeOptions(options, "titleItem", readableMap);
                    options.putBundle("titleItem", titleItem);
                    fragment.setOptions(options);
                    fragment.getGarden().setTitleItem(titleItem);
                }
            }
        });
    }

    @ReactMethod
    public void setStatusBarColor(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setStatusBarColor:" + readableMap);
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("statusBarColor")) {
                        String statusBarColor = readableMap.getString("statusBarColor");
                        options.putString("statusBarColor", statusBarColor);
                        fragment.getGarden().setStatusBarColor(Color.parseColor(statusBarColor));
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setTopBarStyle(final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("topBarStyle")) {
                        String barStyle = readableMap.getString("topBarStyle");
                        options.putString("topBarStyle", barStyle);
                        if (barStyle.equals("dark-content")) {
                            fragment.getGarden().setStatusBarStyle(BarStyle.DarkContent);
                        } else {
                            fragment.getGarden().setStatusBarStyle(BarStyle.LightContent);
                        }
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setTopBarAlpha(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setTopBarAlpha:" + readableMap);
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("topBarAlpha")) {
                        double topBarAlpha = readableMap.getDouble("topBarAlpha");
                        options.putDouble("topBarAlpha", topBarAlpha);
                        fragment.getGarden().setToolbarAlpha((float) topBarAlpha);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setTopBarColor(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setToolbarColor:" + readableMap);
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("topBarColor")) {
                        String topBarColor = readableMap.getString("topBarColor");
                        options.putString("topBarColor", topBarColor);
                        fragment.getGarden().setToolbarColor(Color.parseColor(topBarColor));
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setTopBarShadowHidden(final String sceneId, final ReadableMap readableMap) {
        Log.i(TAG, "setTopBarShadowHidden:" + readableMap);
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    Bundle options = fragment.getOptions();
                    if (readableMap.hasKey("topBarShadowHidden")) {
                        boolean topBarShadowHidden = readableMap.getBoolean("topBarShadowHidden");
                        options.putBoolean("topBarShadowHidden", topBarShadowHidden);
                        fragment.getGarden().setToolbarShadowHidden(topBarShadowHidden);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setBottomBarColor(final String sceneId, final ReadableMap readableMap) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (readableMap.hasKey("bottomBarColor")) {
                    String bottomBarColor = readableMap.getString("bottomBarColor");
                    HybridFragment fragment = findFragmentBySceneId(sceneId);
                    if (fragment != null && fragment.getView() != null) {
                        TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                        if (tabBarFragment != null) {
                            TabBar tabBar = tabBarFragment.getTabBar();
                            tabBar.setBarBackgroundColor(bottomBarColor);
                            tabBar.initialise();
                        }
                    }
                }
            }
        });
    }

    @ReactMethod
    public void replaceTabIcon(final String sceneId, final int index, final ReadableMap icon, final ReadableMap inactiveIcon) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                HybridFragment fragment = findFragmentBySceneId(sceneId);
                if (fragment != null && fragment.getView() != null) {
                    TabBarFragment tabBarFragment = fragment.getTabBarFragment();
                    if (tabBarFragment != null) {
                        TabBar tabBar = tabBarFragment.getTabBar();
                        Drawable drawable = drawableFromReadableMap(tabBar.getContext(), icon);
                        if (drawable == null) {
                            return;
                        }
                        Drawable inactiveDrawable = drawableFromReadableMap(tabBar.getContext(), inactiveIcon);
                        tabBar.setTabIcon(index, drawable, inactiveDrawable);
                        AwesomeFragment f = tabBarFragment.getChildFragments().get(index);
                        f.getTabBarItem().iconUri = icon.getString("uri");
                        if (inactiveIcon != null && inactiveIcon.hasKey("uri")) {
                            f.getTabBarItem().inactiveIconUri = inactiveIcon.getString("uri");
                        }
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
                        TabBar tabBar = tabBarFragment.getTabBar();
                        tabBar.setBadge(index, text);
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

    private Drawable drawableFromReadableMap(Context context, ReadableMap icon) {
        if (icon != null && icon.hasKey("uri")) {
            String uri = icon.getString("uri");
            return DrawableCompat.wrap(DrawableUtils.fromUri(context, uri));
        }
        return null;
    }

    private HybridFragment findFragmentBySceneId(String sceneId) {
        Activity activity = getCurrentActivity();
        if (activity instanceof ReactAppCompatActivity) {
            ReactAppCompatActivity reactActivity = (ReactAppCompatActivity) activity;
            FragmentManager fragmentManager = reactActivity.getSupportFragmentManager();
            return findFragmentBySceneId(fragmentManager, sceneId);
        }
        return null;
    }

    private HybridFragment findFragmentBySceneId(FragmentManager fragmentManager, String sceneId) {
        return (HybridFragment) FragmentHelper.findDescendantFragment(fragmentManager, sceneId);
    }

}
