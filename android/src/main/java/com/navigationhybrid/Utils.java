package com.navigationhybrid;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;

import me.listenzz.navigation.DrawableUtils;

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
        return  iconUri;
    }
}
