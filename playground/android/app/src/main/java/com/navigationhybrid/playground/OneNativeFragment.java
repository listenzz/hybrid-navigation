package com.navigationhybrid.playground;

import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.navigationhybrid.HybridFragment;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.NavigationFragment;
import me.listenzz.navigation.Style;

/**
 * Created by Listen on 2018/1/30.
 */

public class OneNativeFragment extends HybridFragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_native, container, false);

        root.findViewById(R.id.push_to_react).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                NavigationFragment navigationFragment = getNavigationFragment();
                if (navigationFragment != null) {
                    String popToId = getProps().getString("popToId");
                    if (popToId == null) {
                        popToId = getSceneId();
                    }
                    Bundle props = new Bundle();
                    props.putString("popToId", popToId);
                    AwesomeFragment fragment = getReactBridgeManager().createFragment("Navigation", props, null);
                    navigationFragment.pushFragment(fragment);
                }

            }
        });

        root.findViewById(R.id.push_to_native).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                NavigationFragment navigationFragment = getNavigationFragment();
                if (navigationFragment != null) {
                    String popToId = getProps().getString("popToId");
                    if (popToId == null) {
                        popToId = getSceneId();
                    }
                    Bundle props = new Bundle();
                    props.putString("popToId", popToId);
                    props.putString("greeting", "Hello, Native");
                    HybridFragment fragment = new OneNativeFragment();
                    fragment.setAppProperties(props);
                    navigationFragment.pushFragment(fragment);
                }
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
            style.setStatusBarColor(Color.RED);
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        Bundle props = getProps();
        String greeting = props.getString("greeting");
        if (greeting != null) {
            setTitle(greeting);
        } else {
            setTitle("Native");
        }
    }

}
