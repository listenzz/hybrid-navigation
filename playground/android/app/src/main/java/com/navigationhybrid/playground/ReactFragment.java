package com.navigationhybrid.playground;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.common.logging.FLog;

/**
 * Created by Listen on 2017/11/19.
 */

public class ReactFragment extends Fragment {

    protected static final String TAG = "navigation";

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FLog.d(TAG, getClass().getSimpleName() + "#onCreate");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        FLog.d(TAG, getClass().getSimpleName() + "#onDestroy");
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        FLog.d(TAG, getClass().getSimpleName() + "#onCreateView");
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        FLog.d(TAG, getClass().getSimpleName() + "#onViewCreated");
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        FLog.d(TAG, getClass().getSimpleName() + "#onDestroyView");
    }

    @Override
    public void onResume() {
        super.onResume();
        FLog.d(TAG, getClass().getSimpleName() + "#onResume");
    }

    @Override
    public void onPause() {
        super.onPause();
        FLog.d(TAG, getClass().getSimpleName() + "#onPause");
    }
}
