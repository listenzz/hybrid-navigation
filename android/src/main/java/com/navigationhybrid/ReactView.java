package com.navigationhybrid;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewTreeObserver;

import com.facebook.react.ReactRootView;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

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
        removeOnGlobalLayoutListener();
        super.onAttachedToWindow();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeOnGlobalLayoutListener();
    }

    @Override
    public void unmountReactApplication() {
        removeOnGlobalLayoutListener();
        super.unmountReactApplication();
    }

    void addOnGlobalLayoutListener() {
        try {
            Method method = ReactRootView.class.getDeclaredMethod("getCustomGlobalLayoutListener");
            method.setAccessible(true);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                getViewTreeObserver().removeOnGlobalLayoutListener((ViewTreeObserver.OnGlobalLayoutListener) method.invoke(this));
            } else {
                getViewTreeObserver().removeGlobalOnLayoutListener((ViewTreeObserver.OnGlobalLayoutListener) method.invoke(this));
            }
            getViewTreeObserver().addOnGlobalLayoutListener((ViewTreeObserver.OnGlobalLayoutListener) method.invoke(this));
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }

    void removeOnGlobalLayoutListener() {
        try {
            Method method = ReactRootView.class.getDeclaredMethod("getCustomGlobalLayoutListener");
            method.setAccessible(true);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                getViewTreeObserver().removeOnGlobalLayoutListener((ViewTreeObserver.OnGlobalLayoutListener) method.invoke(this));
            } else {
                getViewTreeObserver().removeGlobalOnLayoutListener((ViewTreeObserver.OnGlobalLayoutListener) method.invoke(this));
            }
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }

}
