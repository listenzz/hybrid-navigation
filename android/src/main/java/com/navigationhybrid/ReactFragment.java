package com.navigationhybrid;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;

import me.listenzz.navigation.PresentAnimation;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static com.navigationhybrid.HBDEventEmitter.EVENT_NAVIGATION;
import static com.navigationhybrid.HBDEventEmitter.KEY_ON;
import static com.navigationhybrid.HBDEventEmitter.KEY_REQUEST_CODE;
import static com.navigationhybrid.HBDEventEmitter.KEY_RESULT_CODE;
import static com.navigationhybrid.HBDEventEmitter.KEY_RESULT_DATA;
import static com.navigationhybrid.HBDEventEmitter.KEY_SCENE_ID;
import static com.navigationhybrid.HBDEventEmitter.ON_COMPONENT_APPEAR;
import static com.navigationhybrid.HBDEventEmitter.ON_COMPONENT_DISAPPEAR;
import static com.navigationhybrid.HBDEventEmitter.ON_COMPONENT_RESULT;
import static com.navigationhybrid.HBDEventEmitter.ON_DIALOG_BACK_PRESSED;

/**
 * Created by Listen on 2018/1/15.
 */
public class ReactFragment extends HybridFragment implements ReactRootViewHolder.VisibilityObserver {

    protected static final String TAG = "ReactNative";
    private ViewGroup containerLayout;
    private ReactRootViewHolder reactRootViewHolder;
    private ReactView reactRootView;
    private ReactView reactTitleView;
    private BroadcastReceiver jsBundleReloadBroadcastReceiver;
    private boolean firstRenderCompleted;


    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        int color = preferredToolbarColor();
        boolean extendedLayoutIncludesToolbar = Color.alpha(color) < 255 || getGarden().extendedLayoutIncludesTopBar;
        View view;
        if (extendedLayoutIncludesToolbar) {
            view = inflater.inflate(R.layout.nav_fragment_react_translucent, container, false);
        } else {
            view = inflater.inflate(R.layout.nav_fragment_react, container, false);
        }

        containerLayout = view.findViewById(R.id.react_content);
        if (containerLayout instanceof ReactRootViewHolder) {
            reactRootViewHolder = (ReactRootViewHolder) containerLayout;
            reactRootViewHolder.setVisibilityObserver(this);
        }

        if (!isFragmentHidden() || getShowsDialog()) {
            if (getAnimation() != PresentAnimation.None) {
                postponeEnterTransition();
            }
            initReactNative();
        }

