package com.navigationhybrid;

import android.arch.lifecycle.Lifecycle;
import android.arch.lifecycle.LifecycleObserver;
import android.arch.lifecycle.LifecycleOwner;
import android.arch.lifecycle.OnLifecycleEvent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.util.LinkedList;
import java.util.UUID;

/**
 * Created by Listen on 2017/11/20.
 */

public class Navigator implements LifecycleObserver {

    public static final String ON_COMPONENT_RESULT_EVENT = "ON_COMPONENT_RESULT";
    public static final String REQUEST_CODE_KEY = "requestCode";
    public static final String RESULT_CODE_KEY = "resultCode";
    public static final String RESULT_DATA_KEY = "data";
    public static final String ON_BAR_BUTTON_ITEM_CLICK_EVENT = "ON_BAR_BUTTON_ITEM_CLICK";

    private static final String TAG = "ReactNative";

    public final String navId;
    public final String sceneId;
    public final FragmentManager fragmentManager;
    public final int containerId;

    public PresentAnimation anim = PresentAnimation.None;
    public int requestCode;
    private int resultCode;
    private Bundle result;

    private ReactBridgeManager reactBridgeManager = ReactBridgeManager.instance;

    LifecycleOwner lifecycleOwner;

    public Navigator(@NonNull LifecycleOwner lifecycleOwner, @NonNull String navId, @NonNull String sceneId, @NonNull FragmentManager fragmentManager, int containerId) {
        this.navId = navId;
        this.sceneId = sceneId;
        this.fragmentManager = fragmentManager;
        this.containerId = containerId;
        this.lifecycleOwner = lifecycleOwner;
        lifecycleOwner.getLifecycle().addObserver(this);
    }

