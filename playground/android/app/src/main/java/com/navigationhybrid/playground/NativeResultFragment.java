package com.navigationhybrid.playground;

import com.navigationhybrid.androidnavigation.NavigationFragment;

/**
 * Created by Listen on 2017/11/20.
 */

public class NativeResultFragment extends NavigationFragment {

//    EditText resultText;
//
//    @Nullable
//    @Override
//    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
//        View view = inflater.inflate(R.layout.fragment_native_result, container, false);
//
//        resultText = view.findViewById(R.id.result);
//
//        view.findViewById(R.id.send_result).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                Bundle result = new Bundle();
//                result.putString("text", resultText.getText().toString());
//                getNavigator().setResult(Activity.RESULT_OK, result);
//                getNavigator().dismiss();
//            }
//        });
//
//        view.findViewById(R.id.push_to_react).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                getNavigator().push("ReactResult", getHomeProps(), null, true);
//            }
//        });
//
//        view.findViewById(R.id.push_to_native).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                getNavigator().push("NativeResult", getHomeProps(), null, true);
//            }
//        });
//
//        view.findViewById(R.id.back_to_home).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                Bundle props = getProps();
//                String homeId = props.getString("homeId");
//                if (homeId != null) {
//                    getNavigator().popTo(homeId);
//                }
//            }
//        });
//
//        view.findViewById(R.id.replace_with_react).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                if (getNavigator().isRoot()) {
//                    getNavigator().replace("ReactResult");
//                } else {
//                    getNavigator().replace("ReactResult", getHomeProps(), null);
//                }
//            }
//        });
//
//        view.findViewById(R.id.replace_all_with_one_react).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                getNavigator().replaceToRoot("ReactResult");
//            }
//        });
//
//        return view;
//    }
//
//    String getPassHomeId() {
//        Bundle props = getProps();
//        String homeId = props.getString("homeId");
//        if (homeId == null) {
//            homeId = getSceneId();
//        }
//        return homeId;
//    }
//
//    Bundle getHomeProps() {
//        String homeId = getPassHomeId();
//        Bundle props = new Bundle();
//        props.putString("homeId", homeId);
//        return props;
//    }
//
//    @Override
//    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
//        super.onActivityCreated(savedInstanceState);
//        setTitle("native result");
//        if (getNavigator().isRoot()) {
//            getView().findViewById(R.id.back_to_home).setEnabled(false);
//        }
//    }
//
//    @Override
//    public void onDestroyView() {
//        super.onDestroyView();
//        hideSoftInput(resultText);
//    }
//
//    /**
//     * 隐藏软键盘
//     */
//    public static void hideSoftInput(View view) {
//        if (view == null || view.getContext() == null) return;
//        InputMethodManager imm = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
//        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
//    }

}
