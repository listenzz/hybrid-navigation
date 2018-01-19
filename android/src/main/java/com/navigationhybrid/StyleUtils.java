package com.navigationhybrid;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.StrictMode;
import android.support.annotation.NonNull;
import android.util.Log;

import com.facebook.react.views.text.ReactFontManager;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.List;

import javax.annotation.Nullable;

/**
 * Created by Listen on 2017/12/26.
 */

public class StyleUtils {

    private static final String TAG = "ReactNative";

    // {"__packager_asset":true,
    // "width":24,
    // "height":24,
    // "uri":"http://10.0.2.2:8081/assets/playground/src/ic_settings@3x.png?platform=android&hash=d12cb52d785444661bacffba8115fdda",
    // "scale":3}
    public static Drawable createDrawable(Context context, @NonNull Bundle imageInfo) {
        String uri = imageInfo.getString("uri");
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
        } else if (uri.startsWith("file")){
            Bitmap bitmap = BitmapFactory.decodeFile(Uri.parse(uri).getPath());
            drawable = new BitmapDrawable(context.getResources(), bitmap);
        } else if (uri.startsWith("font")) {
            Uri u = Uri.parse(uri);
            String fontFamily = u.getHost();
            List<String> fragments = u.getPathSegments();
            if (fragments.size() != 2) {
                // FIXME return a meaning drawable
                return new ColorDrawable();
            }
            String glyph = fragments.get(0);
            Integer fontSize = Integer.valueOf(fragments.get(1));
            Log.w(TAG, "fontFamily: " + u.getHost() + " glyph:" + glyph + " fontSize:" + fontSize);
            drawable = getImageForFont(context, fontFamily, glyph, fontSize, Color.WHITE );
        } else {
            int resId = getResourceDrawableId(context, uri);
            drawable =  resId > 0 ? context.getResources().getDrawable(resId) : null;
        }

        return drawable;
    }

    public static int getResourceDrawableId(Context context, @Nullable String name) {
        if (name == null || name.isEmpty()) {
            return 0;
        }
        int id = context.getResources().getIdentifier(
                name,
                "drawable",
                context.getPackageName());
        return id;
    }

    public static Drawable getImageForFont(Context context, String fontFamily, String glyph, Integer fontSize, Integer color) {
        File cacheFolder = context.getCacheDir();
        String cacheFolderPath = cacheFolder.getAbsolutePath() + "/";

        float scale = context.getResources().getDisplayMetrics().density;
        String scaleSuffix = "@" + (scale == (int) scale ? Integer.toString((int) scale) : Float.toString(scale)) + "x";
        int size = Math.round(fontSize*scale);
        String cacheKey = fontFamily + ":" + glyph + ":" + color;
        String hash = Integer.toString(cacheKey.hashCode(), 32);
        String cacheFilePath = cacheFolderPath + hash + "_" + Integer.toString(fontSize) + scaleSuffix + ".png";
        String cacheFileUrl = "file://" + cacheFilePath;
        File cacheFile = new File(cacheFilePath);

        if(cacheFile.exists()) {
            Bitmap bitmap = BitmapFactory.decodeFile(Uri.parse(cacheFileUrl).getPath());
            return new BitmapDrawable(context.getResources(), bitmap);

        } else {
            FileOutputStream fos = null;
            Typeface typeface = ReactFontManager.getInstance().getTypeface(fontFamily, 0, context.getAssets());
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
                return new BitmapDrawable(context.getResources(), bitmap);
            } catch (FileNotFoundException e) {
                Log.e(TAG, "", e);
            } catch (IOException e) {
                Log.e(TAG, "", e);
            }
            finally {
                if (fos != null) {
                    try {
                        fos.close();
                    }
                    catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        return null;
    }

    public static int generateGrayColor(int color) {
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        int gray = Math.max(Math.max(red, green), blue);
        return Color.rgb( gray, gray, gray);
    }

}
