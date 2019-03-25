package com.navigationhybrid;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

public class ReactFrameLayout extends FrameLayout implements ReactRootViewHolder {
    protected static final String TAG = "ReactNative";

    private ReactView mReactRootView;
    private VisibilityObserver mVisibilityObserver;

    public ReactFrameLayout(Context context) {
        super(context);
    }

    public ReactFrameLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ReactFrameLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @TargetApi(21)
    public ReactFrameLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    public void onViewAdded(View child) {
        super.onViewAdded(child);
        if (child instanceof ReactView) {
            mReactRootView = (ReactView) child;
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mReactRootView != null) {
            removeView(mReactRootView);
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (mVisibilityObserver != null) {
            mVisibilityObserver.inspectVisibility(visibility);
        }
    }

    @Override
    public void setVisibilityObserver(VisibilityObserver observer) {
        mVisibilityObserver = observer;
    }
}
