package com.navigationhybrid;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewTreeObserver;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import javax.annotation.Nullable;

public class ReactView extends ReactRootView {

    protected static final String TAG = "ReactNative";

    public ReactView(Context context) {
        super(context);
    }

    public ReactView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ReactView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    private boolean shouldConsumeTouchEvent = true;

    public void setShouldConsumeTouchEvent(boolean consume) {
        this.shouldConsumeTouchEvent = consume;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        super.onTouchEvent(ev);
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
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
        return mGlobalLayoutListener;
    }

    void addOnGlobalLayoutListener() {
        getViewTreeObserver().addOnGlobalLayoutListener(getGlobalLayoutListener());
    }

    void removeOnGlobalLayoutListener() {
        getViewTreeObserver().removeOnGlobalLayoutListener(getGlobalLayoutListener());
    }

}
