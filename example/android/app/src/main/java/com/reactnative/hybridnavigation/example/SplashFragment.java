package com.reactnative.hybridnavigation.example;

import android.app.Dialog;
import android.graphics.Color;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.navigation.androidx.AwesomeFragment;

import javax.annotation.Nullable;

public class SplashFragment extends AwesomeFragment {

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        setStyle(STYLE_NO_FRAME, R.style.SplashTheme);
        setCancelable(false);
        return super.onCreateDialog(savedInstanceState);
    }

    @Override
    protected int preferredNavigationBarColor() {
        return Color.TRANSPARENT;
    }

}
