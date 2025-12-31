package com.reactnative.hybridnavigation;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.Nullable;

import com.facebook.common.logging.FLog;

public class ReactTabBar extends FrameLayout {

    protected static final String TAG = "Navigation";

    private Drawable shadow = new ColorDrawable(Color.parseColor("#EEEEEE"));
    private final Drawable background = new ColorDrawable(Color.WHITE);

    private FrameLayout mReactHolderView;
    private View mDivider;
    private boolean mSizeIndeterminate;
    private FrameLayout mBackgroundView;

    private ViewGroup mReactRootView;

    public ReactTabBar(Context context) {
        super(context);
        init();
    }

    public ReactTabBar(Context context, boolean sizeIndeterminate) {
        super(context);
        mSizeIndeterminate = sizeIndeterminate;
        init();
    }

    public ReactTabBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
        init();
    }

    public ReactTabBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public ReactTabBar(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        setLayoutParams(new ViewGroup.LayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)));
        LayoutInflater inflater = LayoutInflater.from(getContext());
        int layout = mSizeIndeterminate ? R.layout.nav_tab_bar_react_indeterminate : R.layout.nav_tab_bar_react;
        View parentView = inflater.inflate(layout, this, true);
        mBackgroundView = parentView.findViewById(R.id.bottom_navigation_bar_background);
        mReactHolderView = parentView.findViewById(R.id.bottom_navigation_bar_react_holder);
        mDivider = parentView.findViewById(R.id.bottom_navigation_bar_divider);
        mDivider.setBackground(shadow);
    }

    public void setShadow(@Nullable Drawable drawable) {
        shadow = drawable;
        if (mDivider != null) {
            mDivider.setBackground(drawable);
        }
    }

    @Override
    public void setPadding(int left, int top, int right, int bottom) {
        mBackgroundView.setPadding(left, top, right, bottom);
        if (mSizeIndeterminate) {
            mReactHolderView.setPadding(left, top, right, bottom);
        }
    }

    public void setRootView(View rootView) {
        mReactHolderView.addView(rootView);
        mReactRootView = (ViewGroup) rootView;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mReactHolderView.removeAllViews();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        ViewGroup.LayoutParams params = mReactRootView.getLayoutParams();
        if (params.height > 0) {
            return;
        }

        int height = getReactIntrinsicHeight();
        FLog.i(TAG, "[ReactTabBar] intrinsic height:" + height);
        if (height > 0) {
            params.height = height;
            post(mReactRootView::requestLayout);
        }
    }

    private int getReactIntrinsicHeight() {
        int rootViewHeight = mReactRootView.getMeasuredHeight();
        if (mReactRootView.getChildCount() > 1 || mReactHolderView.getLayoutParams().height > 0) {
            return rootViewHeight;
        }

        ViewGroup group = mReactRootView;
        while (group.getMeasuredHeight() == rootViewHeight) {
            if (group.getChildCount() == 0) {
                return 0;
            }
            group = (ViewGroup) group.getChildAt(0);
            if (group.getMeasuredHeight() < rootViewHeight) {
                return group.getMeasuredHeight();
            }
        }
        return rootViewHeight;
    }

}
