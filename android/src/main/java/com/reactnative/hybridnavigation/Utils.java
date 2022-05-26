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

import com.navigation.androidx.DrawableUtils;

import java.util.List;

public class Utils {

    private static final String TAG = "Navigator";

    public static Drawable createTabBarShadow(Context context, Bundle shadowImage) {
        Bundle image = shadowImage.getBundle("image");
        String color = shadowImage.getString("color");
        if (image != null) {
            return createImageShadow(context, image);
        }

        if (color != null) {
            return new ColorDrawable(Color.parseColor(color));
        }

        return new ColorDrawable();
    }

    @Nullable
    private static Drawable createImageShadow(Context context, Bundle image) {
        String uri = image.getString("uri");
        if (uri == null) {
            return new ColorDrawable();
        }

        Drawable drawable = DrawableUtils.fromUri(context, uri);
        if (drawable instanceof BitmapDrawable) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
            bitmapDrawable.setTileModeX(Shader.TileMode.REPEAT);
        }
        return drawable;
    }

    public static String getIconUri(Context context, String uri) {
        if (uri != null && uri.startsWith("font://")) {
            return DrawableUtils.filepathFromFont(context, uri);
        }
        return uri;
    }

    @Nullable
    public static ReactFragment findReactFragment(@NonNull Fragment fragment) {
        if (fragment instanceof ReactFragment) {
            return (ReactFragment) fragment;
        }

        if (!fragment.isAdded()) {
            return null;
        }

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

        return null;
    }
}
