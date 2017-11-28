package com.navigationhybrid;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.StrictMode;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.util.TypedValue;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.facebook.react.bridge.Arguments;
import com.navigationhybrid.view.TextDrawable;

import java.net.URL;

import javax.annotation.Nullable;

import static com.navigationhybrid.NavigationFragment.PROPS_NAV_ID;
import static com.navigationhybrid.NavigationFragment.PROPS_SCENE_ID;

/**
 * Created by Listen on 2017/11/22.
 */

public class Garden {

    private static final String TAG = "ReactNative";

    public static class Global {

        public static int titleTextColor = Color.WHITE;
        public static int titleTextSize = 18;
        public static int barButtonItemTintColor = Color.WHITE;
        public static int barButtonItemTextSize = 14;
        public static String titleAlignment = "left"; // left, center, default is left

        public static int tabBarItemColor = Color.parseColor("#c9c9c9");
        public static int tabBarItemSelectedColor = Color.parseColor("#F44336");
        public static int tabBarItemFontSize;
        public static int tabBarItemBubbleColor = Color.parseColor("#FF4040");
        public static int tabBarItemBubbleBorderColor = Color.WHITE;
    }

    public static void setTitleTextColor(int color) {
        Global.titleTextColor = color;
    }

    public static void setTitleTextSize(int dp) {
        Global.titleTextSize = dp;
    }

    public static void setBarButtonItemTintColor(int color) {
        Global.barButtonItemTintColor = color;
    }

    public static void setBarButtonItemTextSize(int dp) {
        Global.barButtonItemTextSize = dp;
    }

    public static void setTitleAlignment(String alignment) {
        Global.titleAlignment = alignment;
    }

    private  final NavigationFragment fragment;

    Garden(@NonNull NavigationFragment fragment) {
        this.fragment = fragment;
    }

    public void setTitle(String title) {
        if (fragment.getView() == null) return;
        TextView titleView = fragment.topBar.getCenterTitleView();
        if (Global.titleAlignment.equals("center")) { // default is 'left'
            fragment.topBar.setTitleViewAlignment("center");
        }
        titleView.setTextColor(Global.titleTextColor);
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Global.titleTextSize);
        titleView.setText(title);
        titleView.getPaint().setFakeBoldText(true); // 粗体
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
        Log.d(TAG, leftBarButtonItem.toString());

        Bundle icon = leftBarButtonItem.getBundle("icon");
        String title = leftBarButtonItem.getString("title");
        if (icon != null) {
            String uri = icon.getString("uri");
            if (uri != null) {
                Drawable drawable = createDrawable(icon);
                fragment.topBar.getToolbar().setNavigationIcon(drawable);
            }
        } else if (title != null) {
            TextDrawable textDrawable = new TextDrawable(fragment.getContext());
            textDrawable.setTextColor(Global.barButtonItemTintColor);
            textDrawable.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Global.barButtonItemTextSize);
            textDrawable.setText(title);
            fragment.topBar.getToolbar().setNavigationIcon(textDrawable);
        }

        final String action = leftBarButtonItem.getString("action");
        if (action != null) {
            fragment.topBar.getToolbar().setNavigationOnClickListener(new View.OnClickListener() {
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
            Toolbar toolbar = fragment.topBar.getToolbar();
            String title = rightBarButtonItem.getString("title");
            MenuItem menuItem = toolbar.getMenu().add(title);
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
                textDrawable.setTextColor(Global.barButtonItemTintColor);
                textDrawable.setTextSize(TypedValue.COMPLEX_UNIT_DIP, Global.barButtonItemTextSize);
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
    public Drawable createDrawable(Bundle icon) {
        String uri = icon.getString("uri");
        Drawable drawable = null;
        ReactBridgeManager bridgeManager = ReactBridgeManager.instance;
        Context context =  bridgeManager.getReactInstanceManager().getCurrentReactContext();

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
        } else {
            int resId = getResourceDrawableId(context, uri);
            drawable =  resId > 0 ? context.getResources().getDrawable(resId) : null;
        }

        if (drawable != null) {
            drawable.setColorFilter(Color.WHITE, PorterDuff.Mode.SRC_ATOP);
        }

        return drawable;
    }

    public int getResourceDrawableId(Context context, @Nullable String name) {
        if (name == null || name.isEmpty()) {
            return 0;
        }
        int id = context.getResources().getIdentifier(
                name,
                "drawable",
                context.getPackageName());
        return id;
    }

}
