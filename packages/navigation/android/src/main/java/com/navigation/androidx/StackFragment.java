package com.navigation.androidx;

import com.reactnative.hybridnavigation.R;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.lifecycle.Lifecycle;

import java.util.List;

public class StackFragment extends AwesomeFragment {

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FragmentManager fragmentManager = getChildFragmentManager();
        fragmentManager.addOnBackStackChangedListener(new FragmentManager.OnBackStackChangedListener() {
            @Override
            public void onBackStackChanged() {
                setNeedsStatusBarAppearanceUpdate();
                setNeedsNavigationBarAppearanceUpdate();
                setNeedsLayoutInDisplayCutoutModeUpdate();
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.nav_fragment_navigation, container, false);
    }

    @Override
    protected void performCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.performCreateView(inflater, container, savedInstanceState);
        if (savedInstanceState != null) {
            return;
        }

        if (mRootFragment == null) {
            throw new IllegalArgumentException("Must specify rootFragment by `setRootFragment`.");
        }

        FragmentHelper.addFragmentToBackStack(getChildFragmentManager(), R.id.navigation_content, mRootFragment, TransitionAnimation.None);
        mRootFragment = null;
    }

    @Override
    public boolean isLeafAwesomeFragment() {
        return false;
    }

    @Nullable
    @Override
    protected AwesomeFragment childFragmentForAppearance() {
        return getTopFragment();
    }

    @Override
    protected boolean onBackPressed() {
        AwesomeFragment topFragment = getTopFragment();
        if (topFragment != null && !topFragment.isBackInteractive()) {
            return true;
        }

        FragmentManager fragmentManager = getChildFragmentManager();
        int count = fragmentManager.getBackStackEntryCount();
        if (count > 1) {
            popFragment();
            return true;
        }
        return super.onBackPressed();
    }

    private AwesomeFragment mRootFragment;

    public void setRootFragment(@NonNull AwesomeFragment fragment) {
        if (isAdded()) {
            throw new IllegalStateException("StackFragment is at added state，can not `setRootFragment` any more.");
        }
        mRootFragment = fragment;
    }

    @Nullable
    public AwesomeFragment getRootFragment() {
        if (isAdded()) {
            FragmentManager fragmentManager = getChildFragmentManager();
            int count = fragmentManager.getBackStackEntryCount();
            if (count > 0) {
                FragmentManager.BackStackEntry backStackEntry = fragmentManager.getBackStackEntryAt(0);
                return (AwesomeFragment) fragmentManager.findFragmentByTag(backStackEntry.getName());
            }
        }
        return mRootFragment;
    }

    public void pushFragment(@NonNull AwesomeFragment fragment) {
        scheduleTaskAtStarted(() -> pushFragmentSync(fragment, () -> {
        }, TransitionAnimation.Push));
    }

