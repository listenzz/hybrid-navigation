package com.navigationhybrid.playground;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.navigationhybrid.HybridFragment;

import me.listenzz.navigation.AnimationType;

public class NativeModalFragment extends HybridFragment {

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
