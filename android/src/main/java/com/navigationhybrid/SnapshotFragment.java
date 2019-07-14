package com.navigationhybrid;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.ImageView;

import me.listenzz.navigation.AppUtils;
import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.BarStyle;
import me.listenzz.navigation.Style;

public class SnapshotFragment extends AwesomeFragment {

    protected static final String TAG = "ReactNative";

    protected static int count = 0;

    private Bitmap snapshot;

    public void setSnapshot(Bitmap snapshot) {
        this.snapshot = snapshot;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.nav_fragment_snapshot, container, false);
        ImageView imageView = view.findViewById(R.id.nav_image);
        if (snapshot != null) {
            imageView.setBackground(new BitmapDrawable(getResources(), snapshot));
        }
        return view;
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        super.onCustomStyle(style);
        Window window = getWindow();
        if (window != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                style.setStatusBarColor(window.getStatusBarColor());
            } else {
                ViewGroup decorViewGroup = (ViewGroup) window.getDecorView();
                View statusBarView = decorViewGroup.findViewWithTag("custom_status_bar_tag");
                ColorDrawable drawable = (ColorDrawable) statusBarView.getBackground();
                style.setStatusBarColor(drawable.getColor());
            }
            style.setStatusBarStyle(AppUtils.isDarkStatusBarStyle(window) ? BarStyle.DarkContent : BarStyle.LightContent);
            style.setStatusBarHidden(AppUtils.isStatusBarHidden(window));
            style.setStatusBarColorAnimated(false);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                style.setNavigationBarColor(window.getNavigationBarColor());
            }
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        count++;
        if (count > 1) {
            if (BuildConfig.DEBUG) {
                throw new IllegalStateException("snapshot call too many times: " + count);
            }
            Log.w(TAG, "snapshot call too many times ------------------------------- " + count);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        count--;
    }
}
