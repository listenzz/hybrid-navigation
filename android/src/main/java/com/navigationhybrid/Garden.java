package com.navigationhybrid;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.StrictMode;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.util.TypedValue;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.views.text.ReactFontManager;
import com.navigationhybrid.view.TextDrawable;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.List;

import javax.annotation.Nullable;

import static com.navigationhybrid.NavigationFragment.PROPS_NAV_ID;
import static com.navigationhybrid.NavigationFragment.PROPS_SCENE_ID;

/**
 * Created by Listen on 2017/11/22.
 */

public class Garden {

    public static String TOP_BAR_STYLE_LIGHT_CONTENT = "light-content";
    public static String TOP_BAR_STYLE_DARK_CONTENT = "dark-content";

    private static final String TAG = "ReactNative";
    private static int INVALID_COLOR = Integer.MAX_VALUE;

    private static String topBarStyle = TOP_BAR_STYLE_LIGHT_CONTENT;
    private static Drawable backIcon;
    private static int statusBarColor = INVALID_COLOR;
    private static int topBarBackgroundColor = INVALID_COLOR;
    private static int topBarTintColor = INVALID_COLOR;
    private static int titleTextColor = INVALID_COLOR;
    private static int titleTextSize = 17;
    private static String titleAlignment = "left"; // left, center, default is left

    private static int barButtonItemTintColor = INVALID_COLOR;
    private static int barButtonItemTextSize = 15;

    private static int tabBarItemColor = Color.parseColor("#c9c9c9");
    private static int tabBarItemSelectedColor = Color.parseColor("#F44336");
    private static int tabBarItemTextSize;
    private static int tabBarItemBubbleColor = Color.parseColor("#FF4040");
    private static int tabBarItemBubbleBorderColor = Color.WHITE;

    public static void setTopBarStyle(String barStyle) {
        topBarStyle = barStyle;
    }

    public static String getTopBarStyle() {
        return topBarStyle;
    }

    public static void setStatusBarColor(int color) {
        statusBarColor = color;
    }

    public static int getStatusBarColor(Context context) {
        if (statusBarColor != INVALID_COLOR) {
            return statusBarColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return getTopBarBackgroundColor(context);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return getTopBarBackgroundColor(context);
        }

        return Color.BLACK;
    }

    public static void setTopBarBackgroundColor(int color) {
        topBarBackgroundColor = color;
    }

    public static int getTopBarBackgroundColor(Context context) {
        if (topBarBackgroundColor != INVALID_COLOR) {
            return topBarBackgroundColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.BLACK;
        } else {
            return Color.WHITE;
        }
    }

    public static void setTopBarTintColor(int color) {
        topBarTintColor = color;
    }

    public static int getTopBarTintColor() {
        if (topBarTintColor != INVALID_COLOR) {
            return topBarTintColor;
        }

        if (topBarStyle.equals(TOP_BAR_STYLE_LIGHT_CONTENT)) {
            return Color.WHITE;
        } else {
            return Color.BLACK;
        }
    }

    public static void setBackIcon(Bundle icon) {
        backIcon = createDrawable(icon);
    }

