package com.navigationhybrid.playground;

import android.support.multidex.MultiDexApplication;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.navigationhybrid.HybridReactNativeHost;
import com.navigationhybrid.NavigationHybridPackage;
import com.navigationhybrid.ReactBridgeManager;
import com.oblador.vectoricons.VectorIconsPackage;
import com.taihua.hud.HUDReactPackage;
import com.tencent.matrix.Matrix;
import com.tencent.matrix.iocanary.IOCanaryPlugin;
import com.tencent.matrix.iocanary.config.IOConfig;
import com.tencent.matrix.resource.ResourcePlugin;
import com.tencent.matrix.resource.config.ResourceConfig;
import com.tencent.matrix.trace.TracePlugin;
import com.tencent.matrix.trace.config.TraceConfig;
import com.tencent.matrix.util.MatrixLog;

import java.util.Arrays;
import java.util.List;


/**
 * Created by Listen on 2017/11/17.
 */

public class MainApplication extends MultiDexApplication implements ReactApplication{

    private static final String TAG = "Matrix.Application";

    private final ReactNativeHost mReactNativeHost = new HybridReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                    new MainReactPackage(),
                    new NavigationHybridPackage(),
                    new VectorIconsPackage(),
                    new HUDReactPackage()
            );
        }

        @Override
        protected String getJSMainModuleName() {
            return "playground/index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        DynamicConfigImplDemo dynamicConfig = new DynamicConfigImplDemo();
        boolean matrixEnable = dynamicConfig.isMatrixEnable();
        boolean fpsEnable = dynamicConfig.isFPSEnable();
        boolean traceEnable = dynamicConfig.isTraceEnable();

        MatrixLog.i(TAG, "MatrixApplication.onCreate");

        Matrix.Builder builder = new Matrix.Builder(this);
        builder.patchListener(new TestPluginListener(this));

        //trace
        TraceConfig traceConfig = new TraceConfig.Builder()
                .dynamicConfig(dynamicConfig)
                .enableFPS(fpsEnable)
                .enableMethodTrace(traceEnable)
                .enableStartUp(traceEnable)
                .splashActivity("com.navigationhybrid.playground.SplashActivity")
                .build();

        TracePlugin tracePlugin = (new TracePlugin(traceConfig));
        builder.plugin(tracePlugin);

        if (matrixEnable) {

            //resource
            builder.plugin(new ResourcePlugin(new ResourceConfig.Builder()
                    .dynamicConfig(dynamicConfig)
                    .setDumpHprof(false)
                    .setDetectDebuger(true)     //only set true when in sample, not in your app
                    .build()));
            ResourcePlugin.activityLeakFixer(this);

            //io
            IOCanaryPlugin ioCanaryPlugin = new IOCanaryPlugin(new IOConfig.Builder()
                    .dynamicConfig(dynamicConfig)
                    .build());
            builder.plugin(ioCanaryPlugin);

        }

        Matrix.init(builder.build());

        //start only startup tracer, close other tracer.
        tracePlugin.start();
        //only stop at sample app, in your app do not call onDestroy
        tracePlugin.getFPSTracer().onDestroy();

        MatrixLog.i("Matrix.HackCallback", "end:%s", System.currentTimeMillis());



        SoLoader.init(this, false);

        ReactBridgeManager bridgeManager = ReactBridgeManager.get();
        bridgeManager.install(getReactNativeHost());

        // register native modules
        bridgeManager.registerNativeModule("OneNative", OneNativeFragment.class);
        bridgeManager.registerNativeModule("NativeModal", NativeModalFragment.class);

    }
}
