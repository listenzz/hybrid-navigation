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
import me.listenzz.navigation.FragmentHelper;
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
                    AwesomeFragment fragment = getReactBridgeManager().createFragment("Options");
                    navigationFragment.pushFragment(fragment);
                }

            }
        });

        root.findViewById(R.id.push_to_native).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                NavigationFragment navigationFragment = getNavigationFragment();
                if (navigationFragment != null) {
                    AwesomeFragment fragment = new OneNativeFragment();
                    Bundle args = new Bundle();
                    args.putString("greeting", "Hello, Native");
                    fragment.setArguments(args);
                    navigationFragment.pushFragment(fragment);
                }
            }
        });

        return root;
    }

    @Override
    protected void onCustomStyle(@NonNull Style style) {
        super.onCustomStyle(style);
        Bundle args = FragmentHelper.getArguments(this);
        String greeting = args.getString("greeting");
        if (greeting != null) {
            style.setToolbarBackgroundColor(Color.RED);
            style.setStatusBarColor(Color.RED);
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        Bundle args = FragmentHelper.getArguments(this);
        String greeting = args.getString("greeting");
        if (greeting != null) {
            setTitle(greeting);
        } else {
            setTitle("Native");
        }
    }

}