    public void pushFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion) {
        scheduleTaskAtStarted(() -> pushFragmentSync(fragment, completion, TransitionAnimation.Push));
    }

    public void pushFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        scheduleTaskAtStarted(() -> pushFragmentSync(fragment, completion, animation));
    }

    protected void pushFragmentSync(AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        FragmentManager fragmentManager = getChildFragmentManager();
        FragmentHelper.addFragmentToBackStack(fragmentManager, R.id.navigation_content, fragment, animation);
        fragmentManager.executePendingTransactions();
        completion.run();
    }

    public void popToFragment(@NonNull AwesomeFragment fragment) {
        scheduleTaskAtStarted(() -> popToFragmentSync(fragment, () -> {
        }, TransitionAnimation.Push));
    }

    public void popToFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion) {
        scheduleTaskAtStarted(() -> popToFragmentSync(fragment, completion, TransitionAnimation.Push));
    }

    public void popToFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        scheduleTaskAtStarted(() -> popToFragmentSync(fragment, completion, animation));
    }

    protected void popToFragmentSync(AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        if (SystemUI.isImeVisible(getWindow())) {
            SystemUI.hideIme(getWindow());
        }

        AwesomeFragment topFragment = getTopFragment();
        if (topFragment == null || topFragment == fragment) {
            completion.run();
            return;
        }

        topFragment.setAnimation(animation);
        fragment.setAnimation(animation);
        FragmentManager fragmentManager = getChildFragmentManager();
        fragmentManager.beginTransaction()
                .setMaxLifecycle(topFragment, Lifecycle.State.STARTED)
                .setMaxLifecycle(fragment, Lifecycle.State.RESUMED)
                .commitNow();
        fragmentManager.popBackStackImmediate(fragment.getSceneId(), 0);

        completion.run();
        FragmentHelper.handleFragmentResult(fragment, topFragment);
    }

    public void popFragment() {
        scheduleTaskAtStarted(() -> popFragmentSync(() -> {
        }, TransitionAnimation.Push));
    }

    public void popFragment(@NonNull Runnable completion) {
        scheduleTaskAtStarted(() -> popFragmentSync(completion, TransitionAnimation.Push));
    }

    public void popFragment(@NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        scheduleTaskAtStarted(() -> popFragmentSync(completion, animation));
    }

    protected void popFragmentSync(@NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        AwesomeFragment topFragment = getTopFragment();
        if (topFragment == null) {
            completion.run();
            return;
        }

        AwesomeFragment precursor = FragmentHelper.getFragmentBefore(topFragment);
        if (precursor == null) {
            completion.run();
            return;
        }

        popToFragmentSync(precursor, completion, animation);
    }

    public void popToRootFragment() {
        scheduleTaskAtStarted(() -> popToRootFragmentSync(() -> {
        }, TransitionAnimation.Push));
    }

    public void popToRootFragment(@NonNull Runnable completion) {
        scheduleTaskAtStarted(() -> popToRootFragmentSync(completion, TransitionAnimation.Push));
    }

    public void popToRootFragment(@NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        scheduleTaskAtStarted(() -> popToRootFragmentSync(completion, animation));
    }

    protected void popToRootFragmentSync(@NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        AwesomeFragment rootFragment = getRootFragment();
        if (rootFragment == null) {
            completion.run();
            return;
        }
        popToFragmentSync(rootFragment, completion, animation);
    }

    public void redirectToFragment(@NonNull AwesomeFragment fragment) {
        scheduleTaskAtStarted(() -> redirectToFragmentSync(fragment, () -> {
        }, TransitionAnimation.Redirect, null));
    }

    public void redirectToFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion) {
        scheduleTaskAtStarted(() -> redirectToFragmentSync(fragment, completion, TransitionAnimation.Redirect, null));
    }

    public void redirectToFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        scheduleTaskAtStarted(() -> redirectToFragmentSync(fragment, completion, animation, null));
    }

    public void redirectToFragment(@NonNull AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation, @NonNull AwesomeFragment from) {
        scheduleTaskAtStarted(() -> redirectToFragmentSync(fragment, completion, animation, from));
    }

    protected void redirectToFragmentSync(@NonNull AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation, @Nullable AwesomeFragment from) {
        AwesomeFragment topFragment = getTopFragment();
        if (topFragment == null) {
            completion.run();
            return;
        }

        if (SystemUI.isImeVisible(getWindow())) {
            SystemUI.hideIme(getWindow());
        }

        topFragment.setAnimation(animation);

        AwesomeFragment target = from;
        if (target == null) {
            target = topFragment;
        }

        AwesomeFragment precursor = FragmentHelper.getFragmentBefore(target);
        if (precursor != null && precursor.isAdded()) {
            precursor.setAnimation(animation);
        }

        FragmentManager fragmentManager = getChildFragmentManager();
        fragmentManager.beginTransaction().setMaxLifecycle(topFragment, Lifecycle.State.STARTED).commit();
        fragmentManager.popBackStack(target.getSceneId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);

        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.setReorderingAllowed(true);
        transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        if (precursor != null && precursor.isAdded()) {
            transaction.hide(precursor);
            transaction.setMaxLifecycle(precursor, Lifecycle.State.STARTED);
        }
        fragment.setAnimation(animation);
        transaction.add(R.id.navigation_content, fragment, fragment.getSceneId());
        transaction.addToBackStack(fragment.getSceneId());
        transaction.commit();
        fragmentManager.executePendingTransactions();

        completion.run();
    }

    public void setChildFragments(List<AwesomeFragment> fragments) {
        // TODO
        // 弹出所有旧的 fragment

        // 添加所有新的 fragment
    }

    @Nullable
    public AwesomeFragment getTopFragment() {
        if (isAdded()) {
            return (AwesomeFragment) getChildFragmentManager().findFragmentById(R.id.navigation_content);
        }
        return null;
    }

}
