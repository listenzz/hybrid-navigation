package com.navigationhybrid;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.facebook.react.ReactRootView;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class ReactLinearLayout extends LinearLayout implements ReactRootViewHolder {

    protected static final String TAG = "ReactNative";

    private ReactRootView mReactRootView;
    private VisibilityObserver mVisibilityObserver;

    public ReactLinearLayout(Context context) {
        super(context);
    }

    public ReactLinearLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ReactLinearLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @TargetApi(21)
    public ReactLinearLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    protected void onAnimationEnd() {
        super.onAnimationEnd();
        if (mVisibilityObserver != null && mVisibilityObserver.isOptimizationEnabled()) {
            post(new Runnable() {
                @Override
                public void run() {
                    if (getVisibility() == View.GONE && mReactRootView != null) {
                        removeView(mReactRootView);
                    }
                }
            });
        }
    }

    @Override
    public void onViewAdded(View child) {
        super.onViewAdded(child);
        if (child instanceof ReactRootView) {
            mReactRootView = (ReactRootView) child;
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (visibility == View.VISIBLE && mReactRootView != null && mReactRootView.getParent() == null) {
            ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT);
            addView(mReactRootView, layoutParams);
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
