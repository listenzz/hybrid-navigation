package com.navigation.androidx;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.HapticFeedbackConstants;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.window.BackEvent;
import android.window.OnBackAnimationCallback;
import android.window.OnBackInvokedCallback;
import android.window.OnBackInvokedDispatcher;

import com.facebook.react.uimanager.RootView;
import com.facebook.react.uimanager.events.NativeGestureUtil;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collections;

import androidx.core.view.GravityCompat;
import androidx.customview.widget.ViewDragHelper;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.appcompat.app.AppCompatActivity;

public class HybridDrawerLayout extends DrawerLayout {

    private static final int DRAG_NONE = 0;
    private static final int DRAG_OPEN = 1;
    private static final int DRAG_CLOSE = 2;
    private static final int SYSTEM_GESTURE_EXCLUSION_WIDTH_DP = 200;
    private static final int OPEN_EDGE_WIDTH_DP = SYSTEM_GESTURE_EXCLUSION_WIDTH_DP;
    private static final int OPEN_GESTURE_ACTIVATION_DISTANCE_DP = 24;
    private static final int SETTLE_VELOCITY_DP = 350;
    private static final float HORIZONTAL_ACTIVATION_RATIO = 1.2f;
    private static final float OPEN_SETTLE_THRESHOLD = 0.22f;
    private static final float CLOSE_SETTLE_THRESHOLD = 0.78f;
    private static final float DRAWER_CLOSED_EPSILON = 0.01f;

    private final int openEdgeWidth;
    private final int systemGestureExclusionWidth;
    private final int openGestureTriggerDistance;
    private final int settleVelocity;
    private final int touchSlop;
    private float downX;
    private float downY;
    private float dragStartProgress;
    private boolean closeDragCandidate;
    private boolean openDragCandidate;
    private boolean openGestureEnabled;
    private boolean nativeGestureStarted;
    private int activeDragMode = DRAG_NONE;
    private View activeDrawerChild;
    private View activeNativeGestureView;
    private VelocityTracker velocityTracker;
    private OnBackInvokedCallback backGestureCallback;
    private boolean backGestureCallbackRegistered;
    private boolean backGestureActive;
    private float backGestureProgress;
    private Method getDrawerViewOffsetMethod;
    private Method moveDrawerToOffsetMethod;

    public HybridDrawerLayout(Context context) {
        this(context, null);
    }

