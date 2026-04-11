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

import com.facebook.react.interfaces.fabric.ReactSurface;
import com.facebook.react.runtime.ReactSurfaceView;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

@SuppressLint("ClickableViewAccessibility")
public class HBDRootView extends FrameLayout {

	@Nullable
	private ReactSurface surface;

	@Nullable
	private ReactSurfaceView reactSurfaceView;

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

		// Prevent double-dispatch of ACTION_DOWN to JSTouchDispatcher.
		// ReactRootView dispatches touch events to JS in both onInterceptTouchEvent and onTouchEvent.
		// When no Fabric child view handles the DOWN (e.g. during initial render), onTouchEvent is
		// also called, causing JSTouchDispatcher to receive a duplicate DOWN before UP/CANCEL.
		// Returning true from the listener for ACTION_DOWN prevents onTouchEvent from firing,
		// while still allowing MOVE/UP/CANCEL to reach onTouchEvent normally.
		if (reactSurfaceView != null) {
			reactSurfaceView.setOnTouchListener((v, event) -> {
				int action = event.getAction() & MotionEvent.ACTION_MASK;
				return action == MotionEvent.ACTION_DOWN;
			});
		}

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
		if (reactSurfaceView != null) {
			reactSurfaceView.setOnTouchListener(null);
		}
		surface = null;
		reactSurfaceView = null;
		removeAllViews();
	}

	public void setAppProperties(@Nullable Bundle appProperties) {
		this.appProperties = appProperties == null ? null : new Bundle(appProperties);
		applyAppProperties(this.appProperties);
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
		} catch (NoSuchMethodException | IllegalAccessException |
				 InvocationTargetException ignored) {
		}
	}
}
