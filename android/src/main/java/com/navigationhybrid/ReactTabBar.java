package com.navigationhybrid;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;


public class ReactTabBar extends FrameLayout {

    private Drawable shadow = new ColorDrawable(Color.parseColor("#EEEEEE"));

    private FrameLayout mReactHolder;
    private View mDivider;

    public ReactTabBar(Context context) {
        this(context, null);
    }

    public ReactTabBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ReactTabBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public ReactTabBar(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        setLayoutParams(new ViewGroup.LayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)));
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View parentView = inflater.inflate(R.layout.nav_tab_bar_react, this, true);
        mReactHolder = parentView.findViewById(R.id.bottom_navigation_bar_react_holder);
        mDivider = parentView.findViewById(R.id.bottom_navigation_bar_divider);
        mDivider.setBackground(shadow);
        setClipChildren(false);
    }

    public void setShadow(@Nullable Drawable drawable) {
        shadow = drawable;
        if (mDivider != null) {
            mDivider.setBackground(drawable);
        }
    }

    public void setRootView(View rootView) {
        mReactHolder.addView(rootView);
    }

}
