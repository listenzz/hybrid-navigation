package com.navigationhybrid;

import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.ReactContext;

/**
 * Created by Listen on 2017/11/20.
 */

public class ReactNavigationFragment extends NavigationFragment {

    protected static final String TAG = "ReactNative";

    ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
    ReactInstanceManager reactInstanceManager = bridgeManager.getReactInstanceManager();
    ReactRootView reactRootView;
    ReactNavigationFragmentViewGroup containerLayout;
    Handler handler = new Handler();

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Log.d(TAG, toString() + "#onCreateView");
        View view = inflater.inflate(R.layout.fragment_react, container, false);
        containerLayout = view.findViewById(R.id.react_content);
        return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initReactNative();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        Log.d(TAG, toString() + "#onCreateAnimation transit=" + transit + " enter="+ enter + " anim=" + navigator.anim.name());

        if (!enter) {
            if (transit == FragmentTransaction.TRANSIT_NONE) {
                reactRootView.unmountReactApplication();
            } else {
                containerLayout.unmountReactApplicationAfterAnimation(reactRootView);
            }
            reactRootView = null;
        }

        if (transit == FragmentTransaction.TRANSIT_NONE) {
            return AnimationUtils.loadAnimation(getContext(), R.anim.no_anim);
        }

        if (transit == FragmentTransaction.TRANSIT_FRAGMENT_OPEN) {
            if (enter) {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.enter);
            } else {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.exit);
            }
        } else if (transit == FragmentTransaction.TRANSIT_FRAGMENT_CLOSE) {
            if (enter) {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.popEnter);
            } else {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.popExit);
            }
        }
        return super.onCreateAnimation(transit, enter, nextAnim);
    }


    protected boolean isBridgeInitialized() {
        return bridgeManager.isInitialized();
    }

    private void initReactNative() {
        if (reactRootView != null || getView() == null) {
            return;
        }

        if (!isBridgeInitialized()) {
            Log.w(TAG, toString() +" waiting for bridge initialize");
            reactInstanceManager.addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
                @Override
                public void onReactContextInitialized(ReactContext context) {
                    reactInstanceManager.removeReactInstanceEventListener(this);
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            initReactNative();
                        }
                    });
                }
            });
            return;
        }

        Log.w(TAG, toString() + " bridge initialized now");

        if (reactRootView == null && getView() != null) {
            reactRootView = new ReactRootView(getContext());
            reactRootView.setEventListener(new ReactRootView.ReactRootViewEventListener() {
                @Override
                public void onAttachedToReactInstance(ReactRootView rootView) {
                    Log.w(TAG, ReactNavigationFragment.this.toString() + "#onAttachedToReactInstance");
                }
            });
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            containerLayout.addView(reactRootView, layoutParams);
            String moduleName = getArguments().getString(NAVIGATION_MODULE_NAME);
            Bundle initialProps = getArguments().getBundle(NAVIGATION_PROPS);
            reactRootView.startReactApplication(reactInstanceManager, moduleName, initialProps);
        }
    }
}