    public HybridDrawerLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public HybridDrawerLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        float density = getResources().getDisplayMetrics().density;
        openEdgeWidth = Math.round(OPEN_EDGE_WIDTH_DP * density);
        systemGestureExclusionWidth = Math.round(SYSTEM_GESTURE_EXCLUSION_WIDTH_DP * density);
        touchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
        openGestureTriggerDistance = Math.max(touchSlop * 2, Math.round(OPEN_GESTURE_ACTIVATION_DISTANCE_DP * density));
        settleVelocity = Math.round(SETTLE_VELOCITY_DP * density);
        setupDrawerInternals();
    }

    public void setOpenGestureEnabled(boolean enabled) {
        openGestureEnabled = enabled;
        updateSystemGestureExclusionRect();
        updateBackGestureCallback();
    }

    @Override
    public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {
        if (disallowIntercept && (openDragCandidate || activeDragMode != DRAG_NONE)) {
            super.requestDisallowInterceptTouchEvent(false);
            return;
        }
        super.requestDisallowInterceptTouchEvent(disallowIntercept);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        updateSystemGestureExclusionRect();
        updateBackGestureCallback();
    }

    @Override
    protected void onDetachedFromWindow() {
        unregisterBackGestureCallback();
        super.onDetachedFromWindow();
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        updateSystemGestureExclusionRect();
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        int action = event.getActionMasked();
        if (action == MotionEvent.ACTION_DOWN) {
            beginTouchTracking(event);
        } else if (velocityTracker != null) {
            velocityTracker.addMovement(event);
        }

        if (activeDragMode != DRAG_NONE) {
            return handleActiveDrawerDrag(event);
        } else if (action == MotionEvent.ACTION_MOVE) {
            if (tryStartDrawerDrag(event)) {
                return handleActiveDrawerDrag(event);
            }
        } else if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL) {
            resetTouchTracking();
        }

        return super.dispatchTouchEvent(event);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        int action = event.getActionMasked();
        if (activeDragMode != DRAG_NONE) {
            return true;
        }

        if (action == MotionEvent.ACTION_DOWN) {
            return isDrawerVisible(GravityCompat.START) && super.onInterceptTouchEvent(event);
        }

        if (!isDrawerVisible(GravityCompat.START)) {
            if (!openGestureEnabled || !openDragCandidate) {
                return false;
            }

            if (action == MotionEvent.ACTION_MOVE && isVerticalGesture(event)) {
                openDragCandidate = false;
            } else if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL) {
                openDragCandidate = false;
            }
            return false;
        }

        return super.onInterceptTouchEvent(event);
    }

    private void setupDrawerInternals() {
        setDrawerEdgeSize(openEdgeWidth);
        getDrawerViewOffsetMethod = findDrawerLayoutMethod("getDrawerViewOffset", View.class);
        moveDrawerToOffsetMethod = findDrawerLayoutMethod("moveDrawerToOffset", View.class, float.class);
    }

    private void updateBackGestureCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return;
        }

        if (!openGestureEnabled || !isAttachedToWindow()) {
            unregisterBackGestureCallback();
            return;
        }

        if (backGestureCallbackRegistered) {
            return;
        }

        Activity activity = findActivity();
        if (activity == null) {
            return;
        }

        backGestureCallback = createBackGestureCallback();
        activity.getOnBackInvokedDispatcher().registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_OVERLAY,
                backGestureCallback
        );
        backGestureCallbackRegistered = true;
    }

    private void unregisterBackGestureCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || !backGestureCallbackRegistered) {
            return;
        }

        Activity activity = findActivity();
        if (activity != null && backGestureCallback != null) {
            activity.getOnBackInvokedDispatcher().unregisterOnBackInvokedCallback(backGestureCallback);
        }
        backGestureCallbackRegistered = false;
        backGestureCallback = null;
        backGestureActive = false;
        backGestureProgress = 0;
    }

    private OnBackAnimationCallback createBackGestureCallback() {
        return new OnBackAnimationCallback() {
            @Override
            public void onBackStarted(BackEvent backEvent) {
                beginBackGesture(backEvent);
            }

            @Override
            public void onBackProgressed(BackEvent backEvent) {
                progressBackGesture(backEvent);
            }

            @Override
            public void onBackCancelled() {
                cancelBackGesture();
            }

            @Override
            public void onBackInvoked() {
                finishBackGesture();
            }
        };
    }

    private void beginBackGesture(BackEvent backEvent) {
        backGestureActive = openGestureEnabled
                && backEvent.getSwipeEdge() == BackEvent.EDGE_LEFT
                && isDrawerClosed();
        backGestureProgress = 0;

        if (backGestureActive) {
            activeDrawerChild = findDrawerChild();
            if (activeDrawerChild == null || activeDrawerChild.getWidth() <= 0) {
                backGestureActive = false;
                return;
            }
            performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
            moveDrawerToProgress(activeDrawerChild, 0);
        }
    }

    private void progressBackGesture(BackEvent backEvent) {
        if (!backGestureActive || activeDrawerChild == null) {
            return;
        }

        backGestureProgress = backEvent.getProgress();
        moveDrawerToProgress(activeDrawerChild, backGestureProgress);
    }

    private void cancelBackGesture() {
        if (backGestureActive) {
            closeDrawer(GravityCompat.START);
        }
        backGestureActive = false;
        backGestureProgress = 0;
        activeDrawerChild = null;
    }

    private void finishBackGesture() {
        if (!backGestureActive) {
            invokeFallbackBack();
            return;
        }

        openDrawer(GravityCompat.START);
        backGestureActive = false;
        backGestureProgress = 0;
        activeDrawerChild = null;
    }

    private void invokeFallbackBack() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            unregisterBackGestureCallback();
        }

        Activity activity = findActivity();
        if (activity instanceof AppCompatActivity) {
            ((AppCompatActivity) activity).getOnBackPressedDispatcher().onBackPressed();
        } else if (activity != null) {
            activity.onBackPressed();
        }

        post(this::updateBackGestureCallback);
    }

    private Method findDrawerLayoutMethod(String name, Class<?>... parameterTypes) {
        try {
            Method method = DrawerLayout.class.getDeclaredMethod(name, parameterTypes);
            method.setAccessible(true);
            return method;
        } catch (NoSuchMethodException ignored) {
            return null;
        }
    }

    private void updateSystemGestureExclusionRect() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (openGestureEnabled) {
                int width = getWidth() == 0 ? systemGestureExclusionWidth : Math.min(systemGestureExclusionWidth, getWidth());
                setSystemGestureExclusionRects(Collections.singletonList(new Rect(0, 0, width, getHeight())));
            } else {
                setSystemGestureExclusionRects(new ArrayList<>());
            }
        }
    }

    private void setDrawerEdgeSize(int edgeSize) {
        try {
            Field leftDraggerField = DrawerLayout.class.getDeclaredField("mLeftDragger");
            leftDraggerField.setAccessible(true);
            ViewDragHelper leftDragger = (ViewDragHelper) leftDraggerField.get(this);
            Field edgeSizeField = leftDragger.getClass().getDeclaredField("mEdgeSize");
            edgeSizeField.setAccessible(true);
            edgeSizeField.setInt(leftDragger, edgeSize);
        } catch (NoSuchFieldException | IllegalAccessException | ClassCastException ignored) {
        }
    }

    private void beginTouchTracking(MotionEvent event) {
        downX = event.getX();
        downY = event.getY();
        dragStartProgress = 0;
        activeDragMode = DRAG_NONE;
        activeDrawerChild = findDrawerChild();
        float drawerProgress = getDrawerProgress(activeDrawerChild);
        closeDragCandidate = drawerProgress > 0;
        openDragCandidate = openGestureEnabled && drawerProgress <= DRAWER_CLOSED_EPSILON && downX <= openEdgeWidth;
        nativeGestureStarted = false;
        activeNativeGestureView = findNativeGestureView(this, downX, downY);
        recycleVelocityTracker();
        velocityTracker = VelocityTracker.obtain();
        velocityTracker.addMovement(event);
    }

    private boolean tryStartDrawerDrag(MotionEvent event) {
        if (isVerticalGesture(event)) {
            openDragCandidate = false;
            closeDragCandidate = false;
            return false;
        }

        float dx = event.getX() - downX;
        float dy = Math.abs(event.getY() - downY);
        if (openDragCandidate && dx > openGestureTriggerDistance && dx > dy * HORIZONTAL_ACTIVATION_RATIO) {
            return startDrawerDrag(DRAG_OPEN, event);
        }

        if (closeDragCandidate && dx < -touchSlop && Math.abs(dx) > dy * HORIZONTAL_ACTIVATION_RATIO) {
            return startDrawerDrag(DRAG_CLOSE, event);
        }

        return false;
    }

    private boolean isVerticalGesture(MotionEvent event) {
        float dx = Math.abs(event.getX() - downX);
        float dy = Math.abs(event.getY() - downY);
        return dy > touchSlop && dy > dx;
    }

    private boolean startDrawerDrag(int dragMode, MotionEvent event) {
        activeDrawerChild = findDrawerChild();
        if (activeDrawerChild == null || activeDrawerChild.getWidth() <= 0) {
            resetTouchTracking();
            return false;
        }

        activeDragMode = dragMode;
        dragStartProgress = getDrawerProgress(activeDrawerChild);
        notifyNativeGestureStarted(event);
        getParent().requestDisallowInterceptTouchEvent(true);
        performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
        return true;
    }

    private boolean handleActiveDrawerDrag(MotionEvent event) {
        if (activeDrawerChild == null) {
            resetTouchTracking();
            return false;
        }

        int action = event.getActionMasked();
        if (action == MotionEvent.ACTION_MOVE) {
            applyDrawerDragProgress(event);
            return true;
        }

        if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL) {
            applyDrawerDragProgress(event);
            settleDrawerDrag(action == MotionEvent.ACTION_CANCEL, getXVelocity());
            notifyNativeGestureEnded(event);
            resetTouchTracking();
            return true;
        }

        return true;
    }

    private void applyDrawerDragProgress(MotionEvent event) {
        int drawerWidth = activeDrawerChild.getWidth();
        if (drawerWidth <= 0) {
            return;
        }

        float progress = dragStartProgress + (event.getX() - downX) / drawerWidth;
        moveDrawerToProgress(activeDrawerChild, progress);
    }

    private void settleDrawerDrag(boolean cancelled, float velocityX) {
        if (activeDrawerChild == null) {
            return;
        }

        boolean shouldOpen;
        if (cancelled) {
            shouldOpen = activeDragMode == DRAG_CLOSE;
        } else {
            float progress = getDrawerProgress(activeDrawerChild);
            if (activeDragMode == DRAG_OPEN) {
                shouldOpen = progress >= OPEN_SETTLE_THRESHOLD || velocityX >= settleVelocity;
            } else {
                shouldOpen = progress >= CLOSE_SETTLE_THRESHOLD && velocityX >= -settleVelocity;
            }
        }

        if (shouldOpen) {
            openDrawer(GravityCompat.START);
        } else {
            closeDrawer(GravityCompat.START);
        }
    }

    private void moveDrawerToProgress(View drawerChild, float progress) {
        progress = Math.max(0, Math.min(1, progress));
        if (progress > 0) {
            drawerChild.setVisibility(VISIBLE);
        }

        if (!invokeMoveDrawerToOffset(drawerChild, progress)) {
            fallbackMoveDrawerToOffset(drawerChild, progress);
        }

        if (progress == 0) {
            drawerChild.setVisibility(INVISIBLE);
        }
        invalidate();
    }

    private boolean invokeMoveDrawerToOffset(View drawerChild, float progress) {
        if (moveDrawerToOffsetMethod == null) {
            return false;
        }

        try {
            moveDrawerToOffsetMethod.invoke(this, drawerChild, progress);
            return true;
        } catch (IllegalAccessException | InvocationTargetException ignored) {
            return false;
        }
    }

    private void fallbackMoveDrawerToOffset(View drawerChild, float progress) {
        float oldProgress = getDrawerProgress(drawerChild);
        int drawerWidth = drawerChild.getWidth();
        int oldPosition = (int) (drawerWidth * oldProgress);
        int newPosition = (int) (drawerWidth * progress);
        int dx = newPosition - oldPosition;
        drawerChild.offsetLeftAndRight(isStartDrawerOnLeft(drawerChild) ? dx : -dx);
    }

    private float getDrawerProgress(View drawerChild) {
        if (drawerChild == null) {
            return 0;
        }

        if (getDrawerViewOffsetMethod != null) {
            try {
                Object value = getDrawerViewOffsetMethod.invoke(this, drawerChild);
                if (value instanceof Float) {
                    return clampProgress((Float) value);
                }
            } catch (IllegalAccessException | InvocationTargetException ignored) {
            }
        }

        int drawerWidth = drawerChild.getWidth();
        if (drawerWidth <= 0) {
            return isDrawerOpen(drawerChild) ? 1 : 0;
        }

        if (isStartDrawerOnLeft(drawerChild)) {
            return clampProgress((drawerChild.getLeft() + drawerWidth) / (float) drawerWidth);
        }
        return clampProgress((getWidth() - drawerChild.getLeft()) / (float) drawerWidth);
    }

    private float clampProgress(float progress) {
        return Math.max(0, Math.min(1, progress));
    }

    private boolean isDrawerClosed() {
        return getDrawerProgress(findDrawerChild()) <= DRAWER_CLOSED_EPSILON;
    }

    private void notifyNativeGestureStarted(MotionEvent event) {
        if (nativeGestureStarted) {
            return;
        }
        NativeGestureUtil.notifyNativeGestureStarted(getNativeGestureView(), event);
        nativeGestureStarted = true;
    }

    private void notifyNativeGestureEnded(MotionEvent event) {
        if (!nativeGestureStarted) {
            return;
        }
        NativeGestureUtil.notifyNativeGestureEnded(getNativeGestureView(), event);
        nativeGestureStarted = false;
    }

    private View getNativeGestureView() {
        return activeNativeGestureView == null ? this : activeNativeGestureView;
    }

    private void resetTouchTracking() {
        recycleVelocityTracker();
        closeDragCandidate = false;
        openDragCandidate = false;
        activeDragMode = DRAG_NONE;
        activeDrawerChild = null;
        activeNativeGestureView = null;
        dragStartProgress = 0;
        nativeGestureStarted = false;
    }

    private float getXVelocity() {
        if (velocityTracker == null) {
            return 0;
        }

        velocityTracker.computeCurrentVelocity(1000);
        return velocityTracker.getXVelocity();
    }

    private void recycleVelocityTracker() {
        if (velocityTracker == null) {
            return;
        }

        velocityTracker.recycle();
        velocityTracker = null;
    }

    private View findDrawerChild() {
        for (int i = getChildCount() - 1; i >= 0; i--) {
            View child = getChildAt(i);
            if (isDrawerChild(child)) {
                return child;
            }
        }
        return null;
    }

    private View findNativeGestureView(View view, float x, float y) {
        if (view instanceof ViewGroup) {
            ViewGroup group = (ViewGroup) view;
            for (int i = group.getChildCount() - 1; i >= 0; i--) {
                View child = group.getChildAt(i);
                if (child.getVisibility() != VISIBLE || !isPointInsideChild(child, x, y)) {
                    continue;
                }

                float childX = x - child.getLeft() - child.getTranslationX();
                float childY = y - child.getTop() - child.getTranslationY();
                View nativeGestureView = findNativeGestureView(child, childX, childY);
                if (nativeGestureView != null) {
                    return nativeGestureView;
                }
            }
        }

        return view instanceof RootView ? view : null;
    }

    private boolean isPointInsideChild(View child, float x, float y) {
        float left = child.getLeft() + child.getTranslationX();
        float top = child.getTop() + child.getTranslationY();
        return x >= left && x < left + child.getWidth()
                && y >= top && y < top + child.getHeight();
    }

    private Activity findActivity() {
        Context context = getContext();
        while (context instanceof ContextWrapper) {
            if (context instanceof Activity) {
                return (Activity) context;
            }
            context = ((ContextWrapper) context).getBaseContext();
        }
        return null;
    }

    private boolean isDrawerChild(View child) {
        LayoutParams layoutParams = (LayoutParams) child.getLayoutParams();
        int gravity = GravityCompat.getAbsoluteGravity(layoutParams.gravity, getLayoutDirection());
        return (gravity & Gravity.LEFT) == Gravity.LEFT || (gravity & Gravity.RIGHT) == Gravity.RIGHT;
    }

    private boolean isStartDrawerOnLeft(View child) {
        LayoutParams layoutParams = (LayoutParams) child.getLayoutParams();
        int gravity = GravityCompat.getAbsoluteGravity(layoutParams.gravity, getLayoutDirection());
        return (gravity & Gravity.LEFT) == Gravity.LEFT;
    }
}
