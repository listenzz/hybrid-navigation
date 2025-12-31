package com.reactnative.hybridnavigation.example;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.navigation.androidx.AwesomeFragment;
import com.navigation.androidx.StackFragment;
import com.navigation.androidx.Style;
import com.reactnative.hybridnavigation.HybridFragment;

import java.util.Objects;

/**
 * Created by Listen on 2018/1/30.
 */

public class NativeFragment extends HybridFragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_native, container, false);

        root.findViewById(R.id.push_to_react).setOnClickListener(view -> {
            StackFragment stackFragment = getStackFragment();
            if (stackFragment != null) {
                String popToId = getProps().getString("popToId");
                if (popToId == null) {
                    popToId = getSceneId();
                }
                Bundle props = new Bundle();
                props.putString("popToId", popToId);
                AwesomeFragment fragment = getReactManager().createFragment("Navigation", props, null);
                stackFragment.pushFragment(fragment);
            }

        });

        root.findViewById(R.id.push_to_native).setOnClickListener(view -> {
            StackFragment stackFragment = getStackFragment();
            if (stackFragment != null) {
                String popToId = getProps().getString("popToId");
                if (popToId == null) {
                    popToId = getSceneId();
                }
                Bundle props = new Bundle();
                props.putString("popToId", popToId);
                props.putString("greeting", "Hello, Native");
                HybridFragment fragment = new NativeFragment();
                fragment.setAppProperties(props);
                stackFragment.pushFragment(fragment);
            }
        });

        return root;
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        super.onCustomStyle(style);
        Bundle props = getProps();
        String greeting = props.getString("greeting");
        if (greeting != null) {
            style.setToolbarBackgroundColor(Color.RED);
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Bundle props = getProps();
        String greeting = props.getString("greeting");
		setTitle(Objects.requireNonNullElse(greeting, "Native"));
    }
}
