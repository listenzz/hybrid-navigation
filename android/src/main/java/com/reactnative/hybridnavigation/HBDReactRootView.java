package com.reactnative.hybridnavigation;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewTreeObserver;

import androidx.annotation.Nullable;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;

import java.lang.reflect.Method;

public class HBDReactRootView extends ReactRootView {

    protected static final String TAG = "Navigation";

    public HBDReactRootView(Context context) {
        super(context);
    }

    public HBDReactRootView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public HBDReactRootView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    private boolean shouldConsumeTouchEvent = true;

    public void setShouldConsumeTouchEvent(boolean consume) {
        this.shouldConsumeTouchEvent = consume;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        int action = ev.getAction() & MotionEvent.ACTION_MASK;
        if (action == MotionEvent.ACTION_DOWN) {
            onChildStartedNativeGesture(ev);
        }
        return shouldConsumeTouchEvent;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        removeOnGlobalLayoutListener();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeOnGlobalLayoutListener();
    }

    @Override
    public void startReactApplication(ReactInstanceManager reactInstanceManager, String moduleName, @Nullable Bundle initialProperties) {
        super.startReactApplication(reactInstanceManager, moduleName, initialProperties);
        removeOnGlobalLayoutListener();
    }

    // 避免 reload 时，重复 run 的问题
    private boolean shouldRunApplication = true;

    @Override
    public void runApplication() {
        if (shouldRunApplication) {
            shouldRunApplication = false;
            super.runApplication();
        }
    }

    @Override
    public void setAppProperties(@Nullable Bundle appProperties) {
        shouldRunApplication = true;
        super.setAppProperties(appProperties);
    }

    @Override
    public void unmountReactApplication() {
        super.unmountReactApplication();
        removeOnGlobalLayoutListener();
    }

    private ViewTreeObserver.OnGlobalLayoutListener mGlobalLayoutListener;

    private ViewTreeObserver.OnGlobalLayoutListener getGlobalLayoutListener() {
        if (mGlobalLayoutListener == null) {
            try {
                Method method = ReactRootView.class.getDeclaredMethod("getCustomGlobalLayoutListener");
                method.setAccessible(true);
                mGlobalLayoutListener = (ViewTreeObserver.OnGlobalLayoutListener) method.invoke(this);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return mGlobalLayoutListener;
    }

    void addOnGlobalLayoutListener() {
        removeOnGlobalLayoutListener();
        getViewTreeObserver().addOnGlobalLayoutListener(getGlobalLayoutListener());
    }

    void removeOnGlobalLayoutListener() {
        getViewTreeObserver().removeOnGlobalLayoutListener(getGlobalLayoutListener());
    }
}
