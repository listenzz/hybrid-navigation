package com.navigationhybrid.view;

import android.content.Context;
import android.support.design.widget.AppBarLayout;
import android.support.v4.graphics.ColorUtils;
import android.support.v7.widget.Toolbar;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.TextView;

import com.facebook.react.views.view.ColorUtil;
import com.navigationhybrid.R;

/**
 * Created by Listen on 2017/11/22.
 */

public class TopBar extends Toolbar {

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
        titleView = new TextView(context);
        Toolbar.LayoutParams layoutParams = new Toolbar.LayoutParams(-2, -2, Gravity.CENTER_VERTICAL | Gravity.LEFT);
        addView(titleView, layoutParams);
    }

    public TextView getTitleView() {
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
