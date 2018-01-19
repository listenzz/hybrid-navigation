package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.NonNull;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.navigationhybrid.androidnavigation.AwesomeFragment;
import com.navigationhybrid.androidnavigation.FragmentHelper;

/**
 * Created by Listen on 2017/11/20.
 */

public class ReactFragmentHelper {

    private static final String TAG = "ReactNative";

    public static AwesomeFragment createFragment(@NonNull String moduleName, Bundle props, Bundle options) {
        NativeFragment fragment = null;
        ReactBridgeManager reactBridgeManager = ReactBridgeManager.instance;
        if (reactBridgeManager.hasReactModule(moduleName)) {
            fragment = new ReactFragment();
        } else {
            Class<? extends NativeFragment> fragmentClass = reactBridgeManager.nativeModuleClassForName(moduleName);
            if (fragmentClass == null) {
                //throw new IllegalArgumentException("未能找到名为 " + moduleName + " 的模块，你是否忘了注册？");
                FLog.e(TAG, "未能找到名为 " + moduleName + " 的模块，你是否忘了注册？");
            }
            try {
                fragment = fragmentClass.newInstance();
            } catch (Exception e) {
                // ignore
            }
        }

        if (fragment != null) {
            if (options == null) {
                options = new Bundle();
            }

            if (props == null) {
                props = new Bundle();
            }

            if (reactBridgeManager.hasReactModule(moduleName)) {
                ReadableMap readableMap = reactBridgeManager.reactModuleOptionsForKey(moduleName);
                if (readableMap == null) {
                    readableMap = Arguments.createMap();
                }
                WritableMap writableMap = Arguments.createMap();
                writableMap.merge(readableMap);
                writableMap.merge(Arguments.fromBundle(options));
                options = Arguments.toBundle(writableMap);
            }

            Bundle args = FragmentHelper.getArguments(fragment);
            args.putBundle(Constants.ARG_PROPS, props);
            args.putBundle(Constants.ARG_OPTIONS, options);
            args.putString(Constants.ARG_MODULE_NAME, moduleName);
            fragment.setArguments(args);

        }

        return fragment;
    }

    public static Bundle optionsByModuleName(String moduleName) {
        ReactBridgeManager reactBridgeManager = ReactBridgeManager.instance;
        ReadableMap readableMap = reactBridgeManager.reactModuleOptionsForKey(moduleName);
        if (readableMap == null) {
            readableMap = Arguments.createMap();
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(readableMap);

        return Arguments.toBundle(writableMap);
    }


}
