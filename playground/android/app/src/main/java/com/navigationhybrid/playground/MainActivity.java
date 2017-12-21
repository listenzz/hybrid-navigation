package com.navigationhybrid.playground;

import android.os.Bundle;

import com.navigationhybrid.ReactAppCompatActivity;

public class MainActivity extends ReactAppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected String getMainComponentName() {
        return "Navigation";
    }
}
