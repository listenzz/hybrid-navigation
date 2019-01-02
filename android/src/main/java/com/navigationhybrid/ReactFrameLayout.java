package com.navigationhybrid;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.facebook.react.ReactRootView;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class ReactFrameLayout extends FrameLayout implements ReactRootViewHolder {
    protected static final String TAG = "ReactNative";

    private ReactRootView mReactRootView;
    private VisibilityObserver mVisibilityObserver;

    public ReactFrameLayout(Context context) {
        this(context, null);
    }

    public ReactFrameLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ReactFrameLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, 0);
    }

    @TargetApi(21)
    public ReactFrameLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    protected void onAnimationEnd() {
        super.onAnimationEnd();
        post(new Runnable() {
            @Override
            public void run() {
                if (getVisibility() == View.GONE && mReactRootView != null) {
                    removeView(mReactRootView);
                }
            }
        });
    }

    @Override
    public void addView(View child, ViewGroup.LayoutParams params) {
        super.addView(child, params);
        if (child instanceof ReactRootView) {
            mReactRootView = (ReactRootView) child;
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (getVisibility() == View.VISIBLE && mReactRootView != null && mReactRootView.getParent() == null) {
            ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT);
            addView(mReactRootView, 0, layoutParams);
        }

        if (mVisibilityObserver != null) {
            mVisibilityObserver.inspectVisibility(visibility);
        }
    }

    @Override
    public void setVisibilityObserver(VisibilityObserver observer) {
        mVisibilityObserver = observer;
    }
}
