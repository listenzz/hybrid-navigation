package com.navigationhybrid;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

import java.util.List;

/**
 * Created by Listen on 2017/11/20.
 */

public class NavigationFragment extends Fragment {

    protected static final String TAG = "ReactNative";

    public static final String NAVIGATION_PROPS = "props";
    public static final String NAVIGATION_OPTIONS = "options";
    public static final String NAVIGATION_ANIM = "anim";
    public static final String NAVIGATION_REQUEST_CODE = "request_code";

    public static final String PROPS_NAV_ID = "navId";
    public static final String PROPS_SCENE_ID = "sceneId";

    protected Navigator navigator;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, getClass().getSimpleName() + "onCreate");
        navigator = getNavigator();
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        Log.i(TAG, getClass().getSimpleName() + "#onCreateAnimation transit=" + transit + " enter="+ enter);
        if (transit == FragmentTransaction.TRANSIT_NONE) {
            return AnimationUtils.loadAnimation(getContext(), R.anim.no_anim);
        }

        if (transit == FragmentTransaction.TRANSIT_FRAGMENT_OPEN) {
            if (enter) {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.enter);
            } else {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.exit);
            }
        } else if (transit == FragmentTransaction.TRANSIT_FRAGMENT_CLOSE) {
            if (enter) {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.popEnter);
            } else {
                return AnimationUtils.loadAnimation(getContext(), navigator.anim.popExit);
            }
        }
        return super.onCreateAnimation(transit, enter, nextAnim);
    }

    public void onFragmentResult(int requestCode, int resultCode, Bundle data) {
        List<Fragment> fragments =  getChildFragmentManager().getFragments();
        for (Fragment fragment : fragments) {
            if (fragment instanceof NavigationFragment) {
                NavigationFragment child = (NavigationFragment) fragment;
                child.onFragmentResult(requestCode, resultCode, data);
            }
        }
    }

    public Navigator getNavigator() {
        if (getActivity() == null) {
            throw new IllegalStateException("不能在 fragment 还没添加到 activity 的时候调用此方法");
        }
        if (navigator == null) {
            Bundle args = getArguments();
            Bundle props = args.getBundle(NAVIGATION_PROPS);
            String navId = props.getString(PROPS_NAV_ID);
            String sceneId = props.getString(PROPS_SCENE_ID);
            navigator = new Navigator(navId, sceneId, getFragmentManager(), R.id.react_activity_content_id);
            String anim = args.getString(NAVIGATION_ANIM);
            if (anim != null) {
                navigator.anim = PresentAnimation.valueOf(anim);
            }
            navigator.requestCode = args.getInt(NAVIGATION_REQUEST_CODE);
        }
        return navigator;
    }

    public String getSceneId() {
        Bundle args = getArguments();
        Bundle props = args.getBundle(NAVIGATION_PROPS);
        String sceneId = props.getString(PROPS_SCENE_ID);
        return sceneId;
    }

    public String getNavId() {
        Bundle args = getArguments();
        Bundle props = args.getBundle(NAVIGATION_PROPS);
        String navId = props.getString(PROPS_NAV_ID);
        return navId;
    }

    public void setCurrentAnimations(PresentAnimation animation) {
        Bundle args = FragmentHelper.getArguments(this);
        args.putString(NAVIGATION_ANIM, animation.name());
        setArguments(args);
        navigator.anim = PresentAnimation.valueOf(animation.name());
    }

    public void setRequestCode(int requestCode) {
        Bundle args = FragmentHelper.getArguments(this);
        args.putInt(NAVIGATION_REQUEST_CODE, requestCode);
        setArguments(args);
        navigator.requestCode = requestCode;
    }



}
