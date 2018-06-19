package com.navigationhybrid.playground;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import me.listenzz.navigation.AwesomeFragment;
import me.listenzz.navigation.FragmentHelper;

public class CustomContainerFragment extends AwesomeFragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_custom_container, container, false);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (savedInstanceState != null) {
            containerFragment = (AwesomeFragment) getChildFragmentManager().findFragmentById(R.id.container);
            backgroundFragment = (AwesomeFragment) getChildFragmentManager().findFragmentById(R.id.background);
        } else {
            if (backgroundFragment == null || containerFragment == null) {
                throw new IllegalArgumentException("必须指定 backgroundFragment 以及 containerFragment");
            } else {
                FragmentHelper.addFragmentToAddedList(getChildFragmentManager(), R.id.background, backgroundFragment, false);
                FragmentHelper.addFragmentToAddedList(getChildFragmentManager(), R.id.container, containerFragment, true);
            }
        }
    }

    private AwesomeFragment backgroundFragment;

    private AwesomeFragment containerFragment;

    public void setBackgroundFragment(@NonNull final AwesomeFragment backgroundFragment) {
        this.backgroundFragment = backgroundFragment;
    }

    public void setContainerFragment(@NonNull final AwesomeFragment containerFragment) {
        this.containerFragment = containerFragment;
    }
}
