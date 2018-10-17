package com.navigationhybrid;

import android.app.Activity;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;

import me.listenzz.navigation.AnimationType;
import me.listenzz.navigation.FragmentHelper;
import me.listenzz.navigation.PresentAnimation;

import static com.navigationhybrid.Constants.ARG_MODULE_NAME;
import static com.navigationhybrid.Constants.ARG_SCENE_ID;
import static com.navigationhybrid.Constants.ON_COMPONENT_APPEAR;
import static com.navigationhybrid.Constants.ON_COMPONENT_DISAPPEAR;
import static com.navigationhybrid.Constants.ON_COMPONENT_RESULT_EVENT;
import static com.navigationhybrid.Constants.REQUEST_CODE_KEY;
import static com.navigationhybrid.Constants.RESULT_CODE_KEY;
import static com.navigationhybrid.Constants.RESULT_DATA_KEY;

/**
 * Created by Listen on 2018/1/15.
 */

public class ReactFragment extends HybridFragment {

    protected static final String TAG = "ReactNative";

    private ReactRootView reactRootView;
    private ViewGroup containerLayout;
    private ReactRootView reactTitleView;
    private boolean appear;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        int color = preferredToolbarColor();
        boolean extendedLayoutIncludesToolbar = Color.alpha(color) < 255 || getGarden().extendedLayoutIncludesTopBar;
        View view;
        if (extendedLayoutIncludesToolbar) {
            view= inflater.inflate(R.layout.nav_fragment_react_translucent, container, false);
        } else {
            view= inflater.inflate(R.layout.nav_fragment_react, container, false);
        }
        containerLayout = view.findViewById(R.id.react_content);
        if (getReactBridgeManager().isReactModuleRegisterCompleted()) {
            if (getAnimation() != PresentAnimation.None) {
                postponeEnterTransition();
            }
            initReactNative();
        }

        return view;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initTitleViewIfNeeded();
    }

    @Override
    public void onDestroy() {
        if (reactRootView != null) {
            reactRootView.unmountReactApplication();
        }
        if (reactTitleView != null) {
            reactTitleView.unmountReactApplication();
        }
        super.onDestroy();
    }

    @Override
    protected void onViewAppear() {
        super.onViewAppear();
        sendViewAppearEvent(true);
    }

    @Override
    protected void onViewDisappear() {
        super.onViewDisappear();
        sendViewAppearEvent(false);
    }

    private void sendViewAppearEvent(boolean appear) {
        if ((isResumed() || isRemoving()) && getReactBridgeManager().isReactModuleRegisterCompleted() && this.appear != appear) {
            this.appear = appear;
            Bundle bundle = new Bundle();
            bundle.putString(Constants.ARG_SCENE_ID, getSceneId());
            getReactBridgeManager().sendEvent(appear ? ON_COMPONENT_APPEAR : ON_COMPONENT_DISAPPEAR, Arguments.fromBundle(bundle));
        }
    }

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        Bundle result = new Bundle();
        result.putInt(REQUEST_CODE_KEY, requestCode);
        result.putInt(RESULT_CODE_KEY, resultCode);
        result.putBundle(RESULT_DATA_KEY, data);
        result.putString(ARG_SCENE_ID, getSceneId());
        getReactBridgeManager().sendEvent(ON_COMPONENT_RESULT_EVENT, Arguments.fromBundle(result));
    }

    @Override
    public void setAppProperties(@NonNull Bundle props) {
        super.setAppProperties(props);
        if (reactRootView != null && getReactBridgeManager().isReactModuleRegisterCompleted()) {
            this.reactRootView.setAppProperties(getProps());
        }
    }

    private void initReactNative() {
        if (reactRootView != null || getContext() == null) {
            return;
        }

        BubbleTouchEventReactRootView reactRootView = new BubbleTouchEventReactRootView(getContext());
        boolean passThroughTouches = getOptions().getBoolean("passThroughTouches", false);
        reactRootView.setShouldConsumeTouchEvent(!passThroughTouches);
        this.reactRootView = reactRootView;

        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        containerLayout.addView(reactRootView, layoutParams);
        Bundle args = FragmentHelper.getArguments(this);
        String moduleName = args.getString(ARG_MODULE_NAME);
        reactRootView.startReactApplication(getReactBridgeManager().getReactInstanceManager(), moduleName, getProps());
    }

    private void initTitleViewIfNeeded() {
        if (!getReactBridgeManager().isReactModuleRegisterCompleted() || reactTitleView != null || getContext() == null) {
            return;
        }

        Bundle titleItem = getOptions().getBundle("titleItem");
        if (titleItem != null) {
            String moduleName = titleItem.getString("moduleName");
            if (moduleName != null) {
                String fitting = titleItem.getString("layoutFitting");
                boolean expanded = "expanded".equals(fitting);
                reactTitleView = new ReactRootView(getContext());
                Toolbar.LayoutParams layoutParams;
                if (expanded) {
                    layoutParams = new Toolbar.LayoutParams(-1, -1, Gravity.CENTER);
                } else {
                    layoutParams = new Toolbar.LayoutParams(-2, -2, Gravity.CENTER);
                }
                getAwesomeToolbar().addView(reactTitleView, layoutParams);
                reactTitleView.startReactApplication(getReactBridgeManager().getReactInstanceManager(), moduleName, getProps());
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG, "onResume");
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

    @Override
    protected void setupDialog() {
        super.setupDialog();
        getDialog().setOnKeyListener(
                new DialogInterface.OnKeyListener() {
                    @Override
                    public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                        if (event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
                            Bundle bundle = new Bundle();
                            bundle.putString("sceneId", getSceneId());
                            getReactBridgeManager().sendEvent("ON_DIALOG_BACK_PRESSED", Arguments.fromBundle(bundle));
                            return true;
                        }

                        ReactContext reactContext = getReactBridgeManager().getReactInstanceManager().getCurrentReactContext();
                        if (reactContext != null && getReactBridgeManager().isReactModuleRegisterCompleted()) {
                            Activity activity = reactContext.getCurrentActivity();
                            if (activity != null) {
                                if (KeyEvent.ACTION_UP == event.getAction()) {
                                    activity.onKeyUp(keyCode, event);
                                } else if (KeyEvent.ACTION_DOWN == event.getAction()) {
                                    activity.onKeyDown(keyCode, event);
                                }
                            }
                        }
                        return false;
                    }
                });
    }
}
