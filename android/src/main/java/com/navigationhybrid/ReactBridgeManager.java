package com.navigationhybrid;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.UiThread;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;

/**
 * Created by Listen on 2017/11/17.
 */

public class ReactBridgeManager {

    public static String REACT_MODULE_REGISTRY_COMPLETED_BROADCAST = "registry_completed";

    public interface ReactModuleRegistryListener {
        void onReactModuleRegistryCompleted();
    }

    private static final String TAG = "ReactNative";

    public static ReactBridgeManager instance = new ReactBridgeManager();

    private HashMap<String, Class<? extends HybridFragment>> nativeModules = new HashMap<>();
    private HashMap<String, ReadableMap> reactModules = new HashMap<>();
    private CopyOnWriteArrayList<ReactModuleRegistryListener> reactModuleRegistryListeners = new CopyOnWriteArrayList<>();

    private boolean isReactModuleInRegistry = true;

    private ReadableMap rootLayout;

    public ReactBridgeManager() {

    }

    public void install(@NonNull ReactNativeHost reactNativeHost) {
        this.reactNativeHost = reactNativeHost;
        this.setup();
    }

    public void registerNativeModule(String moduleName, Class<? extends HybridFragment> clazz) {
        nativeModules.put(moduleName, clazz);
    }

    public boolean hasNativeModule(String moduleName) {
        return nativeModules.containsKey(moduleName);
    }

    public Class<? extends HybridFragment> nativeModuleClassForName(String moduleName) {
        return nativeModules.get(moduleName);
    }

    public void registerReactModule(String moduleName, ReadableMap options) {
        reactModules.put(moduleName, options);
    }

    public boolean isReactModuleInRegistry() {
        return isReactModuleInRegistry;
    }

    @UiThread
    public void startRegisterReactModule() {
        reactModules.clear();
        isReactModuleInRegistry = true;
    }

    @UiThread
    public void endRegisterReactModule() {
        isReactModuleInRegistry = false;
        for (ReactModuleRegistryListener listener : reactModuleRegistryListeners) {
            listener.onReactModuleRegistryCompleted();
        }
        Context context = getReactInstanceManager().getCurrentReactContext();
        if (context != null) {
            Intent intent = new Intent(REACT_MODULE_REGISTRY_COMPLETED_BROADCAST);
            LocalBroadcastManager.getInstance(context.getApplicationContext()).sendBroadcast(intent);
        }
    }

    @UiThread
    public void addReactModuleRegistryListener(ReactModuleRegistryListener listener) {
        reactModuleRegistryListeners.add(listener);
    }

    @UiThread
    public void removeReactModuleRegistryListener(ReactModuleRegistryListener listener) {
        reactModuleRegistryListeners.remove(listener);
    }

    public boolean hasReactModule(String moduleName) {
        return reactModules.containsKey(moduleName);
    }

    public ReadableMap reactModuleOptionsForKey(String moduleName) {
        return reactModules.get(moduleName);
    }

    public void sendEvent(String eventName, WritableMap data) {
        DeviceEventManagerModule.RCTDeviceEventEmitter emitter = getReactInstanceManager().getCurrentReactContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
        emitter.emit(eventName, data);
    }

    public void sendEvent(String eventName) {
        sendEvent(eventName, Arguments.createMap());
    }


    ReactNativeHost getReactNativeHost() {
        checkReactNativeHost();
        return reactNativeHost;
    }

    public ReactInstanceManager getReactInstanceManager() {
        checkReactNativeHost();
        return reactNativeHost.getReactInstanceManager();
    }

    private ReactNativeHost reactNativeHost;


