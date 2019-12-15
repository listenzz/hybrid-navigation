package com.navigationhybrid.playground;

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

    @Nullable
    @Override
    protected Integer preferredNavigationBarColor() {
        return Color.TRANSPARENT;
    }

}
