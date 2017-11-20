package com.navigationhybrid.playground;

import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.ReactContext;
import com.navigationhybrid.ReactBridgeManager;

/**
 * Created by Listen on 2017/11/19.
 */

public class ReactFragment extends Fragment {

    protected static final String TAG = "ReactNative";

    ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
    ReactInstanceManager reactInstanceManager = bridgeManager.getReactInstanceManager();
    ReactRootView reactRootView;
    FrameLayout containerLayout;
    Handler handler = new Handler();

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, getClass().getSimpleName() + "#onCreate");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, getClass().getSimpleName() + "#onDestroy");
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Log.d(TAG, getClass().getSimpleName() + "#onCreateView");
        View view = inflater.inflate(R.layout.fragment_react, container, false);
        containerLayout = view.findViewById(R.id.react_content);
        return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Log.d(TAG, getClass().getSimpleName() + "#onViewCreated");
        initReactNative();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (reactRootView != null) {
            reactRootView.unmountReactApplication();
            reactRootView = null;
        }
        Log.d(TAG, getClass().getSimpleName() + "#onDestroyView");
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG, getClass().getSimpleName() + "#onResume");
    }

    @Override
    public void onPause() {
        super.onPause();
        Log.d(TAG, getClass().getSimpleName() + "#onPause");
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Log.d(TAG, getClass().getSimpleName() + "#onRequestPermissionsResult");
    }

    protected boolean isBridgeInitialized() {
        return bridgeManager.isInitialized();
    }

    private void initReactNative() {
        if (reactRootView != null || getView() == null) {
            return;
        }

        if (!isBridgeInitialized()) {
            Log.w(TAG, getClass().getSimpleName() +" bridge not initialized");
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

        Log.w(TAG, getClass().getSimpleName() + " bridge initialized now");

        if (reactRootView == null && getView() != null) {
            reactRootView = new ReactRootView(getContext());
            reactRootView.setEventListener(new ReactRootView.ReactRootViewEventListener() {
                @Override
                public void onAttachedToReactInstance(ReactRootView rootView) {
                    Log.w(TAG, ReactFragment.this.getClass().getSimpleName() + "#onAttachedToReactInstance");
                }
            });
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            containerLayout.addView(reactRootView, layoutParams);
            reactRootView.startReactApplication(reactInstanceManager, "Navigator");
        }
    }
}