    private void setup() {
        final ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        reactInstanceManager.addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
            @Override
            public void onReactContextInitialized(ReactContext context) {
                Log.i(TAG, toString() + " react context initialized:" + Thread.currentThread().getName());
                rootLayout = null;
            }
        });
        reactInstanceManager.createReactContextInBackground();
    }

    private void checkReactNativeHost() {
        if (reactNativeHost == null) {
            throw new IllegalStateException("must call ReactBridgeManager#install first");
        }
    }

    public void setRootLayout(ReadableMap root) {
        if (!hasRootLayout()) {
            this.rootLayout = root;
        }
    }

    public ReadableMap getRootLayout() {
        return this.rootLayout;
    }

    public boolean hasRootLayout() {
        return rootLayout != null;
    }

    public AwesomeFragment createFragment(ReadableMap layout) {

        if (layout.hasKey("screen")) {
            ReadableMap screen = layout.getMap("screen");
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
            return createFragment(moduleName, props, options);
        }

        if (layout.hasKey("stack")) {
            ReadableMap stack = layout.getMap("stack");
            AwesomeFragment awesomeFragment = createFragment(stack);
            if (awesomeFragment != null) {
                ReactNavigationFragment reactNavigationFragment = new ReactNavigationFragment();
                reactNavigationFragment.setRootFragment(awesomeFragment);
                return reactNavigationFragment;
            }
        }

        if (layout.hasKey("tabs")) {
            ReadableArray tabs = layout.getArray("tabs");
            List<AwesomeFragment> fragments = new ArrayList<>();
            for (int i = 0, size = tabs.size(); i < size; i++) {
                ReadableMap tab = tabs.getMap(i);
                AwesomeFragment awesomeFragment = createFragment(tab);
                if (awesomeFragment != null) {
                    fragments.add(awesomeFragment);
                }
            }
            if (fragments.size() > 0) {
                ReactTabBarFragment tabBarFragment = new ReactTabBarFragment();
                tabBarFragment.setFragments(fragments);
                return tabBarFragment;
            }
        }

        if (layout.hasKey("drawer")) {
            ReadableArray drawer = layout.getArray("drawer");
            if (drawer.size() == 2) {
                ReadableMap content = drawer.getMap(0);
                ReadableMap menu = drawer.getMap(1);
                AwesomeFragment contentFragment = createFragment(content);
                AwesomeFragment menuFragment = createFragment(menu);
                if (contentFragment != null && menuFragment != null) {
                    ReactDrawerFragment drawerFragment = new ReactDrawerFragment();
                    drawerFragment.setMenuFragment(menuFragment);
                    drawerFragment.setContentFragment(contentFragment);
                    if (menu.hasKey("options")) {
                        ReadableMap options = menu.getMap("options");
                        if (options.hasKey("maxDrawerWidth")) {
                            int maxDrawerWidth = options.getInt("maxDrawerWidth");
                            drawerFragment.setMaxDrawerWidth(maxDrawerWidth);
                        }

                        if (options.hasKey("minDrawerMargin")) {
                            int minDrawerMargin = options.getInt("minDrawerMargin");
                            drawerFragment.setMinDrawerMargin(minDrawerMargin);
                        }
                    }

                    return drawerFragment;
                }
            }
        }
        return null;
    }

    public AwesomeFragment createFragment(@NonNull String moduleName) {
        return createFragment(moduleName, null, null);
    }

    public AwesomeFragment createFragment(@NonNull String moduleName, Bundle props, Bundle options) {
        HybridFragment fragment = null;

        if (hasReactModule(moduleName)) {
            fragment = new ReactFragment();
        } else {
            Class<? extends HybridFragment> fragmentClass = nativeModuleClassForName(moduleName);
            if (fragmentClass == null) {
                throw new IllegalArgumentException("未能找到名为 " + moduleName + " 的模块，你是否忘了注册？");
            }
            try {
                fragment = fragmentClass.newInstance();
            } catch (Exception e) {
                // ignore
            }
        }

        if (fragment != null) {
            if (options == null) {
                options = new Bundle();
            }

            if (props == null) {
                props = new Bundle();
            }

            if (hasReactModule(moduleName)) {
                ReadableMap readableMap = reactModuleOptionsForKey(moduleName);
                if (readableMap == null) {
                    readableMap = Arguments.createMap();
                }
                WritableMap writableMap = Arguments.createMap();
                writableMap.merge(readableMap);
                writableMap.merge(Arguments.fromBundle(options));
                options = Arguments.toBundle(writableMap);
            }

            Bundle args = FragmentHelper.getArguments(fragment);
            args.putBundle(Constants.ARG_PROPS, props);
            args.putBundle(Constants.ARG_OPTIONS, options);
            args.putString(Constants.ARG_MODULE_NAME, moduleName);
            fragment.setArguments(args);

        }

        return fragment;
    }

}
