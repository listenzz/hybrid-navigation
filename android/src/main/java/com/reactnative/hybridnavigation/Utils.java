package com.reactnative.hybridnavigation;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.navigation.androidx.DrawableUtils;

import java.util.List;


public class Utils {

    private static final String TAG = "Navigation";

    public static Drawable createTabBarShadow(Context context, Bundle shadowImage) {
        Bundle image = shadowImage.getBundle("image");
        String color = shadowImage.getString("color");
        Drawable drawable = new ColorDrawable();
        if (image != null) {
            String uri = image.getString("uri");
            if (uri != null) {
                drawable = DrawableUtils.fromUri(context, uri);
                if (drawable instanceof BitmapDrawable) {
                    BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
                    bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
                }
            }
        } else if (color != null) {
            drawable = new ColorDrawable(Color.parseColor(color));
        }
        return drawable;
    }

    public static String getIconUri(Context context, String uri) {
        String iconUri = uri;
        if (uri != null && uri.startsWith("font://")) {
            iconUri = DrawableUtils.filepathFromFont(context, uri);
        }
        return iconUri;
    }

    @NonNull
    static Bundle mergeOptions(@NonNull Bundle options, @NonNull String key, @NonNull ReadableMap readableMap) {
        Bundle bundle = options.getBundle(key);
        if (bundle == null) {
            bundle = new Bundle();
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(bundle));
        writableMap.merge(readableMap);
        Bundle result = Arguments.toBundle(writableMap);
        assert result != null;
        return result;
    }

    @NonNull
    static Bundle mergeOptions(@NonNull Bundle options, @Nullable ReadableMap readableMap) {
        if (readableMap == null) {
            return options;
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(options));
        writableMap.merge(readableMap);
        Bundle result = Arguments.toBundle(writableMap);
        assert result != null;
        return result;
    }

    @NonNull
    static Bundle mergeOptions(@NonNull Bundle options, @Nullable Bundle bundle) {
        if (bundle == null) {
            return options;
        }
        WritableMap writableMap = Arguments.createMap();
        writableMap.merge(Arguments.fromBundle(options));
        writableMap.merge(Arguments.fromBundle(bundle));
        Bundle result = Arguments.toBundle(writableMap);
        assert result != null;
        return result;
    }

    @Nullable
    static ReactFragment findReactFragment(@NonNull Fragment fragment) {
        if (fragment instanceof ReactFragment) {
            return (ReactFragment) fragment;
        }

        if (fragment.isAdded()) {
            FragmentManager fragmentManager = fragment.getChildFragmentManager();
            Fragment primaryFragment = fragmentManager.getPrimaryNavigationFragment();
            if (primaryFragment != null) {
                return findReactFragment(primaryFragment);
            }

            List<Fragment> fragments = fragmentManager.getFragments();
            int count = fragments.size();
            if (count > 0) {
                Fragment topFragment = fragments.get(count - 1);
                return findReactFragment(topFragment);
            }
        }
        return null;
    }
}
