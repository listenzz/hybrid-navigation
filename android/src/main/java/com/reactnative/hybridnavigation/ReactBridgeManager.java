package com.reactnative.hybridnavigation;

import android.annotation.SuppressLint;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.common.logging.FLog;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@UiThread
public class ReactBridgeManager {

    public interface ReactModuleRegisterListener {
        void onReactModuleRegisterCompleted();
    }

    public interface ReactBridgeReloadListener {
        void onReload();
    }

    private static final String TAG = "Navigation";

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
    private Callback pendingCallback;
    private ReadableMap stickyLayout;
    private ReadableMap pendingLayout;
    private boolean viewHierarchyReady;

    private ReactNativeHost reactNativeHost;

    public void install(@NonNull ReactNativeHost reactNativeHost) {
        this.setReactNativeHost(reactNativeHost);
        this.initialize();
    }

    public void setReactNativeHost(@NonNull ReactNativeHost reactNativeHost) {
        this.reactNativeHost = reactNativeHost;
    }
    
    public void initialize() {
        checkReactNativeHost();
        final ReactInstanceManager reactInstanceManager = reactNativeHost.getReactInstanceManager();
        reactInstanceManager.addReactInstanceEventListener(context -> {
            FLog.i(TAG, "React instance context initialized.");
            rootLayout = null;
            pendingCallback = null;
            stickyLayout = null;
            pendingLayout = null;
            reactBridgeReloadListeners.clear();

            setViewHierarchyReady(false);
        });

        FLog.i(TAG, "Create react context in background.");
        reactInstanceManager.createReactContextInBackground();
    }

    private void checkReactNativeHost() {
        if (reactNativeHost == null) {
            throw new IllegalStateException("Must call ReactBridgeManager#install first");
        }
    }
    
    @Nullable
    public ReactInstanceManager getReactInstanceManager() {
        if (reactNativeHost != null && reactNativeHost.hasInstance()) {
            return reactNativeHost.getReactInstanceManager();
        }
        return null;
    }

    @SuppressLint("VisibleForTests")
    @Nullable
    public ReactContext getCurrentReactContext() {
        ReactInstanceManager instanceManager = getReactInstanceManager();
        if (instanceManager != null) {
            return instanceManager.getCurrentReactContext();
        }
        return null;
    }

