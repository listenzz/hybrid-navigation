package com.navigationhybrid.view;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Typeface;
import android.support.annotation.ColorInt;
import android.support.annotation.Nullable;
import android.support.design.widget.AppBarLayout;
import android.support.v7.widget.Toolbar;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.navigationhybrid.Garden;
import com.navigationhybrid.R;

/**
 * Created by Listen on 2017/11/22.
 */

public class TopBar extends AppBarLayout {

    private Toolbar toolbar;
    private TextView titleView;

    public TopBar(Context context) {
        super(context);
        init(context);

    }

    public TopBar(Context context, AttributeSet attrs) {
        super(context, attrs);

        init(context);
    }

    private void init(Context context) {
        toolbar = new Toolbar(context);

        TypedValue typedValue = new TypedValue();
        int height = 0;
        if (context.getTheme().resolveAttribute(R.attr.actionBarSize, typedValue, true)) {
            float px = TypedValue.complexToDimension(typedValue.data, context.getResources().getDisplayMetrics());
            float pixelDensity = Resources.getSystem().getDisplayMetrics().density;
            height = (int)(px);
        }

        addView(toolbar, LayoutParams.MATCH_PARENT, height);

        titleView = new TextView(context);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, Garden.Global.titleTextSize);
        titleView.setTextColor(Garden.Global.titleTextColor);


//        TypedArray typedArray = context.obtainStyledAttributes(new int[]{R.attr.titleTextAppearance});
//         int i = typedArray.getResourceId(0, 0);
//        typedArray.recycle();

        Toolbar.LayoutParams layoutParams = new Toolbar.LayoutParams(-2, -2, Gravity.CENTER);
        toolbar.addView(titleView, layoutParams);

    }


    public void setTitle(String title) {
        // toolbar.setTitle(title);
        titleView.setText(title);
    }

    public String getTitle() {
        return toolbar.getTitle() != null ? toolbar.getTitle().toString() : "";
    }

    public void setTitleTextColor(@ColorInt int color) {
        toolbar.setTitleTextColor(color);
    }

    public void setTitleFontSize(float size) {
        TextView titleTextView = getTitleTextView();
        if (titleTextView != null) {
            titleTextView.setTextSize(size);
        }
    }

    public void setTitleTypeface(Typeface typeface) {
        TextView titleTextView = getTitleTextView();
        if (titleTextView != null) {
            titleTextView.setTypeface(typeface);
        }
    }

    public TextView getTitleTextView() {
        return findTextView(toolbar);
    }

    @Override
    public void setBackgroundColor(@ColorInt int color) {
        toolbar.setBackgroundColor(color);
    }

    @Nullable
    private TextView findTextView(ViewGroup root) {
        for (int i = 0; i < root.getChildCount(); i++) {
            View view = root.getChildAt(i);
            if (view instanceof TextView) {
                return (TextView) view;
            }
            if (view instanceof ViewGroup) {
                return findTextView((ViewGroup) view);
            }
        }
        return null;
    }

    public Toolbar getToolbar() {
        return toolbar;
    }


}