        return view;
    }

    @Override
    public void inspectVisibility(int visibility) {
        if (visibility == View.VISIBLE && isResumed() && reactRootView == null) {
            initReactNative();
            initTitleViewIfNeeded();
        }
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        if (isViewAppear() && reactRootView == null) {
            initReactNative();
            initTitleViewIfNeeded();
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (!isFragmentHidden()) {
            initTitleViewIfNeeded();
        }
    }

    @Override
    public void onDestroy() {
        if (reactRootViewHolder != null) {
            reactRootViewHolder.setVisibilityObserver(null);
        }

        if (jsBundleReloadBroadcastReceiver != null) {
            LocalBroadcastManager.getInstance(requireContext().getApplicationContext()).unregisterReceiver(jsBundleReloadBroadcastReceiver);
            jsBundleReloadBroadcastReceiver = null;
        }

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
        if (reactRootView != null && firstRenderCompleted) {
            reactRootView.addOnGlobalLayoutListener();
            sendViewAppearEvent(true);
        }
    }

    @Override
    protected void onViewDisappear() {
        super.onViewDisappear();
        if (reactRootView != null && firstRenderCompleted) {
            sendViewAppearEvent(false);
            reactRootView.removeOnGlobalLayoutListener();
        }
    }

    public void signalFirstRenderComplete() {
        Log.i(TAG, getModuleName() + " signalFirstRenderComplete");
        if (firstRenderCompleted) {
            return;
        }

        firstRenderCompleted = true;
        startPostponedEnterTransition();

        if (reactRootView != null && isViewAppear()) {
            sendViewAppearEvent(true);
            reactRootView.addOnGlobalLayoutListener();
        }
    }

    public boolean isFirstRenderCompleted() {
        return firstRenderCompleted;
    }

    private void sendViewAppearEvent(boolean appear) {
        // 当从前台进入后台时，不会触发 disappear, 这和 iOS 保持一致
        if (isReactModuleRegisterCompleted() && (isResumed() || isRemoving())) {
            Bundle bundle = new Bundle();
            bundle.putString(KEY_SCENE_ID, getSceneId());
            bundle.putString(KEY_ON, appear ? ON_COMPONENT_APPEAR : ON_COMPONENT_DISAPPEAR);
            HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(bundle));
        }
    }

    @Override
    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        super.onFragmentResult(requestCode, resultCode, data);
        Bundle result = new Bundle();
        result.putInt(KEY_REQUEST_CODE, requestCode);
        result.putInt(KEY_RESULT_CODE, resultCode);
        result.putBundle(KEY_RESULT_DATA, data);
        result.putString(KEY_SCENE_ID, getSceneId());
        result.putString(KEY_ON, ON_COMPONENT_RESULT);
        HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(result));
    }

    @Override
    public void setAppProperties(@NonNull Bundle props) {
        super.setAppProperties(props);
        if (reactRootView != null && isReactModuleRegisterCompleted()) {
            this.reactRootView.setAppProperties(getProps());
        }
    }

    private void initReactNative() {
        Context context = getContext();

        if (context == null || reactRootView != null || !isReactModuleRegisterCompleted()) {
            return;
        }

        final ReactView reactView = new ReactView(context);
        boolean passThroughTouches = getOptions().getBoolean("passThroughTouches", false);
        reactView.setShouldConsumeTouchEvent(!passThroughTouches);
        reactRootView = reactView;

        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT);
        containerLayout.addView(reactView, layoutParams);
        String moduleName = getModuleName();

        reactView.startReactApplication(getReactBridgeManager().getReactInstanceManager(), moduleName, getProps());

        jsBundleReloadBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                LocalBroadcastManager.getInstance(context.getApplicationContext()).unregisterReceiver(this);
                jsBundleReloadBroadcastReceiver = null;

                if (reactRootView != null) {
                    reactRootView.unmountReactApplication();
                    reactRootView = null;
                }

                if (reactTitleView != null) {
                    reactTitleView.unmountReactApplication();
                    reactTitleView = null;
                }
            }
        };

        LocalBroadcastManager.getInstance(context.getApplicationContext())
                .registerReceiver(jsBundleReloadBroadcastReceiver, new IntentFilter(Constants.INTENT_RELOAD_JS_BUNDLE));
    }

    private void initTitleViewIfNeeded() {
        Context context = getContext();

        if (context == null || reactTitleView != null || !isReactModuleRegisterCompleted()) {
            return;
        }

        Bundle titleItem = getOptions().getBundle("titleItem");
        if (titleItem != null) {
            String moduleName = titleItem.getString("moduleName");
            if (moduleName != null) {
                String fitting = titleItem.getString("layoutFitting");
                boolean expanded = "expanded".equals(fitting);
                reactTitleView = new ReactView(context);
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
    public void postponeEnterTransition() {
        super.postponeEnterTransition();
        Log.d(TAG, getModuleName() + " postponeEnterTransition");
        if (getActivity() != null) {
            getActivity().supportPostponeEnterTransition();
        }
    }

    @Override
    public void startPostponedEnterTransition() {
        super.startPostponedEnterTransition();
        Log.d(TAG, getModuleName() + " startPostponeEnterTransition");
        if (getActivity() != null) {
            getActivity().supportStartPostponedEnterTransition();
        }
    }

    @Override
    protected void setupDialog() {
        super.setupDialog();
        getDialog().setOnKeyListener(
                (dialog, keyCode, event) -> {
                    if (event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
                        Bundle bundle = new Bundle();
                        bundle.putString(KEY_SCENE_ID, getSceneId());
                        bundle.putString(KEY_ON, ON_DIALOG_BACK_PRESSED);
                        HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(bundle));
                        return true;
                    }

                    ReactContext reactContext = getCurrentReactContext();
                    if (reactContext != null && isReactModuleRegisterCompleted()) {
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
                });
    }

}