    public boolean getUseDeveloperSupport() {
        if (reactNativeHost != null && reactNativeHost.hasInstance()) {
            return reactNativeHost.getUseDeveloperSupport();
        }
        return false;
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

    @NonNull
    public ReadableMap reactModuleOptionsForKey(@NonNull String moduleName) {
        ReadableMap map = reactModules.get(moduleName);
        if (map != null) {
            return map;
        }
        return Arguments.createMap();
    }

    private boolean reactModuleRegisterCompleted = false;

    public boolean isReactModuleRegisterCompleted() {
        return reactModuleRegisterCompleted;
    }

    public void setReactModuleRegisterCompleted(boolean reactModuleRegisterCompleted) {
        this.reactModuleRegisterCompleted = reactModuleRegisterCompleted;
    }

    public void startRegisterReactModule() {
        FLog.i(TAG, "ReactBridgeManager#startRegisterReactModule");
        reactModules.clear();
        setReactModuleRegisterCompleted(false);
    }

    public void endRegisterReactModule() {
        setReactModuleRegisterCompleted(true);
        FLog.i(TAG, "ReactBridgeManager#endRegisterReactModule");
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

    public void invalidate() {
        invokeReloadListeners();
        setPendingLayout(null, null);
        setReactModuleRegisterCompleted(false);
        setViewHierarchyReady(false);
    }

    private void invokeReloadListeners() {
        for (ReactBridgeManager.ReactBridgeReloadListener listener : reactBridgeReloadListeners) {
            listener.onReload();
        }
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

    public void setPendingLayout(@Nullable ReadableMap pendingLayout, Callback callback) {
        this.pendingLayout = pendingLayout;
        this.pendingCallback = callback;
    }

    @Nullable
    public ReadableMap getPendingLayout() {
        return pendingLayout;
    }

    public Callback getPendingCallback() {
        return pendingCallback;
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

    @NonNull
    public ArrayList<Bundle> buildRouteGraph(@NonNull FragmentManager fragmentManager) {
        ArrayList<Bundle> root = new ArrayList<>();
        List<AwesomeFragment> fragments = FragmentHelper.getFragments(fragmentManager);
        for (int i = 0; i < fragments.size(); i++) {
            AwesomeFragment fragment = fragments.get(i);
            Bundle bundle = buildRouteGraph(fragment);
            if (bundle == null) {
                continue;
            }
            root.add(bundle);
        }
        return root;
    }

    @Nullable
    public Bundle buildRouteGraph(@NonNull AwesomeFragment fragment) {
        String layout = navigatorRegistry.layoutForFragment(fragment);
        if (layout == null) {
            return null;
        }

        Navigator navigator = navigatorRegistry.navigatorForLayout(layout);
        if (navigator != null) {
            return navigator.buildRouteGraph(fragment);
        }

        return null;
    }

    @Nullable
    public HybridFragment primaryFragment(@NonNull FragmentManager fragmentManager) {
        AwesomeFragment dialog = FragmentHelper.getAwesomeDialogFragment(fragmentManager);
        if (dialog != null) {
            return primaryFragment(dialog);
        }

        Fragment fragment = fragmentManager.findFragmentById(android.R.id.content);
        if (fragment instanceof AwesomeFragment) {
            return primaryFragment((AwesomeFragment) fragment);
        }

        return null;
    }

    @Nullable
    public HybridFragment primaryFragment(@Nullable AwesomeFragment fragment) {
        if (fragment == null) {
            return null;
        }

        if (fragment.definesPresentationContext()) {
            AwesomeFragment presented = fragment.getPresentedFragment();
            if (presented != null) {
                return primaryFragment(presented);
            }
        }

        String layout = navigatorRegistry.layoutForFragment(fragment);
        if (layout == null) {
            return null;
        }

        Navigator navigator = navigatorRegistry.navigatorForLayout(layout);
        if (navigator != null) {
            return navigator.primaryFragment(fragment);
        }

        return null;
    }

    public void handleNavigation(@NonNull AwesomeFragment target, @NonNull String action, @NonNull ReadableMap extras, @NonNull Callback callback) {
        Navigator navigator = navigatorRegistry.navigatorForAction(action);
        if (navigator != null) {
            navigator.handleNavigation(target, action, extras, callback);
        }
    }

    @Nullable
    public AwesomeFragment createFragment(@Nullable ReadableMap layout) {
        if (layout == null) {
            return null;
        }

        List<String> layouts = navigatorRegistry.allLayouts();
        for (String name : layouts) {
            if (!layout.hasKey(name)) {
                continue;
            }

            Navigator navigator = navigatorRegistry.navigatorForLayout(name);
            if (navigator == null) {
                continue;
            }

            AwesomeFragment fragment = navigator.createFragment(layout);
            if (fragment != null) {
                navigatorRegistry.setLayoutForFragment(name, fragment);
            }
            return fragment;
        }

        throw new IllegalArgumentException("找不到可以处理 " + layout + " 的 navigator, 你是否忘了注册？");
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

        HybridFragment fragment = newFragment(moduleName);

        Bundle args = FragmentHelper.getArguments(fragment);
        args.putBundle(Constants.ARG_PROPS, notNull(props));
        args.putBundle(Constants.ARG_OPTIONS, mergeOptions(moduleName, notNull(options)));
        args.putString(Constants.ARG_MODULE_NAME, moduleName);

        fragment.setArguments(args);

        return fragment;
    }

    private Bundle notNull(@Nullable Bundle bundle) {
        if (bundle == null) {
            return new Bundle();
        }
        return bundle;
    }

    private Bundle mergeOptions(@NonNull String moduleName, @NonNull Bundle options) {
        if (!hasReactModule(moduleName)) {
            return options;
        }

        ReadableMap readableMap = reactModuleOptionsForKey(moduleName);
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(readableMap);
        writableMap.merge(Arguments.fromBundle(options));
        return Arguments.toBundle(writableMap);
    }

    @NonNull
    private HybridFragment newFragment(@NonNull String moduleName) {
        if (hasReactModule(moduleName)) {
            return new ReactFragment();
        }

        Class<? extends HybridFragment> fragmentClass = nativeModuleClassForName(moduleName);
        if (fragmentClass == null) {
            throw new IllegalArgumentException("未能找到名为 " + moduleName + " 的模块，你是否忘了注册？");
        }

        try {
            return fragmentClass.newInstance();
        } catch (Exception e) {
            throw new IllegalArgumentException("无法创建名为 " + moduleName + " 的模块。");
        }
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
