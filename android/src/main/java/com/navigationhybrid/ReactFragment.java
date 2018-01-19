package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.Arguments;
import com.navigationhybrid.androidnavigation.FragmentHelper;
import com.navigationhybrid.androidnavigation.PresentAnimation;

import static com.navigationhybrid.Constants.ARG_MODULE_NAME;
import static com.navigationhybrid.Constants.ARG_PROPS;
import static com.navigationhybrid.Constants.ON_COMPONENT_RESULT_EVENT;
import static com.navigationhybrid.Constants.REQUEST_CODE_KEY;
import static com.navigationhybrid.Constants.RESULT_CODE_KEY;
import static com.navigationhybrid.Constants.RESULT_DATA_KEY;

/**
 * Created by Listen on 2018/1/15.
 */

public class ReactFragment extends NativeFragment {

    protected static final String TAG = "ReactNative";

    ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
    ReactRootView reactRootView;
    LinearLayout containerLayout;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        // FIXME 动画判断精确
        if (getAnimation() != PresentAnimation.Delay || getAnimation() != PresentAnimation.None) {
            postponeEnterTransition();
        }

        View view = inflater.inflate(R.layout.fragment_react, container, false);
        containerLayout = view.findViewById(R.id.react_content);
        initReactNative();
        return view;
    }

    @Override
    public void onDestroy() {
        reactRootView.unmountReactApplication();
        super.onDestroy();
    }

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        Bundle result = new Bundle();
        result.putInt(REQUEST_CODE_KEY, requestCode);
        result.putInt(RESULT_CODE_KEY, resultCode);
        result.putBundle(RESULT_DATA_KEY, data);
        result.putString(ARGS_SCENE_ID, getSceneId());
        bridgeManager.sendEvent(ON_COMPONENT_RESULT_EVENT, Arguments.fromBundle(result));
    }

    private void initReactNative() {
        if (reactRootView != null) {
            return;
        }

        if (bridgeManager.isReactModuleInRegistry()) {
            bridgeManager.addReactModuleRegistryListener(new ReactBridgeManager.ReactModuleRegistryListener() {
                @Override
                public void onReactModuleRegistryCompleted() {
                    bridgeManager.removeReactModuleRegistryListener(this);
                    Log.w(TAG, ReactFragment.this.toString() + " onReactModuleRegistryCompleted");
                    initReactNative();
                }
            });
            return;
        }

        Log.d(TAG, toString() + " bridge is initialized");

        reactRootView = new ReactRootView(getContext());
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        containerLayout.addView(reactRootView, layoutParams);
        Bundle args = FragmentHelper.getArguments(this);
        String moduleName = args.getString(ARG_MODULE_NAME);
        Bundle initialProps = args.getBundle(ARG_PROPS);
        if (initialProps == null) {
            initialProps = new Bundle();
        }
        initialProps.putString(ARGS_SCENE_ID, getSceneId());

        reactRootView.startReactApplication(bridgeManager.getReactInstanceManager(), moduleName, initialProps);

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
