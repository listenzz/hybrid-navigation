package com.navigationhybrid;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.FrameLayout;

import com.facebook.react.ReactRootView;

/**
 * Root ViewGroup for {@link ReactNavigationFragment} that allows it to get KeyEvents.
 */
public class ReactNavigationFragmentViewGroup extends FrameLayout {

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

    void unmountReactApplicationAfterAnimation(ReactRootView reactRootView) {
        this.reactRootView = reactRootView;
    }

    @Override
    protected void onAnimationEnd() {
        super.onAnimationEnd();
        if (reactRootView != null) {
            reactRootView.unmountReactApplication();
            reactRootView = null;
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        Log.w("ReactNative", "onDetachedFromWindow");
        if (reactRootView != null) {
            reactRootView.unmountReactApplication();
            reactRootView = null;
        }
    }
}
