package com.reactnative.hybridnavigation;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.KeyEvent;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.facebook.common.logging.FLog;
import com.facebook.infer.annotation.Assertions;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.common.ReactConstants;
import com.facebook.react.devsupport.DoubleTapReloadRecognizer;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.PermissionListener;

public class ReactAppCompatActivityDelegate {

    private static final String TAG = "Navigation";

    private final int REQUEST_OVERLAY_PERMISSION_CODE = 1111;
    private static final String REDBOX_PERMISSION_GRANTED_MESSAGE =
        "Overlay permissions have been granted.";
    private static final String REDBOX_PERMISSION_MESSAGE =
        "Overlay permissions needs to be granted in order for react native apps to run in dev mode";

    private final AppCompatActivity mActivity;
    private final ReactBridgeManager mBridgeManager;

    private @Nullable
    DoubleTapReloadRecognizer mDoubleTapReloadRecognizer;
    private @Nullable
    PermissionListener mPermissionListener;
    private @Nullable
    Callback mPermissionsCallback;

    public ReactAppCompatActivityDelegate(@NonNull AppCompatActivity activity, ReactBridgeManager bridgeManager) {
        mActivity = activity;
        mBridgeManager = bridgeManager;
    }

    private void askPermission() {
        ReactBridgeManager bridgeManager = getReactBridgeManager();
        if (bridgeManager.getUseDeveloperSupport() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            FLog.i(TAG, "Check overlay permission");
            // Get permission to show redbox in dev builds.
            if (!Settings.canDrawOverlays(getContext())) {
                FLog.i(TAG, "Request overlay permission");
                Intent serviceIntent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getContext().getPackageName()));
                FLog.w(ReactConstants.TAG, REDBOX_PERMISSION_MESSAGE);
                Toast.makeText(getContext(), REDBOX_PERMISSION_MESSAGE, Toast.LENGTH_LONG).show();
                ((Activity) getContext()).startActivityForResult(serviceIntent, REQUEST_OVERLAY_PERMISSION_CODE);
            }
        }
    }

    protected ReactBridgeManager getReactBridgeManager() {
        return mBridgeManager;
    }

    public ReactInstanceManager getReactInstanceManager() {
        return mBridgeManager.getReactInstanceManager();
    }

    public ReactContext getCurrentReactContext() {
        return mBridgeManager.getCurrentReactContext();
    }

    protected void onCreate(Bundle savedInstanceState) {
        mDoubleTapReloadRecognizer = new DoubleTapReloadRecognizer();
        if (mBridgeManager.isReactModuleRegisterCompleted()) {
            askPermission();
        } else {
            mBridgeManager.addReactModuleRegisterListener(mReactModuleRegisterListener);
        }
    }

    ReactBridgeManager.ReactModuleRegisterListener mReactModuleRegisterListener = this::askPermission;

    protected void onPause() {
        ReactInstanceManager reactInstanceManager = mBridgeManager.getReactInstanceManager();
        ReactContext reactContext = mBridgeManager.getCurrentReactContext();
        if (reactContext != null && reactInstanceManager != null && UiThreadUtil.isOnUiThread()) {
            reactInstanceManager.onHostPause(getPlainActivity());
        }
    }

    protected void onResume() {
        ReactInstanceManager reactInstanceManager = mBridgeManager.getReactInstanceManager();
        ReactContext reactContext = mBridgeManager.getCurrentReactContext();
        if (reactContext != null && reactInstanceManager != null) {
            reactInstanceManager.onHostResume(
                getPlainActivity(),
                (DefaultHardwareBackBtnHandler) getPlainActivity());
        }

        if (mPermissionsCallback != null) {
            mPermissionsCallback.invoke();
            mPermissionsCallback = null;
        }
    }

    protected void onDestroy() {
        mBridgeManager.removeReactModuleRegisterListener(mReactModuleRegisterListener);
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null) {
            reactInstanceManager.onHostDestroy(getPlainActivity());
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null) {
            reactInstanceManager
                .onActivityResult(getPlainActivity(), requestCode, resultCode, data);
        } else {
            // Did we request overlay permissions?
            if (requestCode == REQUEST_OVERLAY_PERMISSION_CODE && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (Settings.canDrawOverlays(getContext())) {
                    Toast.makeText(getContext(), REDBOX_PERMISSION_GRANTED_MESSAGE, Toast.LENGTH_LONG).show();
                }
            }
        }
    }

    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (mBridgeManager.getUseDeveloperSupport() && keyCode == KeyEvent.KEYCODE_MEDIA_FAST_FORWARD) {
            event.startTracking();
            return true;
        }
        return false;
    }

    public boolean onKeyUp(int keyCode, KeyEvent event) {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null && mBridgeManager.getUseDeveloperSupport()) {
            if (keyCode == KeyEvent.KEYCODE_MENU) {
                reactInstanceManager.showDevOptionsDialog();
                return true;
            }

            boolean didDoubleTapR = Assertions.assertNotNull(mDoubleTapReloadRecognizer).didDoubleTapR(keyCode, getPlainActivity().getCurrentFocus());
            if (didDoubleTapR) {
                reactInstanceManager.getDevSupportManager().handleReloadJS();
                return true;
            }
        }
        return false;
    }

    public boolean onKeyLongPress(int keyCode, KeyEvent event) {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null && mBridgeManager.getUseDeveloperSupport() && keyCode == KeyEvent.KEYCODE_MEDIA_FAST_FORWARD) {
            reactInstanceManager.showDevOptionsDialog();
            return true;
        }
        return false;
    }

    public boolean onBackPressed() {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null) {
            reactInstanceManager.onBackPressed();
            return true;
        }
        return false;
    }

    public boolean onNewIntent(Intent intent) {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null) {
            reactInstanceManager.onNewIntent(intent);
            return true;
        }
        return false;
    }

    public void onWindowFocusChanged(boolean hasFocus) {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null) {
            reactInstanceManager.onWindowFocusChange(hasFocus);
        }
    }

    public void onConfigurationChanged(Configuration newConfig) {
        ReactInstanceManager reactInstanceManager = getReactInstanceManager();
        if (reactInstanceManager != null) {
            reactInstanceManager.onConfigurationChanged(this.getContext(), newConfig);
        }
    }

    @TargetApi(Build.VERSION_CODES.M)
    public void requestPermissions(String[] permissions, int requestCode, PermissionListener listener) {
        mPermissionListener = listener;
        getPlainActivity().requestPermissions(permissions, requestCode);
    }

    public void onRequestPermissionsResult(final int requestCode, final String[] permissions, final int[] grantResults) {
        mPermissionsCallback = args -> {
            if (mPermissionListener != null && mPermissionListener.onRequestPermissionsResult(requestCode, permissions, grantResults)) {
                mPermissionListener = null;
            }
        };
    }

    private Context getContext() {
        return Assertions.assertNotNull(mActivity);
    }

    private Activity getPlainActivity() {
        return ((Activity) getContext());
    }

}
