package com.navigationhybrid.playground;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.navigationhybrid.NavigationFragment;

/**
 * Created by Listen on 2017/11/20.
 */

public class NativeResultFragment extends NavigationFragment {

    EditText resultText;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_native_result, container, false);

        resultText = view.findViewById(R.id.result);

        view.findViewById(R.id.send_result).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Bundle result = new Bundle();
                result.putString("text", resultText.getText().toString());
                navigator.setResult(Activity.RESULT_OK, result);
                navigator.dismiss();
            }
        });

        view.findViewById(R.id.push_to_react).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                navigator.push("ReactResult", getHomeProps(), null, true);
            }
        });

        view.findViewById(R.id.push_to_native).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                navigator.push("NativeResult", getHomeProps(), null, true);
            }
        });

        view.findViewById(R.id.back_to_home).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Bundle props = getProps();
                String homeId = props.getString("homeId");
                if (homeId != null) {
                    navigator.popTo(homeId);
                }
            }
        });

        view.findViewById(R.id.replace_with_react).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (navigator.isRoot()) {
                    navigator.replace("ReactResult");
                } else {
                    navigator.replace("ReactResult", getHomeProps(), null);
                }
            }
        });

        view.findViewById(R.id.replace_all_with_one_react).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                navigator.replaceToRoot("ReactResult");
            }
        });

        return view;
    }

    String getPassHomeId() {
        Bundle props = getProps();
        String homeId = props.getString("homeId");
        if (homeId == null) {
            homeId = getSceneId();
        }
        return homeId;
    }

    Bundle getHomeProps() {
        String homeId = getPassHomeId();
        Bundle props = new Bundle();
        props.putString("homeId", homeId);
        return props;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        setTitle("native result");
        if (navigator.isRoot()) {
            getView().findViewById(R.id.back_to_home).setEnabled(false);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        hideSoftInput(resultText);
    }

    /**
     * 隐藏软键盘
     */
    public static void hideSoftInput(View view) {
        if (view == null || view.getContext() == null) return;
        InputMethodManager imm = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

}
