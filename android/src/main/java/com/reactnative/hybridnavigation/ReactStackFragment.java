package com.reactnative.hybridnavigation;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.StackFragment;
import com.navigation.androidx.TabBarItem;
import com.navigation.androidx.TransitionAnimation;

/**
 * Created by Listen on 2018/1/15.
 */

public class ReactStackFragment extends StackFragment {

    private final ReactBridgeManager bridgeManager = ReactBridgeManager.get();

    @NonNull
    public ReactBridgeManager getReactBridgeManager() {
        return bridgeManager;
    }

    @Override
    public void setRootFragment(@NonNull AwesomeFragment fragment) {
        super.setRootFragment(fragment);
        if (fragment instanceof HybridFragment) {
            HybridFragment hybridFragment = (HybridFragment) fragment;
            TabBarItem tabBarItem = hybridFragment.getTabBarItem();
            if (tabBarItem != null) {
                setTabBarItem(tabBarItem);
            }
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        bridgeManager.watchMemory(this);
    }

    private final static TransitionAnimation BetterPush = new TransitionAnimation(R.anim.nav_push_translucent_enter, R.anim.nav_push_translucent_exit, R.anim.nav_pop_translucent_enter, R.anim.nav_pop_translucent_exit);
    private final static TransitionAnimation BetterRedirect = new TransitionAnimation(R.anim.nav_push_translucent_enter, R.anim.nav_gone, R.anim.nav_none, R.anim.nav_push_translucent_exit);

    @Override
    protected void pushFragmentSync(AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        if (fragment instanceof ReactFragment) {
            ReactFragment reactFragment = (ReactFragment) fragment;
            if (reactFragment.shouldPassThroughTouches()) {
                super.pushFragmentSync(fragment, completion, BetterPush);
                return;
            }
        }
        super.pushFragmentSync(fragment, completion, animation);
    }

    @Override
    protected void popToFragmentSync(AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation) {
        AwesomeFragment topFragment = getTopFragment();
        if (topFragment instanceof ReactFragment) {
            ReactFragment reactFragment = (ReactFragment) topFragment;
            if (reactFragment.shouldPassThroughTouches()) {
                super.popToFragmentSync(fragment, completion, BetterPush);
                return;
            }
        }
        super.popToFragmentSync(fragment, completion, animation);
    }

    @Override
    protected void redirectToFragmentSync(@NonNull AwesomeFragment fragment, @NonNull Runnable completion, @NonNull TransitionAnimation animation, @Nullable AwesomeFragment from) {
        if (fragment instanceof ReactFragment) {
            ReactFragment reactFragment = (ReactFragment) fragment;
            if (reactFragment.shouldPassThroughTouches()) {
                super.redirectToFragmentSync(fragment, completion, BetterRedirect, from);
                return;
            }
        }
        super.redirectToFragmentSync(fragment, completion, animation, from);
    }
}
