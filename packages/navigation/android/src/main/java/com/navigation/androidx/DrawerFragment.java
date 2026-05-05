package com.navigation.androidx;

import com.reactnative.hybridnavigation.R;

import android.graphics.Color;
import android.graphics.Outline;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.HapticFeedbackConstants;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.lifecycle.Lifecycle;

public class DrawerFragment extends AwesomeFragment implements DrawerLayout.DrawerListener {

    private static final String MIN_DRAWER_MARGIN_KEY = "MIN_DRAWER_MARGIN_KEY";
    private static final String MAX_DRAWER_WIDTH_KEY = "MAX_DRAWER_WIDTH_KEY";
    private static final float DRAWER_ANIMATION_CONTENT_CORNER_RADIUS_DP = 18;
    private static final float DRAWER_ANIMATION_CONTENT_ELEVATION_DP = 16;
    private static final float DRAWER_ANIMATION_CONTENT_DIMMING_ALPHA = 0.08f;
    private static final float DRAWER_ANIMATION_MENU_OVERLAY_ALPHA = 0.34f;
    private static final int DRAWER_MENU_BACKGROUND_COLOR = Color.rgb(245, 240, 230);

    private HybridDrawerLayout mDrawerLayout;
    private FrameLayout mContentLayout;
    private FrameLayout mMenuLayout;
    private View mContentDimmingView;
    private View mMenuGradientOverlayView;
    private int mMinDrawerMargin = 64; // dp
    private int mMaxDrawerWidth; // dp
    private float mContentCornerRadius;
    private float mContentElevation;
    private float mDrawerProgress;
    private boolean mDrawerGestureHapticPerformed;
    private boolean mDrawerUserDragging;
    private float mDrawerDragStartProgress;
    private boolean mMenuInteractive = true;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.nav_fragment_drawer, container, false);
        mDrawerLayout = root.findViewById(R.id.drawer);
        mContentLayout = mDrawerLayout.findViewById(R.id.drawer_content);
        mMenuLayout = mDrawerLayout.findViewById(R.id.drawer_menu);
        mContentCornerRadius = AppUtils.dp2px(requireContext(), DRAWER_ANIMATION_CONTENT_CORNER_RADIUS_DP);
        mContentElevation = AppUtils.dp2px(requireContext(), DRAWER_ANIMATION_CONTENT_ELEVATION_DP);

        mDrawerLayout.setBackgroundColor(DRAWER_MENU_BACKGROUND_COLOR);
        mDrawerLayout.setScrimColor(Color.TRANSPARENT);
        mDrawerLayout.setDrawerElevation(0);
        mDrawerLayout.addDrawerListener(this);
        mMenuLayout.setBackgroundColor(DRAWER_MENU_BACKGROUND_COLOR);

        if (savedInstanceState != null) {
            mMinDrawerMargin = savedInstanceState.getInt(MIN_DRAWER_MARGIN_KEY, 64);
            mMaxDrawerWidth = savedInstanceState.getInt(MAX_DRAWER_WIDTH_KEY);
        }

        ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) mMenuLayout.getLayoutParams();
        int screenWidth = AppUtils.getScreenWidth(requireContext());
        int margin1 = AppUtils.dp2px(requireContext(), mMinDrawerMargin);
        if (margin1 > screenWidth) {
            margin1 = screenWidth;
        } else if (margin1 < 0) {
            margin1 = 0;
        }
        if (mMaxDrawerWidth <= 0 || mMaxDrawerWidth > screenWidth) {
            mMaxDrawerWidth = screenWidth;
        }
        int margin2 = screenWidth - AppUtils.dp2px(requireContext(), mMaxDrawerWidth);
        int margin = Math.max(margin1, margin2);
        layoutParams.rightMargin = margin - AppUtils.dp2px(requireContext(), 64);
        mMenuLayout.setLayoutParams(layoutParams);

        setupDrawerChromeViews();

        return root;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (savedInstanceState != null) {
            bringDrawerChromeToFront();
            return;
        }

        if (mContentFragment == null) {
            throw new IllegalArgumentException("必须调用 `setContentFragment` 设置 contentFragment");
        }
        if (mMenuFragment == null) {
            throw new IllegalArgumentException("必须调用 `setMenuFragment` 设置 menuFragment");
        }

        addContentFragment();
        addMenuFragment();
        bringDrawerChromeToFront();
        updateMenuGestureState();
    }

    private void addContentFragment() {
        FragmentManager fragmentManager = getChildFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.add(R.id.drawer_content, mContentFragment, mContentFragment.getSceneId());
        transaction.setPrimaryNavigationFragment(mContentFragment); // primary
        transaction.setMaxLifecycle(mContentFragment, Lifecycle.State.RESUMED);
        transaction.commitNow();
    }

    private void addMenuFragment() {
        FragmentManager fragmentManager = getChildFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.add(R.id.drawer_menu, mMenuFragment, mMenuFragment.getSceneId());
        transaction.setMaxLifecycle(mMenuFragment, Lifecycle.State.STARTED);
        transaction.hide(mMenuFragment);
        transaction.commitNow();
    }

    @Override
    public void onResume() {
        super.onResume();
        opened = opening = isMenuOpened();
        closed = !isMenuOpened();
        requestMenuGestureStateUpdate();
    }

    @Override
    public void onPause() {
        if (mDrawerLayout != null) {
            mDrawerLayout.setOpenGestureEnabled(false);
        }
        super.onPause();
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        if (hidden) {
            if (mDrawerLayout != null) {
                mDrawerLayout.setOpenGestureEnabled(false);
            }
            return;
        }
        requestMenuGestureStateUpdate();
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(MIN_DRAWER_MARGIN_KEY, mMinDrawerMargin);
        outState.putInt(MAX_DRAWER_WIDTH_KEY, mMaxDrawerWidth);
    }

    @Override
    public void onDestroyView() {
        mDrawerLayout.removeDrawerListener(this);
        super.onDestroyView();
    }

    @Override
    public boolean isLeafAwesomeFragment() {
        return false;
    }

    @Nullable
    @Override
    protected AwesomeFragment childFragmentForAppearance() {
        return getContentFragment();
    }

    @Override
    protected boolean preferredStatusBarHidden() {
        return super.preferredStatusBarHidden();
    }

    @Override
    protected boolean onBackPressed() {
        if (isMenuOpened()) {
            closeMenu();
            return true;
        }
        return super.onBackPressed();
    }

    private boolean closed = true;
    private boolean opened = false;
    private boolean closing;
    private boolean opening;

    @Override
    public void onDrawerSlide(@NonNull View drawerView, float slideOffset) {
        applyDrawerProgress(drawerView, slideOffset);
        maybePerformDrawerGestureHaptic(slideOffset);

        if (slideOffset != 0) {
            if (closed) {
                if (!opening) {
                    opening = true;
                    showMenuFragment();
                    setNeedsStatusBarAppearanceUpdate();
                }
            } else if (opened) {
                if (!closing) {
                    closing = true;
                    setNeedsStatusBarAppearanceUpdate();
                }
            }
        }

        if (slideOffset == 0) {
            closed = true;
            opened = false;
            opening = false;
            hideMenuFragment();
            applyDrawerProgress(drawerView, 0);
            updateMenuGestureState();
            setNeedsStatusBarAppearanceUpdate();
        } else if (slideOffset == 1) {
            opened = true;
            closed = false;
            closing = false;
            applyDrawerProgress(drawerView, 1);
            updateMenuGestureState();
        }
    }

    @Override
    public void onDrawerOpened(@NonNull View drawerView) {
        scheduleTaskAtStarted(() -> {
            AwesomeFragment menu = getMenuFragment();
            AwesomeFragment content = getContentFragment();

            if (menu == null || content == null) {
                return;
            }

            applyDrawerProgress(drawerView, 1);

            FragmentManager fragmentManager = getChildFragmentManager();
            fragmentManager.beginTransaction()
                    .setPrimaryNavigationFragment(menu)
                    .setMaxLifecycle(menu, Lifecycle.State.RESUMED)
                    .commitNow();

            View menuView = menu.requireView();
            menuView.setClickable(true);
            updateMenuGestureState();
        });
    }

    @Override
    public void onDrawerClosed(@NonNull View drawerView) {
        scheduleTaskAtStarted(() -> {
            AwesomeFragment menu = getMenuFragment();
            AwesomeFragment content = getContentFragment();
            if (menu == null || content == null) {
                return;
            }

            applyDrawerProgress(drawerView, 0);

            FragmentManager fragmentManager = getChildFragmentManager();
            fragmentManager.beginTransaction()
                    .setPrimaryNavigationFragment(content)
                    .setMaxLifecycle(menu, Lifecycle.State.STARTED)
                    .commit();
            updateMenuGestureState();
        });
    }

    @Override
    public void onDrawerStateChanged(int newState) {
        if (newState == DrawerLayout.STATE_DRAGGING) {
            mDrawerUserDragging = true;
            mDrawerGestureHapticPerformed = false;
            mDrawerDragStartProgress = mDrawerProgress;
        } else if (newState == DrawerLayout.STATE_IDLE) {
            mDrawerUserDragging = false;
            mDrawerGestureHapticPerformed = false;
        }
    }

    private AwesomeFragment mContentFragment;

    public void setContentFragment(final AwesomeFragment fragment) {
        if (isAdded()) {
            throw new IllegalStateException("DrawerFragment 已处于 added 状态，不可以再设置 contentFragment");
        }
        mContentFragment = fragment;
    }

    @Nullable
    public AwesomeFragment getContentFragment() {
        if (isAdded()) {
            return (AwesomeFragment) getChildFragmentManager().findFragmentById(R.id.drawer_content);
        }
        return null;
    }

    @NonNull
    public AwesomeFragment requireContentFragment() {
        AwesomeFragment fragment = getContentFragment();
        if (fragment == null) {
            throw new NullPointerException("No content fragment");
        }
        return fragment;
    }

    private AwesomeFragment mMenuFragment;

    public void setMenuFragment(AwesomeFragment fragment) {
        if (isAdded()) {
            throw new IllegalStateException("DrawerFragment 已处于 added 状态，不可以再设置 menuFragment");
        }
        mMenuFragment = fragment;
    }

    @Nullable
    public AwesomeFragment getMenuFragment() {
        if (isAdded()) {
            return (AwesomeFragment) getChildFragmentManager().findFragmentById(R.id.drawer_menu);
        }
        return null;
    }

    public void setMinDrawerMargin(int dp) {
        this.mMinDrawerMargin = dp;
    }

    public void setMaxDrawerWidth(int dp) {
        this.mMaxDrawerWidth = dp;
    }

    public void openMenu() {
        openMenu(() -> {
        });
    }

    public void closeMenu() {
        closeMenu(() -> {
        });
    }

    public void openMenu(@NonNull Runnable completion) {
        if (isMenuOpened()) {
            completion.run();
            return;
        }

        if (mDrawerLayout == null) {
            throw new IllegalStateException("No drawer");
        }

        mDrawerLayout.addDrawerListener(new DrawerLayout.SimpleDrawerListener() {
            @Override
            public void onDrawerOpened(View drawerView) {
                mDrawerLayout.removeDrawerListener(this);
                completion.run();
            }
        });

        scheduleTaskAtStarted(() -> {
            showMenuFragment();
            mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, GravityCompat.START);
            mDrawerLayout.openDrawer(GravityCompat.START);
        });
    }

    public void closeMenu(@NonNull Runnable completion) {
        if (!isMenuOpened()) {
            completion.run();
            return;
        }

        if (mDrawerLayout == null) {
            throw new IllegalStateException("No drawer");
        }

        mDrawerLayout.addDrawerListener(new DrawerLayout.SimpleDrawerListener() {
            @Override
            public void onDrawerClosed(View drawerView) {
                mDrawerLayout.removeDrawerListener(this);
                completion.run();
            }
        });

        scheduleTaskAtStarted(() -> {
            mDrawerLayout.closeDrawer(GravityCompat.START);
        });
    }

    private void showMenuFragment() {
        AwesomeFragment menu = getMenuFragment();
        AwesomeFragment content = getContentFragment();

        if (menu == null || content == null) {
            return;
        }

        FragmentManager fragmentManager = getChildFragmentManager();
        fragmentManager.beginTransaction()
                .show(menu)
                .commitNow();
        bringDrawerChromeToFront();
    }

    private void hideMenuFragment() {
        AwesomeFragment menu = getMenuFragment();
        AwesomeFragment content = getContentFragment();

        if (menu == null || content == null) {
            return;
        }

        FragmentManager fragmentManager = getChildFragmentManager();
        fragmentManager.beginTransaction()
                .hide(menu)
                .commitNow();
    }

    private void setupDrawerChromeViews() {
        setupContentLayoutOutline();
        setupContentDimmingView();
        setupMenuGradientOverlayView();
        bringDrawerChromeToFront();
        applyDrawerProgress(mMenuLayout, isMenuOpened() ? 1 : 0);
    }

    private void setupContentLayoutOutline() {
        mContentLayout.setOutlineProvider(new ViewOutlineProvider() {
            @Override
            public void getOutline(View view, Outline outline) {
                float radius = mContentCornerRadius * mDrawerProgress;
                outline.setRoundRect(0, 0, view.getWidth(), view.getHeight(), radius);
            }
        });
    }

    private void setupContentDimmingView() {
        mContentDimmingView = new View(requireContext());
        mContentDimmingView.setBackgroundColor(Color.BLACK);
        mContentDimmingView.setAlpha(0);
        mContentDimmingView.setClickable(false);
        mContentLayout.addView(mContentDimmingView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        ));
    }

    private void setupMenuGradientOverlayView() {
        GradientDrawable overlay = new GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT, new int[]{
                Color.argb(Math.round(255 * DRAWER_ANIMATION_MENU_OVERLAY_ALPHA * 0.32f), 0, 0, 0),
                Color.argb(Math.round(255 * DRAWER_ANIMATION_MENU_OVERLAY_ALPHA * 0.6f), 0, 0, 0),
                Color.argb(Math.round(255 * DRAWER_ANIMATION_MENU_OVERLAY_ALPHA), 0, 0, 0)
        });

        mMenuGradientOverlayView = new View(requireContext());
        mMenuGradientOverlayView.setBackground(overlay);
        mMenuGradientOverlayView.setAlpha(0);
        mMenuGradientOverlayView.setClickable(false);
        mMenuLayout.addView(mMenuGradientOverlayView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        ));
    }

    private void bringDrawerChromeToFront() {
        if (mMenuGradientOverlayView != null) {
            mMenuGradientOverlayView.bringToFront();
        }
        if (mContentDimmingView != null) {
            mContentDimmingView.bringToFront();
        }
    }

    private void applyDrawerProgress(@NonNull View drawerView, float progress) {
        progress = Math.max(0, Math.min(1, progress));
        mDrawerProgress = progress;

        int drawerWidth = drawerView.getWidth();
        drawerView.setTranslationX(drawerWidth * (1 - progress));
        mContentLayout.setTranslationX(drawerWidth * progress);
        mContentLayout.setClipToOutline(progress > 0);
        mContentLayout.setElevation(mContentElevation * progress);
        mContentLayout.invalidateOutline();

        mContentDimmingView.setAlpha(DRAWER_ANIMATION_CONTENT_DIMMING_ALPHA * progress);
        mMenuGradientOverlayView.setAlpha(1 - progress);
    }

    private void maybePerformDrawerGestureHaptic(float progress) {
        if (!mDrawerUserDragging || mDrawerGestureHapticPerformed) {
            return;
        }

        if (Math.abs(progress - mDrawerDragStartProgress) > 0.015f) {
            performDrawerGestureHaptic();
        }
    }

    private void performDrawerGestureHaptic() {
        if (mDrawerLayout == null || mDrawerGestureHapticPerformed) {
            return;
        }

        mDrawerLayout.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
        mDrawerGestureHapticPerformed = true;
    }

    public void setDrawerLockMode(final int lockMode) {
        if (mDrawerLayout != null) {
            mDrawerLayout.setDrawerLockMode(lockMode, GravityCompat.START);
        }
    }

    public void setMenuInteractive(boolean enabled) {
        mMenuInteractive = enabled;
        scheduleTaskAtStarted(this::updateMenuGestureState);
    }

    public void updateMenuGestureState() {
        if (mDrawerLayout == null) {
            return;
        }

        boolean drawerVisible = mDrawerProgress > 0 || isMenuOpened();
        boolean canOpenByGesture = isResumed() && isDrawerStackRoot() && mMenuInteractive && isContentStackRoot();
        mDrawerLayout.setOpenGestureEnabled(canOpenByGesture);
        mDrawerLayout.setDrawerLockMode(drawerVisible || canOpenByGesture
                ? DrawerLayout.LOCK_MODE_UNLOCKED
                : DrawerLayout.LOCK_MODE_LOCKED_CLOSED, GravityCompat.START);
    }

    private void requestMenuGestureStateUpdate() {
        updateMenuGestureState();
        HybridDrawerLayout drawerLayout = mDrawerLayout;
        if (drawerLayout != null) {
            drawerLayout.post(() -> {
                if (mDrawerLayout == drawerLayout) {
                    updateMenuGestureState();
                }
            });
        }
    }

    public void toggleMenu() {
        toggleMenu(() -> {
        });
    }

    public void toggleMenu(@NonNull Runnable completion) {
        if (isMenuOpened()) {
            closeMenu(completion);
        } else {
            openMenu(completion);
        }
    }

    public boolean isMenuOpened() {
        if (mDrawerLayout != null) {
            return mDrawerLayout.isDrawerOpen(GravityCompat.START);
        }
        return false;
    }

    public boolean isMenuPrimary() {
        return !(closed || closing);
    }

    private boolean isContentStackRoot() {
        AwesomeFragment content = getCurrentContentFragmentForDrawerGesture();
        return content != null && content.isStackRoot();
    }

    @Nullable
    private AwesomeFragment getCurrentContentFragmentForDrawerGesture() {
        AwesomeFragment content = getContentFragment();
        if (content instanceof TabBarFragment) {
            content = ((TabBarFragment) content).getSelectedFragment();
        }
        if (content instanceof StackFragment) {
            AwesomeFragment top = ((StackFragment) content).getTopFragment();
            return top == null ? content : top;
        }
        return content;
    }

    private boolean isDrawerStackRoot() {
        StackFragment stackFragment = getStackFragment();
        return stackFragment == null || isStackRoot();
    }

}
