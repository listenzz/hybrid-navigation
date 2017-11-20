package com.navigationhybrid.playground;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.navigationhybrid.NavigationFragment;

/**
 * Created by Listen on 2017/11/20.
 */

public class NativeNavigationFragment extends NavigationFragment {

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_native_navigation, container, false);

        view.findViewById(R.id.push_to_native).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                navigator.push("NativeNavigation");
            }
        });

        view.findViewById(R.id.push_to_react).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

            }
        });

        view.findViewById(R.id.pop_to_root).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                navigator.popToRoot();
            }
        });


        view.findViewById(R.id.request_from_native).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

            }
        });

        view.findViewById(R.id.request_from_react).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

            }
        });

        return view;
    }


    @Override
    public void onResume() {
        super.onResume();

        if (getView() != null) {
            getView().findViewById(R.id.pop_to_root).setEnabled(!navigator.isRoot());
        }


    }
}
