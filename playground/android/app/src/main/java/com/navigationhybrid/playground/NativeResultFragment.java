package com.navigationhybrid.playground;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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

            }
        });

        view.findViewById(R.id.push_to_native).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                navigator.push("NativeResult");
            }
        });

        return view;
    }


}
