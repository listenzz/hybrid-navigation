package com.navigationhybrid;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;

import java.util.List;

/**
 * Created by Listen on 2017/11/20.
 */

public class FragmentHelper {

    public static Bundle getArguments(Fragment fragment) {
        Bundle bundle = fragment.getArguments();
        if (bundle == null) {
            bundle = new Bundle();
            fragment.setArguments(bundle);
        }
        return bundle;
    }

    public static List<Fragment> getActiveFragments(FragmentManager fragmentManager) {
        return fragmentManager.getFragments();
    }

}
