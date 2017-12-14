package com.navigationhybrid;

import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.Arguments;

/**
 * Created by Listen on 2017/11/20.
 */

public class ReactNavigationFragment extends NavigationFragment {

    protected static final String TAG = "ReactNative";

    ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
    ReactRootView reactRootView;
    ReactNavigationFragmentViewGroup containerLayout;
    Handler handler = new Handler();

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Log.d(TAG, toString() + "#onCreateView");
        if (navigator.anim != PresentAnimation.None) {
            postponeEnterTransition();
        }
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
        reactRootView = null;
    }

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        Bundle result = new Bundle();
        result.putInt(Navigator.REQUEST_CODE_KEY, requestCode);
        result.putInt(Navigator.RESULT_CODE_KEY, resultCode);
        result.putBundle(Navigator.RESULT_DATA_KEY, data);
        result.putString(PROPS_NAV_ID, navigator.navId);
        result.putString(PROPS_SCENE_ID, navigator.sceneId);
        bridgeManager.sendEvent(Navigator.ON_COMPONENT_RESULT_EVENT, Arguments.fromBundle(result));
    }

    private void initReactNative() {
        if (reactRootView != null || getView() == null) {
            return;
        }

        if (bridgeManager.isReactModuleInRegistry()) {
            bridgeManager.addReactModuleRegistryListener(new ReactBridgeManager.ReactModuleRegistryListener() {
                @Override
                public void onStartRegisterReactModule() {

                }

                @Override
                public void onEndRegisterReactModule() {
                    bridgeManager.removeReactModuleRegistryListener(this);
                    Log.w(TAG, ReactNavigationFragment.this.toString() + " onEndRegisterReactModule");
                    initReactNative();
                }
            });
            return;
        }

        Log.d(TAG, toString() + " bridge is initialized");

        if (reactRootView == null && getView() != null) {
            reactRootView = new ReactRootView(getContext());
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            containerLayout.addView(reactRootView, layoutParams);
            containerLayout.setReactRootView(reactRootView);
            String moduleName = getArguments().getString(NAVIGATION_MODULE_NAME);
            Bundle initialProps = getArguments().getBundle(NAVIGATION_PROPS);
            reactRootView.startReactApplication(bridgeManager.getReactInstanceManager(), moduleName, initialProps);
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    startPostponedEnterTransition();
                }
            }, 2000);
        }
    }

    public void signalFirstRenderComplete() {
        Log.d(TAG, "signalFirstRenderComplete");
        startPostponedEnterTransition();
    }

    @Override
    public void postponeEnterTransition() {
        super.postponeEnterTransition();
        Log.d(TAG, "postponeEnterTransition");
        if (getActivity() != null) {
            getActivity().supportPostponeEnterTransition();
        }
    }

    @Override
    public void startPostponedEnterTransition() {
        super.startPostponedEnterTransition();
        Log.d(TAG, "startPostponeEnterTransition");
        if (getActivity() != null) {
            getActivity().supportStartPostponedEnterTransition();
        }
    }


}
