package com.navigationhybrid.view;

import android.content.Context;
import android.support.design.widget.AppBarLayout;
import android.support.v7.widget.Toolbar;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.TextView;

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
            height = (int)(px);
        }
        addView(toolbar, LayoutParams.MATCH_PARENT, height);
        titleView = new TextView(context);
        Toolbar.LayoutParams layoutParams = new Toolbar.LayoutParams(-2, -2, Gravity.CENTER_VERTICAL | Gravity.LEFT);
        toolbar.addView(titleView, layoutParams);
    }

    public Toolbar getToolbar() {
        return toolbar;
    }

    public TextView getCenterTitleView() {
        return titleView;
    }

    public void setTitleViewAlignment(String alignment) {
        Toolbar.LayoutParams layoutParams = (Toolbar.LayoutParams) titleView.getLayoutParams();
        if ("center".equals(alignment)) {
            layoutParams.gravity = Gravity.CENTER;
        } else {
            layoutParams.gravity = Gravity.CENTER_VERTICAL | Gravity.LEFT;

        }
        titleView.setLayoutParams(layoutParams);
    }

}
