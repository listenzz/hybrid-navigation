package com.reactnative.hybridnavigation;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.UIManager;
import com.facebook.react.interfaces.fabric.ReactSurface;
import com.facebook.react.runtime.ReactSurfaceView;
import com.facebook.react.uimanager.TouchTargetHelper;
import com.facebook.react.uimanager.UIManagerHelper;
import com.facebook.react.uimanager.common.UIManagerType;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class HBDRootView extends FrameLayout {

    @Nullable
    private ReactSurface surface;

    @Nullable
    private ReactSurfaceView reactSurfaceView;

    private boolean passThroughTouches;

    @Nullable
    private Bundle appProperties;

    public HBDRootView(@NonNull Context context) {
        super(context);
    }

    public HBDRootView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public HBDRootView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setPassThroughTouches(boolean passThroughTouches) {
        this.passThroughTouches = passThroughTouches;
    }

    public void setSurface(@NonNull ReactSurface reactSurface) {
        if (surface == reactSurface) {
            return;
        }

        clearSurface();
        surface = reactSurface;

        View view = reactSurface.getView();
        if (view == null) {
            throw new IllegalStateException("[Navigation] ReactSurface.getView() 不能为空。");
        }

        addView(view, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        reactSurfaceView = findReactSurfaceView(this);

        if (appProperties != null) {
            applyAppProperties(appProperties);
        }

        reactSurface.start();
    }

    public void clearSurface() {
        clearSurface(true);
    }

    public void clearSurface(boolean stopSurface) {
        if (surface != null && stopSurface) {
            surface.stop();
        }
        surface = null;
        reactSurfaceView = null;
        removeAllViews();
    }

    public void setAppProperties(@Nullable Bundle appProperties) {
        this.appProperties = appProperties == null ? null : new Bundle(appProperties);
        applyAppProperties(this.appProperties);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (shouldPassTouches(ev)) {
            return false;
        }
        return super.dispatchTouchEvent(ev);
    }

	@SuppressLint("ClickableViewAccessibility")
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		ReactSurfaceView surfaceView = getReactSurfaceView();
		if (surfaceView != null) {
			surfaceView.onChildStartedNativeGesture(surfaceView, event);
		}
		return true;
	}

	private boolean shouldPassTouches(@NonNull MotionEvent ev) {
        if (!passThroughTouches) {
            return false;
        }

        int action = ev.getAction() & MotionEvent.ACTION_MASK;
        if (action != MotionEvent.ACTION_DOWN) {
            return false;
        }

        ReactSurfaceView surfaceView = getReactSurfaceView();
        if (surfaceView == null) {
            return false;
        }

        ViewGroup rootViewGroup = surfaceView.getRootViewGroup();

        int tag = TouchTargetHelper.findTargetTagForTouch(ev.getX(), ev.getY(), rootViewGroup);
        UIManager uiManager = UIManagerHelper.getUIManager(surfaceView.getCurrentReactContext(), UIManagerType.FABRIC);
        if (uiManager == null) {
            return false;
        }

        View view = uiManager.resolveView(tag);
        if (view == null) {
            return false;
        }

        if (view == surfaceView || view == surfaceView.getChildAt(0)) {
            if (view.getWidth() == surfaceView.getWidth() && view.getHeight() == surfaceView.getHeight()) {
                surfaceView.onChildStartedNativeGesture(surfaceView, ev);
                return true;
            }
        }

        return false;
    }

    @Nullable
    private ReactSurfaceView getReactSurfaceView() {
        if (reactSurfaceView == null) {
            reactSurfaceView = findReactSurfaceView(this);
        }
        return reactSurfaceView;
    }

    @Nullable
    private ReactSurfaceView findReactSurfaceView(@NonNull ViewGroup parent) {
        for (int i = 0; i < parent.getChildCount(); i++) {
            View child = parent.getChildAt(i);
            if (child instanceof ReactSurfaceView surfaceView) {
                return surfaceView;
            }

            if (child instanceof ViewGroup childGroup) {
                ReactSurfaceView result = findReactSurfaceView(childGroup);
                if (result != null) {
                    return result;
                }
            }
        }

        return null;
    }

    private void applyAppProperties(@Nullable Bundle appProperties) {
        if (appProperties == null || surface == null) {
            return;
        }

        try {
            Method updateInitProps = surface.getClass().getMethod("updateInitProps", Bundle.class);
            updateInitProps.invoke(surface, new Bundle(appProperties));
        } catch (NoSuchMethodException ignored) {
        } catch (IllegalAccessException | InvocationTargetException ignored) {
        }
    }
}
