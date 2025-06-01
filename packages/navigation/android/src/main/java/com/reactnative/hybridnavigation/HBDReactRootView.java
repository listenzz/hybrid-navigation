package com.reactnative.hybridnavigation;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.MotionEvent;

import androidx.annotation.Nullable;

import com.facebook.react.ReactRootView;

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

    @SuppressLint("ClickableViewAccessibility")
	@Override
    public boolean onTouchEvent(MotionEvent ev) {
        int action = ev.getAction() & MotionEvent.ACTION_MASK;
        if (action == MotionEvent.ACTION_DOWN) {
            onChildStartedNativeGesture(ev);
        }
        return shouldConsumeTouchEvent;
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

    private boolean hbd_isAttachedToReactInstance;

    @Override
    public void onAttachedToReactInstance() {
        super.onAttachedToReactInstance();
        hbd_isAttachedToReactInstance = true;
    }

    @Override
    public void setAppProperties(@Nullable Bundle appProperties) {
        if (hbd_isAttachedToReactInstance) {
            shouldRunApplication = true;
            super.setAppProperties(appProperties);
        }
    }
}
