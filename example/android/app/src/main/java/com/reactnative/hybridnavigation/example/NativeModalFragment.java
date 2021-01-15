package com.reactnative.hybridnavigation.example;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.navigation.androidx.AnimationType;
import com.reactnative.hybridnavigation.HybridFragment;

public class NativeModalFragment extends HybridFragment {

    @NonNull
    @Override
    public AnimationType getAnimationType() {
        return AnimationType.Slide;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_modal, container, false);
    }

}
