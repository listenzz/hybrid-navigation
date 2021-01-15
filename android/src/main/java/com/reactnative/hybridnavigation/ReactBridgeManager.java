package com.reactnative.hybridnavigation;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;

import com.facebook.common.logging.FLog;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.reactnative.hybridnavigation.navigator.Navigator;
import com.reactnative.hybridnavigation.navigator.NavigatorRegistry;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Created by Listen on 2017/11/17.
 */
@UiThread
public class ReactBridgeManager {

    public interface ReactModuleRegisterListener {
        void onReactModuleRegisterCompleted();
    }

    public interface ReactBridgeReloadListener {
        void onReload();
    }

    private static final String TAG = "ReactNative";
    private final static ReactBridgeManager instance = new ReactBridgeManager();

    public static ReactBridgeManager get() {
        return instance;
    }

    private ReactBridgeManager() {
    }

    private final HashMap<String, Class<? extends HybridFragment>> nativeModules = new HashMap<>();
    private final HashMap<String, ReadableMap> reactModules = new HashMap<>();
    private final CopyOnWriteArrayList<ReactModuleRegisterListener> reactModuleRegisterListeners = new CopyOnWriteArrayList<>();
    private final CopyOnWriteArrayList<ReactBridgeReloadListener> reactBridgeReloadListeners = new CopyOnWriteArrayList<>();

    private ReadableMap rootLayout;
    private int pendingTag;
    private ReadableMap stickyLayout;
    private ReadableMap pendingLayout;
    private boolean viewHierarchyReady;

    private ReactNativeHost reactNativeHost;

    public void install(@NonNull ReactNativeHost reactNativeHost) {
        this.reactNativeHost = reactNativeHost;
        this.setup();
    }

    private void setup() {
        final ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        reactInstanceManager.addReactInstanceEventListener(context -> {
            FLog.i(TAG, "react instance context initialized.");
            rootLayout = null;
            pendingTag = 0;
            stickyLayout = null;
            pendingLayout = null;
            setViewHierarchyReady(false);
        });

        if (!reactInstanceManager.hasStartedCreatingInitialContext()) {
            FLog.i(TAG, "create react context");
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
    public ReactContext getCurrentReactContext() {
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
        setReactModuleRegisterCompleted(false);
    }

    public void endRegisterReactModule() {
        setReactModuleRegisterCompleted(true);
        FLog.i(TAG, "react module registry completed");
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

    public void addReactBridgeReloadListener(@NonNull ReactBridgeReloadListener listener) {
        reactBridgeReloadListeners.add(listener);
    }

    public void removeReactBridgeReloadListener(@NonNull ReactBridgeReloadListener listener) {
        reactBridgeReloadListeners.remove(listener);
    }

    public List<ReactBridgeReloadListener> getReactBridgeReloadListeners() {
        return reactBridgeReloadListeners;
    }

    public void setRootLayout(@NonNull ReadableMap root, boolean sticky) {
        if (sticky && !hasStickyLayout()) {
            stickyLayout = root;
        }

        rootLayout = root;
    }

    @Nullable
    public ReadableMap getRootLayout() {
        return rootLayout;
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

    public void setPendingLayout(@Nullable ReadableMap pendingLayout, int tag) {
        this.pendingLayout = pendingLayout;
        this.pendingTag = tag;
    }

    @Nullable
    public ReadableMap getPendingLayout() {
        return pendingLayout;
    }

    public int getPendingTag() {
        return pendingTag;
    }

    public boolean hasPendingLayout() {
        return pendingLayout != null;
    }

    public boolean isViewHierarchyReady() {
        return viewHierarchyReady;
    }

    public void setViewHierarchyReady(boolean ready) {
        viewHierarchyReady = ready;
    }

    public void buildRouteGraph(@Nullable AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        if (fragment == null) {
            return;
        }

        List<AwesomeFragment> children = fragment.getChildFragments();

        if (children.size() > 0) {
            for (int i = 0; i < children.size(); i++) {
                AwesomeFragment child = children.get(i);
                if (child.getShowsDialog() && !child.isDismissed()) {
                    for (Navigator navigator : navigatorRegistry.allNavigators()) {
                        if (navigator.buildRouteGraph(child, modal, modal)) {
                            break;
                        }
                    }
                }
            }
        }

        for (Navigator navigator : navigatorRegistry.allNavigators()) {
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

        List<AwesomeFragment> children = fragment.getChildFragments();
        if (children.size() > 0) {
            AwesomeFragment last = children.get(children.size() - 1);
            if (last.getShowsDialog() && !last.isDismissed()) {
                fragment = last;
            }
        }

        HybridFragment hybridFragment = null;
        for (Navigator navigator : navigatorRegistry.allNavigators()) {
            hybridFragment = navigator.primaryFragment(fragment);
            if (hybridFragment != null) {
                break;
            }
        }
        return hybridFragment;
    }

    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Promise promise) {
        Navigator navigator = navigatorRegistry.navigatorForAction(action);
        if (navigator != null) {
            navigator.handleNavigation(target, action, extras, promise);
        }
    }

    @Nullable
    public AwesomeFragment createFragment(@Nullable ReadableMap layout) {
        if (layout == null) {
            return null;
        }

        List<String> layouts = navigatorRegistry.allLayouts();
        Navigator navigator = null;
        for (String name : layouts) {
            if (layout.hasKey(name)) {
                navigator = navigatorRegistry.navigatorForLayout(name);
                break;
            }
        }

        if (navigator == null) {
            throw new IllegalArgumentException("找不到可以处理 " + layout + " 的 navigator, 你是否忘了注册？");
        }

        return navigator.createFragment(layout);
    }

    @NonNull
    public HybridFragment createFragment(@NonNull String moduleName) {
        return createFragment(moduleName, null, null);
    }

    @NonNull
    public HybridFragment createFragment(@NonNull String moduleName, @Nullable Bundle props, @Nullable Bundle options) {
        if (getCurrentReactContext() == null) {
            throw new IllegalStateException("current react context is null.");
        }

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

        Bundle args = FragmentHelper.getArguments(fragment);
        args.putBundle(Constants.ARG_PROPS, props);
        args.putBundle(Constants.ARG_OPTIONS, options);
        args.putString(Constants.ARG_MODULE_NAME, moduleName);
        fragment.setArguments(args);

        return fragment;
    }

    private final NavigatorRegistry navigatorRegistry = new NavigatorRegistry();

    public void registerNavigator(@NonNull Navigator navigator) {
        navigatorRegistry.register(navigator);
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
