package com.navigation.androidx;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.StrictMode;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import java.net.URL;

public class DrawableUtils {

    private static final String TAG = "Navigation";

    @Nullable
    public static Drawable fromUri(@NonNull Context context, @NonNull String uri) {
        Drawable drawable = null;
        if (uri.startsWith("http")) {
            try {
                StrictMode.ThreadPolicy threadPolicy = StrictMode.getThreadPolicy();
                StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder().permitNetwork().build());

                URL url = new URL(uri);
                Bitmap bitmap = BitmapFactory.decodeStream(url.openStream());
                drawable = new BitmapDrawable(context.getResources(), bitmap);

                StrictMode.setThreadPolicy(threadPolicy);
            } catch (Exception e) {
                Log.e(TAG, e.toString());
            }
        } else if (uri.startsWith("file")) {
            Bitmap bitmap = BitmapFactory.decodeFile(Uri.parse(uri).getPath());
            drawable = new BitmapDrawable(context.getResources(), bitmap);
        } else {
            int resId = fromResourceDrawableId(context, uri);
            drawable = resId > 0 ? ContextCompat.getDrawable(context, resId) : null;
        }
        return drawable;
    }

    public static int fromResourceDrawableId(@NonNull Context context, @Nullable String name) {
        if (name == null || name.isEmpty()) {
            return 0;
        }
        return context.getResources().getIdentifier(
                name,
                "drawable",
                context.getPackageName());
    }
}