    public static Drawable getBackIcon(Context context) {
        if (backIcon != null) {
            return backIcon;
        }
        Drawable drawable = context.getResources().getDrawable(R.drawable.nav_ic_arrow_back);
        drawable.setColorFilter(Garden.getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
        backIcon = drawable;
        return backIcon;
    }

    public static void setTitleTextColor(int color) {
        titleTextColor = color;
    }

    public static int getTitleTextColor() {
        if (titleTextColor != INVALID_COLOR) {
            return titleTextColor;
        }

        return getTopBarTintColor();
    }

    public static void setTitleTextSize(int dp) {
        titleTextSize = dp;
    }

    public static int getTitleTextSizeDp() {
        return titleTextSize;
    }

    public static void setBarButtonItemTintColor(int color) {
        barButtonItemTintColor = color;
    }

    public static int getBarButtonItemTintColor() {
        if (barButtonItemTintColor != INVALID_COLOR) {
            return barButtonItemTintColor;
        }
        return getTopBarTintColor();
    }


    public static void setBarButtonItemTextSize(int dp) {
        barButtonItemTextSize = dp;
    }

    public static int  getBarButtonItemTextSizeDp() {
        return barButtonItemTextSize;
    }

    public static void setTitleAlignment(String alignment) {
        titleAlignment = alignment;
    }

    public static String getTitleAlignment() {
        return titleAlignment;
    }


    // ----- instance ------

    private  final NavigationFragment fragment;

    public Garden(@NonNull NavigationFragment fragment) {
        this.fragment = fragment;
    }

    public void setTopBarStyle() {
        fragment.toolBar.setBackgroundColor(Garden.getTopBarBackgroundColor(fragment.getContext()));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = fragment.getActivity().getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Garden.getStatusBarColor(fragment.getContext()));
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (Garden.getTopBarStyle().equals(Garden.TOP_BAR_STYLE_DARK_CONTENT)) {
                    window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                }
            }
        }
    }

    public void setTitle(String title) {
        if (fragment.getView() == null) return;
        TextView titleView = fragment.toolBar.getTitleView();
        if (Garden.getTitleAlignment().equals("center")) { // default is 'left'
            fragment.toolBar.setTitleViewAlignment("center");
        }
        titleView.setTextColor(Garden.getTitleTextColor());
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Garden.getTitleTextSizeDp());
        titleView.setText(title);
        //titleView.getPaint().setFakeBoldText(true); // 粗体
    }

    public void setTitleItem(Bundle titleItem) {
        if (titleItem != null) {
            String title = titleItem.getString("title");
            setTitle(title);
        }
    }

    public void setLeftBarButtonItem(Bundle leftBarButtonItem) {
        if (fragment.getView() == null) return;
        if (leftBarButtonItem == null) { return; }
        Log.d(TAG, "leftBarButtonItem: " + leftBarButtonItem.toString());

        Bundle icon = leftBarButtonItem.getBundle("icon");
        String title = leftBarButtonItem.getString("title");
        if (icon != null) {
            String uri = icon.getString("uri");
            if (uri != null) {
                Drawable drawable = createDrawable(icon);
                fragment.toolBar.setNavigationIcon(drawable);
            }
        } else if (title != null) {
            TextDrawable textDrawable = new TextDrawable(fragment.getContext());
            textDrawable.setTextColor(Garden.getBarButtonItemTintColor());
            textDrawable.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Garden.getBarButtonItemTextSizeDp());
            textDrawable.setText(title);
            fragment.toolBar.setNavigationIcon(textDrawable);
        }

        final String action = leftBarButtonItem.getString("action");
        if (action != null) {
            fragment.toolBar.setNavigationOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
                    Bundle bundle = new Bundle();
                    bundle.putString("action", action);
                    bundle.putString(PROPS_NAV_ID, fragment.navigator.navId);
                    bundle.putString(PROPS_SCENE_ID, fragment.navigator.sceneId);
                    bridgeManager.sendEvent(Navigator.ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
                }
            });
        }
    }

    public void setRightBarButtonItem(Bundle rightBarButtonItem) {
        if (fragment.getView() == null) return;
        if (rightBarButtonItem != null) {
            Log.d(TAG, rightBarButtonItem.toString());
            Toolbar toolbar = fragment.toolBar;

            Menu menu = toolbar.getMenu();
            menu.clear();
            String title = rightBarButtonItem.getString("title");
            MenuItem menuItem = menu.add(title);
            menuItem.setShowAsActionFlags(MenuItem.SHOW_AS_ACTION_IF_ROOM);

            boolean enabled = rightBarButtonItem.getBoolean("enabled", true);
            menuItem.setEnabled(enabled);

            Bundle icon = rightBarButtonItem.getBundle("icon");
            if (icon != null) {
                String uri = icon.getString("uri");
                if (uri != null) {
                    Drawable drawable = createDrawable(icon);
                    menuItem.setIcon(drawable);
                }
            } else if(title != null){
                TextDrawable textDrawable = new TextDrawable(fragment.getContext());
                textDrawable.setTextColor(Garden.getBarButtonItemTintColor());
                textDrawable.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Garden.getBarButtonItemTextSizeDp());
                textDrawable.setText(title);
                menuItem.setIcon(textDrawable);
            }

            final String action = rightBarButtonItem.getString("action");
            if (action != null) {
                menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem menuItem) {
                        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
                        Bundle bundle = new Bundle();
                        bundle.putString("action", action);
                        bundle.putString(PROPS_NAV_ID, fragment.navigator.navId);
                        bundle.putString(PROPS_SCENE_ID, fragment.navigator.sceneId);
                        bridgeManager.sendEvent(Navigator.ON_BAR_BUTTON_ITEM_CLICK_EVENT, Arguments.fromBundle(bundle));
                        return true;
                    }
                });
            }
        }
    }

    // {"__packager_asset":true,
    // "width":24,
    // "height":24,
    // "uri":"http://10.0.2.2:8081/assets/playground/src/ic_settings@3x.png?platform=android&hash=d12cb52d785444661bacffba8115fdda",
    // "scale":3}
    public static Drawable createDrawable(Bundle icon) {
        String uri = icon.getString("uri");
        Drawable drawable = null;
        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        Context context =  bridgeManager.getReactInstanceManager().getCurrentReactContext().getApplicationContext();

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
            String glyph = fragments.get(0);
            Integer fontSize = Integer.valueOf(fragments.get(1));
            Log.w(TAG, "fontFamily: " + u.getHost() + " glyph:" + glyph + " fontSize:" + fontSize);
            drawable = getImageForFont(fontFamily, glyph, fontSize, Color.WHITE );
        } else {
            int resId = getResourceDrawableId(context, uri);
            drawable =  resId > 0 ? context.getResources().getDrawable(resId) : null;
        }

        if (drawable != null) {
            drawable.setColorFilter(Garden.getBarButtonItemTintColor(), PorterDuff.Mode.SRC_ATOP);
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

    public static Drawable getImageForFont(String fontFamily, String glyph, Integer fontSize, Integer color) {
        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        Context context =  bridgeManager.getReactInstanceManager().getCurrentReactContext().getApplicationContext();
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

}
