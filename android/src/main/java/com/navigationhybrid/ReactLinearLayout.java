package com.navigationhybrid;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;

public class ReactLinearLayout extends LinearLayout implements ReactRootViewHolder {

    protected static final String TAG = "ReactNative";

    private VisibilityObserver mVisibilityObserver;
    private HBDReactRootView mReactRootView;

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
    public void onViewAdded(View child) {
        super.onViewAdded(child);
        if (child instanceof HBDReactRootView) {
            mReactRootView = (HBDReactRootView) child;
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
