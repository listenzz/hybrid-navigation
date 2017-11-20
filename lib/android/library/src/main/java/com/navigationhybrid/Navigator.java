package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;

/**
 * Created by Listen on 2017/11/20.
 */

public class Navigator {

    private static final String TAG = "ReactNative";

    private final String navId;
    private final String sceneId;
    private final FragmentManager fragmentManager;
    private final int containerId;

    public PresentAnimation anim = PresentAnimation.None;
    public int requestCode;
    private int resultCode;
    private Bundle result;

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

        if (animated) {
            transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
            fragment.setCurrentAnimations(PresentAnimation.Modal);
        }

        transaction.add(containerId, fragment, navId);

        NavigationFragment topFragment = getTopFragment();
        if (topFragment != null) {
            transaction.hide(topFragment);
        }

        transaction.addToBackStack(navId);
        transaction.commit();
    }

    public NavigationFragment createFragment(@NonNull String moduleName, Bundle props, Bundle options) {
        // FIXME implement
        return null;
    }

    public void push(@NonNull String moduleName, Bundle props, Bundle options, boolean animated) {
        NavigationFragment fragment = createFragment(moduleName, props, options);

        if (animated) {
            fragment.setCurrentAnimations(PresentAnimation.Push);
            anim = PresentAnimation.Push;
        }

        NavigationFragment selfFragment = getSelfFragment();

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
        return getRootFragment() != getSelfFragment();
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

        fragmentManager.popBackStack(sceneId, FragmentManager.POP_BACK_STACK_INCLUSIVE);
    }

    public void pop() {
        pop(true);
    }

    public void present(@NonNull String moduleName, int requestCode, Bundle props, Bundle options, boolean animated) {
        NavigationFragment fragment = createFragment(moduleName, props, options);
        fragment.setRequestCode(requestCode);
        if (animated) {
            fragment.setCurrentAnimations(PresentAnimation.Modal);
            anim = PresentAnimation.Modal;
        }

        NavigationFragment selfFragment = getSelfFragment();

        fragmentManager
                .beginTransaction()
                .setReorderingAllowed(true)
                .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN)
                .add(containerId, fragment, fragment.getNavId())
                .hide(selfFragment)
                .addToBackStack(fragment.getNavId())
                .commit();
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
        Fragment fragment = fragmentManager.findFragmentByTag(sceneId);
        if (fragment == null) {
            fragment = fragmentManager.findFragmentByTag(navId);
        }
        return (NavigationFragment) fragment;
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
                if (name.equals(fragment.getNavigator().sceneId) || name.equals(fragment.getNavigator().navId)) {
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

}
