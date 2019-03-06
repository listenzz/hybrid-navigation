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

    @UiThread
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
            }
        });

        if (!reactInstanceManager.hasStartedCreatingInitialContext()) {
            Log.i(TAG, "create react context");
            reactInstanceManager.createReactContextInBackground();
        }
    }

    @UiThread
    @NonNull
    public ReactNativeHost getReactNativeHost() {
        checkReactNativeHost();
        return reactNativeHost;
    }

    @UiThread
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

    @UiThread
    public void registerNativeModule(String moduleName, Class<? extends HybridFragment> clazz) {
        nativeModules.put(moduleName, clazz);
    }

    @UiThread
    public boolean hasNativeModule(String moduleName) {
        return nativeModules.containsKey(moduleName);
    }

    @UiThread
    @Nullable
    public Class<? extends HybridFragment> nativeModuleClassForName(String moduleName) {
        return nativeModules.get(moduleName);
    }

    @UiThread
    public void registerReactModule(String moduleName, ReadableMap options) {
        reactModules.put(moduleName, options);
    }

    @UiThread
    public boolean hasReactModule(String moduleName) {
        return reactModules.containsKey(moduleName);
    }

    @UiThread
    @Nullable
    public ReadableMap reactModuleOptionsForKey(String moduleName) {
        return reactModules.get(moduleName);
    }

    private boolean reactModuleRegisterCompleted = false;

    @UiThread
    public boolean isReactModuleRegisterCompleted() {
        return reactModuleRegisterCompleted;
    }

    @UiThread
    public void setReactModuleRegisterCompleted(boolean reactModuleRegisterCompleted) {
        this.reactModuleRegisterCompleted = reactModuleRegisterCompleted;
    }

    @UiThread
    public void startRegisterReactModule() {
        reactModules.clear();
        reactModuleRegisterCompleted = false;
    }

    @UiThread
    public void endRegisterReactModule() {
        reactModuleRegisterCompleted = true;
        Log.i(TAG, "react module registry completed");
        for (ReactModuleRegisterListener listener : reactModuleRegisterListeners) {
            listener.onReactModuleRegisterCompleted();
        }
    }

    @UiThread
    public void addReactModuleRegisterListener(ReactModuleRegisterListener listener) {
        reactModuleRegisterListeners.add(listener);
    }

    @UiThread
    public void removeReactModuleRegisterListener(ReactModuleRegisterListener listener) {
        reactModuleRegisterListeners.remove(listener);
    }

    @UiThread
    public void setRootLayout(ReadableMap root, boolean sticky) {
        if (sticky && !hasStickyLayout()) {
            this.stickyLayout = root;
        }
        this.rootLayout = root;
    }

    @UiThread
    public ReadableMap getRootLayout() {
        return this.rootLayout;
    }

    @UiThread
    public boolean hasRootLayout() {
        return rootLayout != null;
    }

    @UiThread
    public ReadableMap getStickyLayout() {
        return stickyLayout;
    }

    @UiThread
    public boolean hasStickyLayout() {
        return stickyLayout != null;
    }

    @UiThread
    public void setPendingLayout(ReadableMap pendingLayout) {
        this.pendingLayout = pendingLayout;
    }

    @UiThread
    public ReadableMap getPendingLayout() {
        return pendingLayout;
    }

    @UiThread
    public boolean hasPendingLayout() {
        return pendingLayout != null;
    }

    @UiThread
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

    @UiThread
    public void buildRouteGraph(@NonNull AwesomeFragment fragment, @NonNull ArrayList<Bundle> root, @NonNull ArrayList<Bundle> modal) {
        FragmentManager fragmentManager = fragment.getFragmentManager();
        if (fragmentManager == null || fragmentManager.isDestroyed()) {
            return;
        }
        FragmentHelper.executePendingTransactionsSafe(fragmentManager);

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

    @UiThread
    @Nullable
    public HybridFragment primaryFragment(AwesomeFragment fragment) {
        FragmentManager fragmentManager = fragment.getFragmentManager();
        if (fragmentManager == null || fragmentManager.isDestroyed()) {
            return null;
        }
        FragmentHelper.executePendingTransactionsSafe(fragmentManager);

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


    @UiThread
    public void handleNavigation(@Nullable AwesomeFragment fragment, @NonNull String action, @NonNull ReadableMap extras) {
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

    @UiThread
    @NonNull
    public HybridFragment createFragment(@NonNull String moduleName) {
        return createFragment(moduleName, null, null);
    }

    @UiThread
    @NonNull
    public HybridFragment createFragment(@NonNull String moduleName, Bundle props, Bundle options) {
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
                Bundle icon = tabItem.getBundle("icon");
                String uri = null;
                if (icon != null) {
                    uri = icon.getString("uri");
                }
                TabBarItem tabBarItem = new TabBarItem(uri, title);

                Bundle selectedIcon = tabItem.getBundle("selectedIcon");
                if (selectedIcon != null) {
                    tabBarItem.selectedIconUri = selectedIcon.getString("uri");
                }
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

    @UiThread
    public void registerNavigator(Navigator navigator) {
        navigators.add(0, navigator);
    }
}
