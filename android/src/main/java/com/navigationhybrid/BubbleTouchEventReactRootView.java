package com.navigationhybrid;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;

import javax.annotation.Nullable;

public class BubbleTouchEventReactRootView extends ReactRootView {
    public BubbleTouchEventReactRootView(Context context) {
        super(context);
    }

    public BubbleTouchEventReactRootView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public BubbleTouchEventReactRootView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    private String moduleName;

    private boolean shouldConsumeTouchEvent = true;

    public void setShouldConsumeTouchEvent(boolean consume) {
        this.shouldConsumeTouchEvent = consume;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        super.onTouchEvent(ev);
        Log.i("ReactNative", moduleName + " onTouchEvent " + descriptionFromAction(ev));
        return shouldConsumeTouchEvent;
    }

    @Override
    public void onChildStartedNativeGesture(MotionEvent androidEvent) {
        super.onChildStartedNativeGesture(androidEvent);
        Log.i("ReactNative", moduleName + " onChildStartedNativeGesture " + descriptionFromAction(androidEvent));
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        Log.i("ReactNative", moduleName + " onInterceptTouchEvent " + descriptionFromAction(ev));
        return super.onInterceptTouchEvent(ev);
    }

    @Override
    public void startReactApplication(ReactInstanceManager reactInstanceManager, String moduleName, @Nullable Bundle initialProperties) {
        this.moduleName = moduleName;
        super.startReactApplication(reactInstanceManager, moduleName, initialProperties);
        Log.i("ReactNative", moduleName + " startReactApplication ");
    }

    private String descriptionFromAction(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_CANCEL:
                return "ACTION_CANCEL";
            case MotionEvent.ACTION_DOWN:
                return "ACTION_DOWN";
            case MotionEvent.ACTION_UP:
                return "ACTION_UP";
            default:
                return "ACTION_" + event.getAction();
        }
    }
}
