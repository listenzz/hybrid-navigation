package com.navigationhybrid;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.navigationhybrid.view.TopBar;

import java.util.List;

/**
 * Created by Listen on 2017/11/20.
 */

public class NavigationFragment extends Fragment {

    protected static final String TAG = "ReactNative";

    public static final String NAVIGATION_MODULE_NAME = "module_name";
    public static final String NAVIGATION_PROPS = "props";
    public static final String NAVIGATION_OPTIONS = "options";
    public static final String NAVIGATION_CONTAINER_ID = "container_id";
    public static final String NAVIGATION_ANIM = "anim";
    public static final String NAVIGATION_REQUEST_CODE = "request_code";

    public static final String PROPS_NAV_ID = "navId";
    public static final String PROPS_SCENE_ID = "sceneId";

    protected Navigator navigator;
    protected TopBar topBar;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, toString() + "#onCreate");
        navigator = getNavigator();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, toString() + "#onDestroy");
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        Log.d(TAG, toString() + "#onAttach");
    }

    @Override
    public void onDetach() {
        super.onDetach();
        Log.d(TAG, toString() + "#onDetach");
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG, toString() + "#onResume");
    }

    @Override
    public void onPause() {
        super.onPause();
        Log.d(TAG, toString() + "#onPause");
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Log.d(TAG, toString() + "#onViewCreated");
        if (view instanceof LinearLayout) {
            LinearLayout linearLayout = (LinearLayout) view;
            TopBar topBar = new TopBar(getContext());
            this.topBar = topBar;
            linearLayout.addView(topBar, 0, new LinearLayout.LayoutParams(-1, -2));
        } else if (view instanceof FrameLayout) {
            FrameLayout frameLayout = (FrameLayout) view;
            TopBar topBar = new TopBar(getContext());
            this.topBar = topBar;
            frameLayout.addView(topBar,  new FrameLayout.LayoutParams(-1, -2));
        } else {
            throw new UnsupportedOperationException("NavigationFragment 还没适配 " + view.getClass().getSimpleName());
        }

        if (topBar != null) {
            setupTopBar();
        }
    }
    
    protected void setupTopBar() {
        if (!navigator.isRoot()) {
            Toolbar toolbar = topBar.getToolbar();
            toolbar.setNavigationIcon(R.drawable.nav_ic_arrow_back_white);
            toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    navigator.pop();
                }
            });
        }
    }

    public void setTitle(String title) {
        if (topBar != null) {
            topBar.setTitle(title);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        topBar = null;
        Log.d(TAG, toString() + "#onDestroyView");
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        Log.d(TAG, toString() + "#onHiddenChanged hidden="+ hidden);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        Log.d(TAG, toString() + "#onCreateAnimation transit=" + transit + " enter="+ enter + " anim=" + navigator.anim.name());
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
        Log.i(TAG, toString() + "#onFragmentResult requestCode=" + requestCode + " resultCode=" + resultCode + " data=" + data );
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
            int containerId = args.getInt(NAVIGATION_CONTAINER_ID);
            navigator = new Navigator(navId, sceneId, getFragmentManager(), containerId);
            String anim = args.getString(NAVIGATION_ANIM);
            if (anim != null) {
                navigator.anim = PresentAnimation.valueOf(anim);
            }
            navigator.requestCode = args.getInt(NAVIGATION_REQUEST_CODE);
            Log.i(TAG, navigator.toString());
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
        if (navigator != null) {
            navigator.anim = animation;
        }
    }

    public void setRequestCode(int requestCode) {
        Bundle args = FragmentHelper.getArguments(this);
        args.putInt(NAVIGATION_REQUEST_CODE, requestCode);
        setArguments(args);
        if (navigator != null) {
            navigator.requestCode = requestCode;
        }
    }

}
