package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.UiThread;
import android.support.v4.app.FragmentManager;
import android.util.Log;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.navigationhybrid.navigator.DrawerNavigator;
import com.navigationhybrid.navigator.Navigator;
import com.navigationhybrid.navigator.ScreenNavigator;
import com.navigationhybrid.navigator.StackNavigator;
import com.navigationhybrid.navigator.TabNavigator;

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
@UiThread
public class ReactBridgeManager {

    public interface ReactModuleRegisterListener {
        void onReactModuleRegisterCompleted();
    }

    private static final String TAG = "ReactNative";
    private final static ReactBridgeManager instance = new ReactBridgeManager();

    public static ReactBridgeManager get() {
        return instance;
    }

    private ReactBridgeManager() {
        registerNavigator(new ScreenNavigator());
        registerNavigator(new StackNavigator());
        registerNavigator(new TabNavigator());
        registerNavigator(new DrawerNavigator());
    }

    private final HashMap<String, Class<? extends HybridFragment>> nativeModules = new HashMap<>();
    private final HashMap<String, ReadableMap> reactModules = new HashMap<>();
    private final CopyOnWriteArrayList<ReactModuleRegisterListener> reactModuleRegisterListeners = new CopyOnWriteArrayList<>();

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
        reactInstanceManager.addReactInstanceEventListener(context -> {
            Log.i(TAG, "react instance context initialized.");
            rootLayout = null;
            stickyLayout = null;
            pendingLayout = null;
        });

