package com.navigationhybrid;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import me.listenzz.navigation.DrawableUtils;
import me.listenzz.navigation.FontManager;

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
            iconUri = Utils.filepathFromFont(context, uri);
        }
        return  iconUri;
    }

    public static String filepathFromFont(@NonNull Context context, @NonNull String uri) {
        Uri u = Uri.parse(uri);
        String fontFamily = u.getHost();
        List<String> fragments = u.getPathSegments();
        if (fragments.size() < 2) {
            throw new IllegalArgumentException("font uri 格式不对。");
        }
        String glyph = fragments.get(0);
        Integer fontSize = Integer.valueOf(fragments.get(1));

        int color = Color.WHITE;

        if (fragments.size() == 3) {
            String hex = fragments.get(2);
            color = Color.parseColor("#" + hex);
        }
        return filepathFromFont(context, fontFamily, glyph, fontSize, color);
    }

    public static String filepathFromFont(Context context, String fontFamily, String glyph, Integer fontSize, Integer color) {
        File cacheFolder = context.getCacheDir();
        String cacheFolderPath = cacheFolder.getAbsolutePath() + "/";

        float scale = context.getResources().getDisplayMetrics().density;
        String scaleSuffix = "@" + (scale == (int) scale ? Integer.toString((int) scale) : Float.toString(scale)) + "x";
        int size = Math.round(fontSize * scale);
        String cacheKey = fontFamily + ":" + glyph + ":" + color;
        String hash = Integer.toString(cacheKey.hashCode(), 32);
        String cacheFilePath = cacheFolderPath + hash + "_" + Integer.toString(fontSize) + scaleSuffix + ".png";
        String cacheFileUrl = "file://" + cacheFilePath;
        File cacheFile = new File(cacheFilePath);

        if (cacheFile.exists()) {
            return cacheFileUrl;

        } else {
            FileOutputStream fos = null;
            Typeface typeface = FontManager.getInstance().getTypeface(fontFamily, 0, context.getAssets());
            Paint paint = new Paint();
            paint.setTypeface(typeface);
            paint.setColor(color);
            paint.setTextSize(size);
            paint.setAntiAlias(true);
            Rect textBounds = new Rect();
            paint.getTextBounds(glyph, 0, glyph.length(), textBounds);

            Bitmap bitmap = Bitmap.createBitmap(textBounds.width(), textBounds.height(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            canvas.drawText(glyph, -textBounds.left, -textBounds.top, paint);

            try {
                fos = new FileOutputStream(cacheFile);
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
                fos.flush();
                fos.close();
                fos = null;
                return cacheFileUrl;
            } catch (FileNotFoundException e) {
                Log.e(TAG, "", e);
            } catch (IOException e) {
                Log.e(TAG, "", e);
            } finally {
                if (fos != null) {
                    try {
                        fos.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return null;
    }
}
