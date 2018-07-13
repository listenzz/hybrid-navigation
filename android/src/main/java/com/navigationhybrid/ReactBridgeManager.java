package com.navigationhybrid;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.UiThread;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.navigationhybrid.router.DrawerNavigator;
import com.navigationhybrid.router.Navigator;
import com.navigationhybrid.router.ScreenNavigator;
import com.navigationhybrid.router.StackNavigator;
import com.navigationhybrid.router.TabNavigator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.TabBarItem;

/**
 * Created by Listen on 2017/11/17.
 */

public class ReactBridgeManager {

    public static String REACT_MODULE_REGISTRY_COMPLETED_BROADCAST = "registry_completed";
    public static String REACT_INSTANCE_CONTEXT_INITIALIZED = "context_initialized";

    public interface ReactModuleRegistryListener {
        void onReactModuleRegistryCompleted();
    }

    private static final String TAG = "ReactNative";
    public static ReactBridgeManager instance = new ReactBridgeManager();

    private ReactBridgeManager() {
        registerNavigator(new ScreenNavigator());
        registerNavigator(new StackNavigator());
        registerNavigator(new TabNavigator());
        registerNavigator(new DrawerNavigator());
    }

    private HashMap<String, Class<? extends HybridFragment>> nativeModules = new HashMap<>();
    private HashMap<String, ReadableMap> reactModules = new HashMap<>();
    private CopyOnWriteArrayList<ReactModuleRegistryListener> reactModuleRegistryListeners = new CopyOnWriteArrayList<>();

    private ReadableMap rootLayout;
    private ReadableMap stickyLayout;
    private ReadableMap pendingLayout;

    private ReactNativeHost reactNativeHost;

    public void install(@NonNull ReactNativeHost reactNativeHost) {
        this.reactNativeHost = reactNativeHost;
        this.setup();
    }

