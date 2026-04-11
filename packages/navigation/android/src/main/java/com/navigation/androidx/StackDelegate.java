package com.navigation.androidx;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Bundle;
import android.view.Gravity;
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

        return mFragment == stackFragment.getRootFragment() || stackFragment.shouldShowTabBarWhenPushed();
    }

    boolean drawTabBarIfNeeded(int transit, boolean enter, Animation anim) {
        if (!hasStackParent()) {
            return false;
        }

        StackFragment stackFragment = mFragment.requireStackFragment();
        TabBarFragment tabBarFragment = stackFragment.getTabBarFragment();

        if (tabBarFragment == null || tabBarFragment.getSelectedFragment() != stackFragment) {
            return false;
        }

        if (mFragment != stackFragment.getRootFragment() || stackFragment.shouldShowTabBarWhenPushed()) {
            return false;
        }

        if (transit == FragmentTransaction.TRANSIT_FRAGMENT_OPEN && !enter) {
            drawTabBar(tabBarFragment, anim.getDuration(), true);
            tabBarFragment.hideTabBarAnimated(anim);
            return true;
        }

        if (transit == FragmentTransaction.TRANSIT_FRAGMENT_CLOSE && enter) {
            drawTabBar(tabBarFragment, anim.getDuration(), false);
            tabBarFragment.showTabBarAnimated(anim);
            return true;
        }

        return false;
    }

    private void drawTabBar(@NonNull TabBarFragment tabBarFragment, long duration, boolean open) {
        int vWidth = tabBarFragment.requireView().getWidth();
        int vHeight = tabBarFragment.requireView().getHeight();

        View tabBar = tabBarFragment.getTabBar();
        if (tabBar.getMeasuredWidth() == 0) {
            tabBar.measure(View.MeasureSpec.makeMeasureSpec(vWidth, View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
            tabBar.layout(0, 0, tabBar.getMeasuredWidth(), tabBar.getMeasuredHeight());
        }

        Bitmap bitmap = AppUtils.createBitmapFromView(tabBar);
        BitmapDrawable bitmapDrawable = new BitmapDrawable(mFragment.getResources(), bitmap);
        bitmapDrawable.setBounds(0, vHeight - tabBar.getHeight(),
                tabBar.getMeasuredWidth(), vHeight);
        bitmapDrawable.setGravity(Gravity.BOTTOM);

        ColorDrawable colorDrawable = new ColorDrawable(0x00000000);
        colorDrawable.setBounds(0, 0, vWidth, vHeight);

        LayerDrawable layerDrawable = new LayerDrawable(new Drawable[]{bitmapDrawable, colorDrawable,});
        layerDrawable.setBounds(0, 0, vWidth, vHeight);

        FrameLayout root = requireView();
        root.setForeground(layerDrawable);
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
        }, duration + 8);

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
