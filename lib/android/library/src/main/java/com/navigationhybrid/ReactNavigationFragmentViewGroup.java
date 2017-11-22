package com.navigationhybrid;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.LinearLayout;

import com.facebook.react.ReactRootView;

/**
 * Root ViewGroup for {@link ReactNavigationFragment} that allows it to get KeyEvents.
 */
public class ReactNavigationFragmentViewGroup extends LinearLayout {

    @Nullable
    private ReactRootView reactRootView;

    public ReactNavigationFragmentViewGroup(Context context) {
        super(context);
    }

    public ReactNavigationFragmentViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ReactNavigationFragmentViewGroup(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setReactRootView(ReactRootView reactRootView) {
        this.reactRootView = reactRootView;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (reactRootView != null) {
            String sceneId = reactRootView.getAppProperties().getString("sceneId");
            Log.w("ReactNative", "onDetachedFromWindow:" + sceneId);
            reactRootView.unmountReactApplication();
            reactRootView = null;
        }
    }
}
