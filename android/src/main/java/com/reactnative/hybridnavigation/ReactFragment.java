package com.reactnative.hybridnavigation;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;
import static com.reactnative.hybridnavigation.HBDEventEmitter.EVENT_NAVIGATION;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_ON;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_REQUEST_CODE;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_RESULT_CODE;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_RESULT_DATA;
import static com.reactnative.hybridnavigation.HBDEventEmitter.KEY_SCENE_ID;
import static com.reactnative.hybridnavigation.HBDEventEmitter.ON_COMPONENT_APPEAR;
import static com.reactnative.hybridnavigation.HBDEventEmitter.ON_COMPONENT_DISAPPEAR;
import static com.reactnative.hybridnavigation.HBDEventEmitter.ON_COMPONENT_RESULT;

import android.annotation.SuppressLint;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.facebook.common.logging.FLog;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.common.LifecycleState;
import com.navigation.androidx.Style;

public class ReactFragment extends HybridFragment implements ReactBridgeManager.ReactBridgeReloadListener {

    protected static final String TAG = "Navigation";

    private ViewGroup reactViewHolder;

    private HBDReactRootView reactRootView;
    private HBDReactRootView reactTitleView;
    private boolean firstRenderCompleted;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.nav_fragment_react, container, false);
        reactViewHolder = view.findViewById(R.id.react_content);
        if (isReactModuleRegisterCompleted()) {
            mountReactView();
        }
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // 这个时候 toolbar 才创建好
        initReactTitleView();
    }

    @Override
    protected boolean extendedLayoutIncludesToolbar() {
        int color = mStyle.getToolbarBackgroundColor();
        float alpha = mStyle.getToolbarAlpha();
        Garden garden = getGarden();
        return Color.alpha(color) < 255
            || alpha < 1.0
            || garden.toolbarHidden
            || garden.extendedLayoutIncludesTopBar;
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        super.onCustomStyle(style);
        if (shouldPassThroughTouches()) {
            style.setScrimAlpha(0);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (isViewReady()) {
            reactRootView.addOnGlobalLayoutListener();
            sendViewAppearEvent(true);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (isViewReady()) {
            sendViewAppearEvent(false);
            reactRootView.removeOnGlobalLayoutListener();
        }
    }

    private boolean isViewReady() {
        if (reactRootView == null) {
            return false;
        }
        return firstRenderCompleted;
    }

    private boolean reactViewAppeared = false;

    private void sendViewAppearEvent(boolean appear) {
        if (!isReactModuleRegisterCompleted()) {
            return;
        }

        // 当从前台进入后台时，不会触发 disappear, 这和 iOS 保持一致
        ReactContext reactContext = getCurrentReactContext();
        boolean isResumed = reactContext != null && reactContext.getLifecycleState() == LifecycleState.RESUMED;
        if (!isResumed) {
            return;
        }

        if (reactViewAppeared == appear) {
            return;
        }
        reactViewAppeared = appear;

        Bundle bundle = new Bundle();
        bundle.putString(KEY_SCENE_ID, getSceneId());
        bundle.putString(KEY_ON, appear ? ON_COMPONENT_APPEAR : ON_COMPONENT_DISAPPEAR);
        HBDEventEmitter.sendEvent(EVENT_NAVIGATION, Arguments.fromBundle(bundle));
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        unmountReactView();
    }

    @Override
    public void onStart() {
        super.onStart();
        if (forceScreenLandscape()) {
            requireActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        }
    }

    @SuppressLint("SourceLockedOrientationActivity")
    @Override
    public void onStop() {
        if (isRemoving() && forceScreenLandscape()) {
            requireActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
        super.onStop();
    }

    @Override
    public void onReload() {
        unmountReactView();
    }

    private void mountReactView() {
        initReactRootView();
        getReactBridgeManager().addReactBridgeReloadListener(this);
    }

    private void unmountReactView() {
        getReactBridgeManager().removeReactBridgeReloadListener(this);

        ReactContext reactContext = getCurrentReactContext();
        if (reactContext == null || !reactContext.hasActiveCatalystInstance()) {
            return;
        }

        if (reactRootView != null) {
            FLog.w(TAG, "销毁页面-：" + getModuleName());
            reactRootView.unmountReactApplication();
            ViewGroup parent = (ViewGroup) reactRootView.getParent();
            parent.removeView(reactRootView);
            reactRootView = null;
        }

        if (reactTitleView != null) {
            reactTitleView.unmountReactApplication();
            ViewGroup parent = (ViewGroup) reactTitleView.getParent();
            parent.removeView(reactTitleView);
            reactTitleView = null;
        }
    }

    @Override
    protected boolean onBackPressed() {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (getShowsDialog() && reactInstanceManager != null) {
            reactInstanceManager.onBackPressed();
            return true;
        }
        return super.onBackPressed();
    }

    public void signalFirstRenderComplete() {
        if (firstRenderCompleted) {
            return;
        }
        firstRenderCompleted = true;

        if (isViewReady() && isResumed()) {
            sendViewAppearEvent(true);
            reactRootView.addOnGlobalLayoutListener();
        }
    }

    public boolean isFirstRenderCompleted() {
        return firstRenderCompleted;
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
        if (reactRootView == null) {
            return;
        }

        if (isReactModuleRegisterCompleted()) {
            reactRootView.setAppProperties(getProps());
        }
    }

    private void initReactRootView() {
        reactRootView = createReactRootView();
        reactRootView.startReactApplication(getReactInstanceManager(), getModuleName(), getProps());
    }

    @NonNull
    private HBDReactRootView createReactRootView() {
        HBDReactRootView reactRootView = new HBDReactRootView(getContext());
        reactRootView.setShouldConsumeTouchEvent(!shouldPassThroughTouches());
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT);
        reactViewHolder.addView(reactRootView, layoutParams);
        return reactRootView;
    }

    private void initReactTitleView() {
        if (getToolbar() == null) {
            return;
        }

        Bundle titleItem = getOptions().getBundle("titleItem");
        if (titleItem == null) {
            return;
        }

        String moduleName = titleItem.getString("moduleName");
        if (moduleName == null) {
            return;
        }

        if (!isReactModuleRegisterCompleted()) {
            throw new IllegalStateException("[Navigation] React Component 还没有注册完毕。");
        }

        String fitting = titleItem.getString("layoutFitting");
        boolean expanded = "expanded".equals(fitting);
        reactTitleView = createReactTitleView(expanded);
        reactTitleView.startReactApplication(getReactInstanceManager(), moduleName, getProps());
    }

    private HBDReactRootView createReactTitleView(boolean expanded) {
        Toolbar.LayoutParams layoutParams = createTitleLayoutParams(expanded);
        HBDReactRootView reactTitleView = new HBDReactRootView(getContext());
        Toolbar toolbar = getToolbar();
        toolbar.addView(reactTitleView, layoutParams);
        return reactTitleView;
    }

    @NonNull
    private Toolbar.LayoutParams createTitleLayoutParams(boolean expanded) {
        if (expanded) {
            return new Toolbar.LayoutParams(MATCH_PARENT, MATCH_PARENT, Gravity.CENTER);
        }
        return new Toolbar.LayoutParams(WRAP_CONTENT, WRAP_CONTENT, Gravity.CENTER);
    }

    @Override
    public String getDebugTag() {
        return "[" + getModuleName() + "]";
    }
}
