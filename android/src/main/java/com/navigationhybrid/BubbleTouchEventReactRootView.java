package com.navigationhybrid;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;

import com.facebook.react.ReactRootView;

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

    private boolean shouldConsumeTouchEvent = true;

    public void setShouldConsumeTouchEvent(boolean consume) {
        this.shouldConsumeTouchEvent = consume;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        super.onTouchEvent(ev);
        return shouldConsumeTouchEvent;
    }
}
