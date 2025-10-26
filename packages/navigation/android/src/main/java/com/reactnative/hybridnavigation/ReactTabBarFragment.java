package com.reactnative.hybridnavigation;

import static com.reactnative.hybridnavigation.Constants.ARG_OPTIONS;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.FragmentHelper;
import com.navigation.androidx.Style;
import com.navigation.androidx.TabBarFragment;
import com.navigation.androidx.TabBarProvider;
import com.navigation.androidx.TransitionAnimation;

import java.util.List;

public class ReactTabBarFragment extends TabBarFragment {

	private static final String SAVED_OPTIONS = "hybrid_options";

	private final ReactManager reactManager = ReactManager.get();

	@Override
	public void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (savedInstanceState != null) {
			options = savedInstanceState.getBundle(SAVED_OPTIONS);
		}
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		reactManager.watchMemory(this);
	}

	@Override
	public void onSaveInstanceState(@NonNull Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putBundle(SAVED_OPTIONS, options);
	}

	private final static TransitionAnimation FadeShort = new TransitionAnimation(R.anim.nav_fade_in_short, R.anim.nav_fade_out_short, R.anim.nav_fade_in_short, R.anim.nav_fade_out_short);
	private final static TransitionAnimation DelayShort = new TransitionAnimation(R.anim.nav_delay_short, R.anim.nav_delay_short, R.anim.nav_delay_short, R.anim.nav_delay_short);

	@Override
	protected void setPresentAnimation(AwesomeFragment current, AwesomeFragment previous) {
		if (shouldImproveTransitionForReact(current)) {
			improveTransitionForReact(current, previous);
		} else {
			super.setPresentAnimation(current, previous);
		}
	}

	private boolean shouldImproveTransitionForReact(AwesomeFragment current) {
		ReactFragment reactFragment = Utils.findReactFragment(current);
		return reactFragment != null && !reactFragment.isFirstRenderCompleted();
	}

	private void improveTransitionForReact(AwesomeFragment current, AwesomeFragment previous) {
		List<AwesomeFragment> children = getChildAwesomeFragments();
		if (children.indexOf(current) > children.indexOf(previous)) {
			current.setAnimation(FadeShort);
			previous.setAnimation(DelayShort);
		} else {
			current.setAnimation(TransitionAnimation.None);
			previous.setAnimation(FadeShort);
		}
	}

	@Override
	protected void onCustomStyle(@NonNull Style style) {
		super.onCustomStyle(style);
		Bundle options = getOptions();
		String tabBarColor = options.getString("tabBarColor");
		if (tabBarColor != null) {
			style.setTabBarBackgroundColor(tabBarColor);
		}

		String tabBarItemColor = options.getString("tabBarItemColor");
		String tabBarUnselectedItemColor = options.getString("tabBarUnselectedItemColor");

		if (tabBarItemColor != null) {
			style.setTabBarItemColor(tabBarItemColor);
			style.setTabBarUnselectedItemColor(tabBarUnselectedItemColor);
		} else {
			options.putString("tabBarItemColor", style.getTabBarItemColor());
			options.putString("tabBarUnselectedItemColor", style.getTabBarUnselectedItemColor());
			options.putString("tabBarBadgeColor", style.getTabBarBadgeColor());
		}

		Bundle shadowImage = options.getBundle("tabBarShadowImage");
		if (shadowImage != null) {
			style.setTabBarShadow(Utils.createTabBarShadow(requireContext(), shadowImage));
		}
	}

	@Override
	protected TabBarProvider createDefaultTabBarProvider() {
		return new ReactTabBarProvider();
	}

	private Bundle options;

	@NonNull
	public Bundle getOptions() {
		if (options == null) {
			Bundle args = FragmentHelper.getArguments(this);
			options = args.getBundle(ARG_OPTIONS);
			if (options == null) {
				options = new Bundle();
			}
		}
		return options;
	}

	public void setOptions(@NonNull Bundle options) {
		this.options = options;
	}

	public void setIntercepted(boolean intercepted) {
		this.intercepted = intercepted;
	}

	private boolean intercepted = true;

	@Override
	public void setSelectedIndex(int index, @NonNull Runnable completion) {
		if (shouldIntercept()) {
			sendSwitchTabEvent(index);
			// restore tab bar selected index
			setTabBarSelectedIndex(getSelectedIndex());
		} else {
			super.setSelectedIndex(index, completion);
			intercepted = true;
		}
	}

	private boolean shouldIntercept() {
		return isAdded() && reactManager.hasRootLayout() && this.intercepted;
	}

	private void sendSwitchTabEvent(int index) {
		Bundle data = new Bundle();
		data.putString("sceneId", getSceneId());
		data.putInt("from", getSelectedIndex());
		data.putInt("to", index);
		NativeEvent.getInstance().emitOnSwitchTab(Arguments.fromBundle(data));
	}

	public Style getStyle() {
		return mStyle;
	}

}