    public void setRoot(final NavigationFragment fragment, final boolean animated) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            setRootTask(fragment, animated);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    setRootTask(fragment, animated);
                }
            });
        }
    }

    void setRootTask(NavigationFragment fragment, boolean animated) {
        NavigationFragment root = getRootFragment();
        if (root != null) {
            throw new IllegalStateException("已经设置 root fragment 了，不可以再设置");
        }

        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.setReorderingAllowed(true);
        NavigationFragment topFragment = getTopFragment();
        if (animated) {
            transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
            fragment.setCurrentAnimations(PresentAnimation.Modal);
            topFragment.setCurrentAnimations(PresentAnimation.Modal);
        }

        transaction.add(containerId, fragment, navId);

        if (topFragment != null) {
            transaction.hide(topFragment);
        }

        transaction.addToBackStack(navId);

        transaction.commit();
        if (!animated) {
            fragmentManager.executePendingTransactions();
        }
    }

    public NavigationFragment createFragment(@NonNull String moduleName, @NonNull String sceneId, Bundle props, Bundle options) {

        NavigationFragment fragment = null;

        if (options == null) {
            options = new Bundle();
        }

        if (reactBridgeManager.hasReactModule(moduleName)) {
            fragment = new ReactNavigationFragment();

            ReadableMap readableMap = reactBridgeManager.reactModuleOptionsForKey(moduleName);
            if (readableMap == null) {
                readableMap = Arguments.createMap();
            }
            WritableMap writableMap = Arguments.createMap();
            writableMap.merge(readableMap);
            writableMap.merge(Arguments.fromBundle(options));
            options = Arguments.toBundle(writableMap);

        } else {
            Class<? extends NavigationFragment> fragmentClass = reactBridgeManager.nativeModuleClassForName(moduleName);
            if (fragmentClass == null) {
                throw new IllegalArgumentException("未能找到名为 " + moduleName + " 的模块，你是否忘了注册？");
            }

            try {
                fragment = fragmentClass.newInstance();
            } catch (Exception e) {
                // ignore
                e.printStackTrace();
            }
        }

        Bundle args = FragmentHelper.getArguments(fragment);
        if (props == null) {
            props = new Bundle();
        }

        props.putString(NavigationFragment.PROPS_NAV_ID, navId);
        props.putString(NavigationFragment.PROPS_SCENE_ID, sceneId);

        args.putBundle(NavigationFragment.NAVIGATION_PROPS, props);
        args.putBundle(NavigationFragment.NAVIGATION_OPTIONS, options);
        args.putInt(NavigationFragment.NAVIGATION_CONTAINER_ID, containerId);
        args.putInt(NavigationFragment.NAVIGATION_REQUEST_CODE, requestCode);
        args.putString(NavigationFragment.NAVIGATION_MODULE_NAME, moduleName);

        if (fragment != null) {
            fragment.setArguments(args);
        }

        return fragment;
    }

    public void push(@NonNull final String moduleName, final Bundle props, final Bundle options, final boolean animated) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            pushTask(moduleName, props, options, animated);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    pushTask(moduleName, props, options, animated);
                }
            });
        }
    }

    void pushTask(@NonNull String moduleName, Bundle props, Bundle options, boolean animated) {
        NavigationFragment fragment = createFragment(moduleName, UUID.randomUUID().toString(), props, options);
        NavigationFragment selfFragment = getSelfFragment();
        if (animated) {
            fragment.setCurrentAnimations(PresentAnimation.Push);
            selfFragment.setCurrentAnimations(PresentAnimation.Push);
        }

        fragmentManager
                .beginTransaction()
                .setReorderingAllowed(true)
                .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN)
                .add(containerId, fragment, fragment.getSceneId())
                .hide(selfFragment)
                .addToBackStack(fragment.getSceneId())
                .commit();
    }


    public void push(@NonNull String moduleName) {
        push(moduleName, null, null, true);
    }

    public boolean isRoot() {
        return getRootFragment() == getSelfFragment();
    }

    public boolean canPop() {
        return !isRoot();
    }

    public void pop() {
        pop(true);
    }

    public void pop(final boolean animated) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            popTask(animated);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    popTask(animated);
                }
            });
        }
    }

    void popTask(boolean animated) {
        if (!canPop()) {
            return;
        }
        NavigationFragment previous = getPreFragment(getSelfFragment());

        if (animated) {
            previous.setCurrentAnimations(PresentAnimation.Push);
            anim = PresentAnimation.Push;
        } else {
            previous.setCurrentAnimations(PresentAnimation.None);
            anim = PresentAnimation.None;
        }

        fragmentManager.popBackStack();

        if (result != null) {
            previous.onFragmentResult(0, resultCode, result);
        }
    }

    public void popTo(String sceneId) {
        popTo(sceneId, true);
    }

    public void popTo(final String sceneId, final boolean animated) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            popToTask(sceneId, animated);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    popTo(sceneId, animated);
                }
            });
        }
    }

    void popToTask(String sceneId, boolean animated) {

        if (!canPop()) return;

        NavigationFragment root = getRootFragment();
        NavigationFragment target = null;
        String tag = null;

        int count = fragmentManager.getBackStackEntryCount();
        for (int i = count -1; i > -1; i--) {
            FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(i);
            String name = entry.getName();
            tag = name;
            if (name != null && name.equals(sceneId)) {
                target = (NavigationFragment) fragmentManager.findFragmentByTag(sceneId);
                break;
            }

            // 到根部了
            if (name != null && name.equals(root.getTag())) {
                if (sceneId.equals(root.getSceneId())) {
                    target = root;
                }
                break; // must put here, since we don't want the target out of navigation bounds
            }
        }

        if (target != null) {
            if (animated) {
                anim = PresentAnimation.Push;
                target.setCurrentAnimations(PresentAnimation.Push);
            } else {
                anim = PresentAnimation.None;
                target.setCurrentAnimations(PresentAnimation.None);
            }
            fragmentManager.popBackStack(tag, 0);

            if (result != null) {
                target.onFragmentResult(0, resultCode, result);
            }

        } else {
            Log.w(TAG, "can't find the specified scene at current navigation bounds");
        }
    }


    public void popToRoot() {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            popToRootTask();
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    popToRootTask();
                }
            });
        }
    }

    void popToRootTask() {
        if (!canPop()) {
            return;
        }
        NavigationFragment rootFragment = getRootFragment();
        rootFragment.setCurrentAnimations(PresentAnimation.Push);
        anim = PresentAnimation.Push;
        fragmentManager.popBackStack(navId, 0);

        if (result != null) {
            rootFragment.onFragmentResult(0, resultCode, result);
        }
    }

    public void replace(String moduleName) {
        replace(moduleName, null, null);
    }

    public void replace(@NonNull final String moduleName, final Bundle props, final Bundle options) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            replaceTask(moduleName, props, options);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    replace(moduleName, props, options);
                }
            });
        }
    }

    void replaceTask(@NonNull String moduleName, Bundle props, Bundle options) {
        NavigationFragment fragment = createFragment(moduleName, UUID.randomUUID().toString(), props, options);
        NavigationFragment selfFragment = getSelfFragment();
        NavigationFragment preFragment = getPreFragment(selfFragment);

        selfFragment.setCurrentAnimations(PresentAnimation.None);

        if (preFragment != null) {
           preFragment.setCurrentAnimations(PresentAnimation.None);
        }

        boolean isRoot = isRoot();
        fragmentManager.popBackStack();

        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.setReorderingAllowed(true);
        transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        if (isRoot) {
            transaction.add(containerId, fragment, fragment.getNavId());
        } else {
            transaction.add(containerId, fragment, fragment.getSceneId());
        }

        if (preFragment != null) {
            transaction.hide(preFragment);
        }

        if (isRoot) {
            transaction.addToBackStack(fragment.getNavId());
        } else {
            transaction.addToBackStack(fragment.getSceneId());
        }

        transaction.commit();
    }

    public void replaceToRoot(String moduleName) {
        replaceToRoot(moduleName, null, null);
    }

    public void replaceToRoot(@NonNull final String moduleName, final Bundle props, final Bundle options) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            replaceToRootTask(moduleName, props, options);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    replaceToRootTask(moduleName, props, options);
                }
            });
        }
    }

    void replaceToRootTask(@NonNull String moduleName, Bundle props, Bundle options) {
        NavigationFragment fragment = createFragment(moduleName, UUID.randomUUID().toString(), props, options);
        NavigationFragment rootFragment = getRootFragment();
        NavigationFragment preFragment = getPreFragment(rootFragment);
        NavigationFragment selfFragment = getSelfFragment();

        selfFragment.setCurrentAnimations(PresentAnimation.None);
        if (preFragment != null) {
            preFragment.setCurrentAnimations(PresentAnimation.None);
        }

        fragmentManager.popBackStack(rootFragment.getTag(), FragmentManager.POP_BACK_STACK_INCLUSIVE);

        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.setReorderingAllowed(true);
        transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        transaction.add(containerId, fragment, fragment.getNavId());
        if (preFragment != null) {
            transaction.hide(preFragment);
        }
        transaction.addToBackStack(fragment.getNavId());
        transaction.commit();
    }

    public void present(@NonNull final String moduleName, final int requestCode, final Bundle props, final Bundle options, final boolean animated) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            presentTask(moduleName, requestCode, props, options, animated);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    presentTask(moduleName, requestCode, props, options, animated);
                }
            });
        }
    }

    void presentTask(@NonNull String moduleName, int requestCode, Bundle props, Bundle options, boolean animated) {
        anim = PresentAnimation.Modal;
        Navigator navigator = new Navigator(lifecycleOwner, UUID.randomUUID().toString(), UUID.randomUUID().toString(), fragmentManager, containerId);
        NavigationFragment fragment = navigator.createFragment(moduleName, navigator.sceneId, props, options);
        fragment.setRequestCode(requestCode);
        navigator.setRoot(fragment, animated);
    }

    public void present(@NonNull String moduleName, int requestCode) {
        present(moduleName, requestCode, null, null, true);
    }

    public boolean canDismiss() {
        return getPresentingFragment() != null;
    }

    public void setResult(int resultCode, Bundle data) {
        this.result = data;
        this.resultCode = resultCode;
    }

    public void dismiss(final boolean animated) {
        if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
            dismissTask(animated);
        } else {
            scheduleTask(new Runnable() {
                @Override
                public void run() {
                    dismissTask(animated);
                }
            });
        }
    }

    void dismissTask(boolean animated) {
        if (!canDismiss()) {
            NavigationFragment fragment = getRootFragment();
            if (fragment.getActivity() != null ) {
                ActivityCompat.finishAfterTransition(fragment.getActivity());
            }
            return;
        }

        // FIXME 考虑有 presented 的情况

        NavigationFragment presenting = getPresentingFragment();

        if (animated) {
            presenting.setCurrentAnimations(PresentAnimation.Modal);
            anim = PresentAnimation.Modal;
        } else {
            presenting.setCurrentAnimations(PresentAnimation.None);
            anim = PresentAnimation.None;
        }

        presenting.onFragmentResult(requestCode, resultCode, result);

        fragmentManager.popBackStack(navId, FragmentManager.POP_BACK_STACK_INCLUSIVE);
    }

    public void dismiss() {
        dismiss(true);
    }

    NavigationFragment getRootFragment() {
        return (NavigationFragment) fragmentManager.findFragmentByTag(navId);
    }

    NavigationFragment getSelfFragment() {
        NavigationFragment fragment = (NavigationFragment) fragmentManager.findFragmentByTag(sceneId);
        if (fragment == null) {
            fragment = (NavigationFragment) fragmentManager.findFragmentByTag(navId);
            if (!fragment.getSceneId().equals(sceneId)) {
                Log.w(TAG, "fragment scene id not equal!");
            }
        }
        return fragment;
    }

    NavigationFragment getTopFragment() {
        int count = fragmentManager.getBackStackEntryCount();
        if (count > 0) {
            FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(count -1);
            if (entry.getName() != null) {
                return (NavigationFragment) fragmentManager.findFragmentByTag(entry.getName());
            } else {
                Log.w(TAG, "entry name is null, maybe something wrong!");
            }
        }
        return null;
    }

    NavigationFragment getPreFragment(NavigationFragment fragment) {

        if (fragment == null) {
            return null;
        }

        int count = fragmentManager.getBackStackEntryCount();

        int index = -1;
        for (int i = count -1; i > -1; i--) {
            FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(i);
            String name = entry.getName();
            if (name != null) {
                if (name.equals(fragment.getTag())) {
                    index = i - 1;
                    break;
                }
            } else {
                Log.w(TAG, "entry name is null, maybe something wrong!");
            }
        }

        for (int i = index; i > -1; i-- ) {
            FragmentManager.BackStackEntry entry = fragmentManager.getBackStackEntryAt(i);
            String name = entry.getName();
            if (name != null) {
                return (NavigationFragment) fragmentManager.findFragmentByTag(name);
            } else {
                Log.w(TAG, "entry name is null, maybe something wrong!");
            }
        }

        return null;

    }

    NavigationFragment getPresentingFragment() {
        // FIXMe 精确到子 fragment
        return getPreFragment(getRootFragment());
    }

    boolean active;
    LinkedList<Runnable> tasks = new LinkedList<>();

    void scheduleTask(Runnable runnable) {
        if (lifecycleOwner.getLifecycle().getCurrentState() != Lifecycle.State.DESTROYED) {
            tasks.add(runnable);
            considerExecute();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_ANY)
    void onStateChange() {
        if (lifecycleOwner.getLifecycle().getCurrentState() == Lifecycle.State.DESTROYED) {
            // 清空队列
            tasks.clear();
            lifecycleOwner.getLifecycle().removeObserver(this);
        } else {
            activeStateChanged(isActiveState(lifecycleOwner.getLifecycle().getCurrentState()));
        }
    }

    void activeStateChanged(boolean newActive) {
        if (newActive != this.active) {
            this.active = newActive;
            considerExecute();
        }
    }

    void considerExecute() {
        if (active) {
            if (isActiveState(lifecycleOwner.getLifecycle().getCurrentState())) {
                if (tasks.size() > 0) {
                    for (Runnable task : tasks) {
                        task.run();
                    }
                    tasks.clear();
                }
            }
        }
    }

    boolean isActiveState(Lifecycle.State state) {
        return state.isAtLeast(Lifecycle.State.STARTED);
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("navId=" + navId);
        builder.append(", sceneId=" + sceneId);
        builder.append(", containerId=" + containerId);
        builder.append(", anim=" + anim.name());
        builder.append(", requestCode=" + requestCode);
        return builder.toString();
    }
}