        if (!reactInstanceManager.hasStartedCreatingInitialContext()) {
            Log.i(TAG, "create react context");
            reactInstanceManager.createReactContextInBackground();
        }
    }

    @NonNull
    public ReactNativeHost getReactNativeHost() {
        checkReactNativeHost();
        return reactNativeHost;
    }

    @NonNull
    public ReactInstanceManager getReactInstanceManager() {
        checkReactNativeHost();
        return reactNativeHost.getReactInstanceManager();
    }

    @Nullable
    public ReactContext getReactContext() {
        return getReactInstanceManager().getCurrentReactContext();
    }

    private void checkReactNativeHost() {
        if (reactNativeHost == null) {
            throw new IllegalStateException("must call ReactBridgeManager#install first");
        }
    }

    public void registerNativeModule(@NonNull String moduleName, @NonNull Class<? extends HybridFragment> clazz) {
        nativeModules.put(moduleName, clazz);
    }

    public boolean hasNativeModule(@NonNull String moduleName) {
        return nativeModules.containsKey(moduleName);
    }

    @Nullable
    public Class<? extends HybridFragment> nativeModuleClassForName(@NonNull String moduleName) {
        return nativeModules.get(moduleName);
    }

    public void registerReactModule(@NonNull String moduleName, @Nullable ReadableMap options) {
        reactModules.put(moduleName, options);
    }

    public boolean hasReactModule(@NonNull String moduleName) {
        return reactModules.containsKey(moduleName);
    }

    @Nullable
    public ReadableMap reactModuleOptionsForKey(@NonNull String moduleName) {
        return reactModules.get(moduleName);
    }

    private boolean reactModuleRegisterCompleted = false;

    public boolean isReactModuleRegisterCompleted() {
        return reactModuleRegisterCompleted;
    }

    public void setReactModuleRegisterCompleted(boolean reactModuleRegisterCompleted) {
        this.reactModuleRegisterCompleted = reactModuleRegisterCompleted;
    }

    public void startRegisterReactModule() {
        reactModules.clear();
        reactModuleRegisterCompleted = false;
    }

    public void endRegisterReactModule() {
        reactModuleRegisterCompleted = true;
        Log.i(TAG, "react module registry completed");
        for (ReactModuleRegisterListener listener : reactModuleRegisterListeners) {
            listener.onReactModuleRegisterCompleted();
        }
    }

    public void addReactModuleRegisterListener(@NonNull ReactModuleRegisterListener listener) {
        reactModuleRegisterListeners.add(listener);
    }

    public void removeReactModuleRegisterListener(@NonNull ReactModuleRegisterListener listener) {
        reactModuleRegisterListeners.remove(listener);
    }

    public void setRootLayout(@NonNull ReadableMap root, boolean sticky) {
        if (sticky && !hasStickyLayout()) {
            this.stickyLayout = root;
        }
        this.rootLayout = root;
    }

    @Nullable
    public ReadableMap getRootLayout() {
        return this.rootLayout;
    }

    public boolean hasRootLayout() {
        return rootLayout != null;
    }

    @Nullable
    public ReadableMap getStickyLayout() {
        return stickyLayout;
    }

    public boolean hasStickyLayout() {
        return stickyLayout != null;
    }

    public void setPendingLayout(@Nullable ReadableMap pendingLayout) {
        this.pendingLayout = pendingLayout;
    }

    @Nullable
    public ReadableMap getPendingLayout() {
        return pendingLayout;
    }

    public boolean hasPendingLayout() {
        return pendingLayout != null;
    }

    @Nullable
    public AwesomeFragment createFragment(@Nullable ReadableMap layout) {
        if (layout == null) {
            return null;
        }
        AwesomeFragment fragment = null;
        for (Navigator navigator : navigators) {
            fragment = navigator.createFragment(layout);
            if (fragment != null) {
                break;
            }
        }
        return fragment;
    }

    public void buildRouteGraph(@Nullable AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment == null) {
            return;
        }
        FragmentManager childFragmentManager = fragment.getChildFragmentManager();
        if (!childFragmentManager.isDestroyed()) {
            FragmentHelper.executePendingTransactionsSafe(childFragmentManager);
        }

        List<AwesomeFragment> children = fragment.getChildFragmentsAtAddedList();

        if (children.size() > 0) {
            for (int i = 0; i < children.size(); i++) {
                AwesomeFragment child = children.get(i);
                if (child.getShowsDialog()) {
                    for (Navigator navigator : navigators) {
                        if (navigator.buildRouteGraph(child, modal, modal)) {
                            break;
                        }
                    }
                }
            }
        }

        for (Navigator navigator : navigators) {
            if (navigator.buildRouteGraph(fragment, root, modal)) {
                break;
            }
        }
    }

    @Nullable
    public HybridFragment primaryFragment(@Nullable AwesomeFragment fragment) {
        if (fragment == null) {
            return null;
        }
        FragmentManager childFragmentManager = fragment.getChildFragmentManager();
        if (!childFragmentManager.isDestroyed()) {
            FragmentHelper.executePendingTransactionsSafe(childFragmentManager);
        }

        List<AwesomeFragment> children = fragment.getChildFragmentsAtAddedList();
        if (children.size() > 0) {
            AwesomeFragment last = children.get(children.size() - 1);
            if (last.getShowsDialog()) {
                fragment = last;
            }
        }

        HybridFragment hybridFragment = null;
        for (Navigator navigator : navigators) {
            hybridFragment = navigator.primaryFragment(fragment);
            if (hybridFragment != null) {
                break;
            }
        }
        return hybridFragment;
    }

    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras) {
        for (Navigator navigator : navigators) {
            List<String> supportActions = navigator.supportActions();
            if (supportActions.contains(action)) {
                navigator.handleNavigation(target, action, extras);
                break;
            }
        }
    }

    @NonNull
    public HybridFragment createFragment(@NonNull String moduleName) {
        return createFragment(moduleName, null, null);
    }

    @NonNull
    public HybridFragment createFragment(@NonNull String moduleName, @Nullable Bundle props, @Nullable Bundle options) {
        if (!isReactModuleRegisterCompleted()) {
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

        if (fragment == null) {
            throw new NullPointerException("无法创建名为 " + moduleName + " 的模块。");
        }

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
                String uri = null;
                String selectedUri = null;

                Bundle icon = tabItem.getBundle("icon");
                if (icon != null) {
                    uri = icon.getString("uri");
                }

                Bundle selectedIcon = tabItem.getBundle("selectedIcon");
                if (selectedIcon != null) {
                    selectedUri = selectedIcon.getString("uri");
                }

                TabBarItem tabBarItem = new TabBarItem(uri, selectedUri, title);
                fragment.setTabBarItem(tabBarItem);
            }
        }

        Bundle args = FragmentHelper.getArguments(fragment);
        args.putBundle(Constants.ARG_PROPS, props);
        args.putBundle(Constants.ARG_OPTIONS, options);
        args.putString(Constants.ARG_MODULE_NAME, moduleName);
        fragment.setArguments(args);

        return fragment;
    }

    private final List<Navigator> navigators = new ArrayList<>();

    public void registerNavigator(@NonNull Navigator navigator) {
        navigators.add(0, navigator);
    }

    public interface MemoryWatcher {
        void watch(Object object);
    }

    private MemoryWatcher memoryWatcher = null;

    public void setMemoryWatcher(MemoryWatcher memoryWatcher) {
        this.memoryWatcher = memoryWatcher;
    }

    public void watchMemory(Object object) {
        if (memoryWatcher != null) {
            memoryWatcher.watch(object);
        }
    }
}
