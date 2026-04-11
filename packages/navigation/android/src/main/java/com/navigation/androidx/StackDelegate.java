package com.navigation.androidx;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.animation.Animation;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import androidx.fragment.app.FragmentTransaction;

public class StackDelegate {

    private final AwesomeFragment mFragment;

    public StackDelegate(AwesomeFragment fragment) {
        mFragment = fragment;
    }

    public Window getWindow() {
        return mFragment.getWindow();
    }

    private FrameLayout requireView() {
        return (FrameLayout) mFragment.requireView();
    }

    private Style getStyle() {
        return mFragment.mStyle;
    }

    private Context requireContext() {
        return mFragment.requireContext();
    }

    public LayoutInflater onGetLayoutInflater(LayoutInflater layoutInflater, @Nullable Bundle savedInstanceState) {
        return new StackLayoutInflater(requireContext(), layoutInflater);
    }

    public boolean isStackRoot() {
        if (!hasStackParent()) {
            return false;
        }
        StackFragment stackFragment = mFragment.requireStackFragment();
        return mFragment == stackFragment.getRootFragment();
    }

    public boolean hasStackParent() {
        AwesomeFragment parent = mFragment.getParentAwesomeFragment();
        return (parent instanceof StackFragment);
    }

    public boolean shouldFitsTabBar() {
        if (!hasStackParent()) {
            return false;
        }

        StackFragment stackFragment = mFragment.requireStackFragment();
        TabBarFragment tabBarFragment = stackFragment.getTabBarFragment();
        if (tabBarFragment == null) {
            return false;
        }

        return mFragment == stackFragment.getRootFragment();
    }

    void drawScrimIfNeeded(int transit, boolean enter, Animation anim) {
        if (!hasStackParent()) {
            return;
        }
        StackFragment stackFragment = mFragment.requireStackFragment();

        TransitionAnimation animation = mFragment.getAnimation();
        if (animation.exit == animation.popEnter) {
            if (transit == FragmentTransaction.TRANSIT_FRAGMENT_CLOSE && !enter) {
                ViewCompat.setTranslationZ(requireView(), -1f);
                drawScrim(stackFragment, anim.getDuration(), true);
            }
        } else {
            if (transit == FragmentTransaction.TRANSIT_FRAGMENT_OPEN && !enter) {
                drawScrim(stackFragment, anim.getDuration(), true);
            } else if (transit == FragmentTransaction.TRANSIT_FRAGMENT_CLOSE && enter) {
                drawScrim(stackFragment, anim.getDuration(), false);
            }
        }
    }

    private void drawScrim(@NonNull StackFragment stackFragment, long duration, boolean open) {
        int vWidth = stackFragment.requireView().getWidth();
        int vHeight = stackFragment.requireView().getHeight();

        ColorDrawable colorDrawable = new ColorDrawable(0x00000000);
        colorDrawable.setBounds(0, 0, vWidth, vHeight);

        FrameLayout root = requireView();
        root.setForeground(colorDrawable);
        int scrimAlpha = getStyle().getScrimAlpha();
        ValueAnimator valueAnimator = open ? ValueAnimator.ofInt(0, scrimAlpha) : ValueAnimator.ofInt(scrimAlpha, 0);
        valueAnimator.setDuration(duration);
        valueAnimator.addUpdateListener(animation -> {
            int value = (Integer) animation.getAnimatedValue();
            colorDrawable.setColor(value << 24);
        });
        valueAnimator.start();

        root.postDelayed(() -> {
            if (mFragment.isAdded()) {
                root.setForeground(null);
            }
        }, duration);
    }
}
