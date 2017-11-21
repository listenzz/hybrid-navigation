package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;

import java.util.UUID;

/**
 * Created by Listen on 2017/11/20.
 */

public class Navigator {

    public static final String ON_COMPONENT_RESULT_EVENT = "ON_COMPONENT_RESULT";
    public static final String REQUEST_CODE_KEY = "requestCode";
    public static final String RESULT_CODE_KEY = "resultCode";
    public static final String RESULT_DATA_KEY = "data";

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

    public Navigator(@NonNull String navId, @NonNull String sceneId, @NonNull FragmentManager fragmentManager, int containerId) {
        this.navId = navId;
        this.sceneId = sceneId;
        this.fragmentManager = fragmentManager;
        this.containerId = containerId;
    }

    public void setRoot(NavigationFragment fragment, boolean animated) {
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
    }

    public NavigationFragment createFragment(@NonNull String moduleName, @NonNull String sceneId, Bundle props, Bundle options) {

        NavigationFragment fragment = null;

        if (reactBridgeManager.hasReactModule(moduleName)) {
            fragment = new ReactNavigationFragment();
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

    public void push(@NonNull String moduleName, Bundle props, Bundle options, boolean animated) {
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

    public void pop(boolean animated) {
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
    }

    public void pop() {
        pop(true);
    }

    public void popToRoot() {
        if (!canPop()) {
            return;
        }
        anim = PresentAnimation.Push;
        fragmentManager.popBackStack(navId, 0);
    }

    public void present(@NonNull String moduleName, int requestCode, Bundle props, Bundle options, boolean animated) {
        anim = PresentAnimation.Modal;
        Navigator navigator = new Navigator(UUID.randomUUID().toString(), UUID.randomUUID().toString(), fragmentManager, containerId);
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

    public void dismiss(boolean animated) {
        if (!canDismiss()) {
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

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("navId=" + navId);
        builder.append(" sceneId=" + sceneId);
        builder.append(" containerId=" + containerId);
        builder.append(" anim=" + anim.name());
        builder.append(" requestCode=" + requestCode);
        return builder.toString();
    }
}
