package com.navigationhybrid;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.facebook.react.ReactRootView;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class ReactLinearLayout extends LinearLayout {

    protected static final String TAG = "ReactNative";

    private ReactRootView mReactRootView;

    public ReactLinearLayout(Context context) {
        this(context, null);
    }

    public ReactLinearLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ReactLinearLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, 0);
    }

    @TargetApi(21)
    public ReactLinearLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
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
            addView(mReactRootView, layoutParams);
        }
    }

}