    private void setup() {
        final ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        reactInstanceManager.addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
            @Override
            public void onReactContextInitialized(ReactContext context) {
                Log.i(TAG, "react instance context initialized.");
                rootLayout = null;
                stickyLayout = null;
                pendingLayout = null;

                if (context != null) {
                    Intent intent = new Intent(REACT_INSTANCE_CONTEXT_INITIALIZED);
                    LocalBroadcastManager.getInstance(context.getApplicationContext()).sendBroadcast(intent);
                }
            }
        });
        reactInstanceManager.createReactContextInBackground();
    }

    ReactNativeHost getReactNativeHost() {
        checkReactNativeHost();
        return reactNativeHost;
    }

    public ReactInstanceManager getReactInstanceManager() {
        checkReactNativeHost();
        return reactNativeHost.getReactInstanceManager();
    }

    private void checkReactNativeHost() {
        if (reactNativeHost == null) {
            throw new IllegalStateException("must call ReactBridgeManager#install first");
        }
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

    public boolean hasReactModule(String moduleName) {
        return reactModules.containsKey(moduleName);
    }

    public ReadableMap reactModuleOptionsForKey(String moduleName) {
        return reactModules.get(moduleName);
    }

    private boolean isReactModuleInRegistry = true;

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
        Log.i(TAG, "react module registry completed");
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

    public void sendEvent(String eventName, WritableMap data) {
        if (!isReactModuleInRegistry) {
            ReactContext reactContext = getReactInstanceManager().getCurrentReactContext();
            if (reactContext != null) {
                DeviceEventManagerModule.RCTDeviceEventEmitter emitter = reactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
                emitter.emit(eventName, data);
            }
        }
    }

    public void sendEvent(String eventName) {
        sendEvent(eventName, Arguments.createMap());
    }

    public void setRootLayout(ReadableMap root, boolean sticky) {
        if (sticky && !hasStickyLayout()) {
            this.stickyLayout = root;
        }
        this.rootLayout = root;
    }

    public ReadableMap getRootLayout() {
        return this.rootLayout;
    }

    public boolean hasRootLayout() {
        return rootLayout != null;
    }

    public ReadableMap getStickyLayout() {
        return stickyLayout;
    }

    public boolean hasStickyLayout() {
        return stickyLayout != null;
    }

    public void setPendingLayout(ReadableMap pendingLayout) {
        this.pendingLayout = pendingLayout;
    }

    public ReadableMap getPendingLayout() {
        return pendingLayout;
    }

    public boolean hasPendingLayout() {
        return pendingLayout != null;
    }

    public AwesomeFragment createFragment(ReadableMap layout) {
        AwesomeFragment fragment = null;
        for (Navigator navigator : navigators) {
            fragment = navigator.createFragment(layout);
            if (fragment != null) {
                break;
            }
        }
        return fragment;
    }

    public void buildRouteGraph(AwesomeFragment fragment, ArrayList<Bundle> graph, ArrayList<Bundle> modalContainer) {
        List<AwesomeFragment> children = fragment.getChildFragmentsAtAddedList();
        if (children.size() > 0) {
            for (int i = 0; i < children.size(); i ++) {
                AwesomeFragment child = children.get(i);
                if (child.getShowsDialog()) {
                    for (Navigator navigator : navigators) {
                        if (navigator.buildRouteGraph(child, modalContainer, modalContainer)) {
                            break;
                        }
                    }
                }
            }
        }

        for (Navigator navigator : navigators) {
            if (navigator.buildRouteGraph(fragment, graph, modalContainer)) {
                break;
            }
        }
    }

    public HybridFragment primaryChildFragment(AwesomeFragment f) {
        List<AwesomeFragment> children = f.getChildFragmentsAtAddedList();
        if (children.size() > 0) {
            AwesomeFragment last = children.get(children.size() -1);
            if (last.getShowsDialog()) {
                f = last;
            }
        }

        HybridFragment fragment = null;
        for (Navigator navigator : navigators) {
            fragment = navigator.primaryChildFragment(f);
            if (fragment != null) {
                break;
            }
        }
        return fragment;
    }

    public void handleNavigation(@Nullable AwesomeFragment fragment, @NonNull String action, @NonNull Bundle extras) {
        if (fragment == null) {
            return;
        }
        for (Navigator navigator : navigators) {
            List<String> supportActions = navigator.supportActions();
            if (supportActions.contains(action)) {
                navigator.handleNavigation(fragment, action, extras);
                break;
            }
        }
    }

    @Nullable
    public HybridFragment createFragment(@NonNull String moduleName) {
        return createFragment(moduleName, null, null);
    }

    @Nullable
    public HybridFragment createFragment(@NonNull String moduleName, Bundle props, Bundle options) {
        if (isReactModuleInRegistry()) {
            throw new IllegalStateException("模块还没有注册完，不能执行此操作");
        }

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

            if (options != null) {
                Bundle tabItem = options.getBundle("tabItem");
                if (tabItem != null) {
                    String title = tabItem.getString("title");
                    Bundle icon = tabItem.getBundle("icon");
                    String uri = null;
                    if (icon != null) {
                        uri = icon.getString("uri");
                    }
                    TabBarItem tabBarItem = new TabBarItem(uri, title);

                    Bundle inactiveIcon = tabItem.getBundle("inactiveIcon");
                    if (inactiveIcon != null) {
                        tabBarItem.inactiveIconUri = inactiveIcon.getString("uri");
                    }
                    fragment.setTabBarItem(tabBarItem);
                }
            }

            Bundle args = FragmentHelper.getArguments(fragment);
            args.putBundle(Constants.ARG_PROPS, props);
            args.putBundle(Constants.ARG_OPTIONS, options);
            args.putString(Constants.ARG_MODULE_NAME, moduleName);
            fragment.setArguments(args);

        }

        return fragment;
    }

    private List<Navigator> navigators = new ArrayList<>();

    public void registerNavigator(Navigator navigator) {
        navigators.add(0, navigator);
    }
}
