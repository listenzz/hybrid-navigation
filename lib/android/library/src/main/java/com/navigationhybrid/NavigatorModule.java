package com.navigationhybrid;

import android.os.Handler;
import android.os.Looper;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

/**
 * Created by Listen on 2017/11/20.
 */

public class NavigatorModule extends ReactContextBaseJavaModule{

    private final Handler handler = new Handler(Looper.getMainLooper());


    public NavigatorModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "NavigationHybrid";
    }



}
