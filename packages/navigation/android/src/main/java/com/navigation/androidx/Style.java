package com.navigation.androidx;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;

import androidx.annotation.ColorInt;
import androidx.annotation.IntRange;
import androidx.annotation.NonNull;

public class Style implements Cloneable {

    public static int INVALID_COLOR = Integer.MAX_VALUE;
    private static final Drawable defaultShadow = new ColorDrawable(Color.parseColor("#F0F0F0"));

    private int screenBackgroundColor = Color.WHITE;

    private BarStyle statusBarStyle = BarStyle.DarkContent;
    private boolean statusBarHidden = false;

    private int navigationBarColor = INVALID_COLOR;
    private boolean navigationBarHidden = false;

    private String tabBarBackgroundColor = "#FFFFFF";
    private String tabBarItemColor = null;
    private String tabBarUnselectedItemColor = null;
    private Drawable tabBarShadow = defaultShadow;

    private boolean swipeBackEnabled;
    private String tabBarBadgeColor = "#FF3B30";

    private int scrimAlpha = 25;

    private boolean displayCutoutWhenLandscape = true;

    private boolean fitsOpaqueNavigationBar = true;

    protected Style(Context context) {
    }

    public boolean isDisplayCutoutWhenLandscape() {
        return displayCutoutWhenLandscape;
    }

    public void setDisplayCutoutWhenLandscape(boolean displayCutoutWhenLandscape) {
        this.displayCutoutWhenLandscape = displayCutoutWhenLandscape;
    }

    public void setScreenBackgroundColor(int color) {
        screenBackgroundColor = color;
    }

    public int getScreenBackgroundColor() {
        return screenBackgroundColor;
    }

    public void setTabBarBackgroundColor(String tabBarBackgroundColor) {
        this.tabBarBackgroundColor = tabBarBackgroundColor;
    }

    public String getTabBarBackgroundColor() {
        return tabBarBackgroundColor;
    }

    public void setTabBarItemColor(String tabBarItemColor) {
        this.tabBarItemColor = tabBarItemColor;
    }

    public String getTabBarItemColor() {
        return tabBarItemColor;
    }

    public String getTabBarUnselectedItemColor() {
        return tabBarUnselectedItemColor;
    }

    public void setTabBarUnselectedItemColor(String tabBarUnselectedItemColor) {
        this.tabBarUnselectedItemColor = tabBarUnselectedItemColor;
    }

    public void setStatusBarStyle(BarStyle barStyle) {
        statusBarStyle = barStyle;
    }

    public BarStyle getStatusBarStyle() {
        return statusBarStyle;
    }

    public boolean isStatusBarHidden() {
        return statusBarHidden;
    }

    public void setStatusBarHidden(boolean statusBarHidden) {
        this.statusBarHidden = statusBarHidden;
    }

    public Drawable getTabBarShadow() {
        return tabBarShadow;
    }

    public void setTabBarShadow(Drawable drawable) {
        this.tabBarShadow = drawable;
    }

    public boolean isSwipeBackEnabled() {
        return swipeBackEnabled;
    }

    public void setSwipeBackEnabled(boolean swipeBackEnabled) {
        this.swipeBackEnabled = swipeBackEnabled;
    }

    public String getTabBarBadgeColor() {
        return tabBarBadgeColor;
    }

    public void setTabBarBadgeColor(String badgeColor) {
        this.tabBarBadgeColor = badgeColor;
    }

    @ColorInt
    public int getNavigationBarColor() {
        return navigationBarColor;
    }

    public void setNavigationBarColor(@ColorInt int color) {
        this.navigationBarColor = color;
    }

    public boolean isNavigationBarHidden() {
        return navigationBarHidden;
    }

    public void setNavigationBarHidden(boolean hidden) {
        this.navigationBarHidden = hidden;
    }

    public boolean shouldFitsOpaqueNavigationBar() {
        return fitsOpaqueNavigationBar;
    }

    public void setFitsOpaqueNavigationBar(boolean fitsOpaqueNavigationBar) {
        this.fitsOpaqueNavigationBar = fitsOpaqueNavigationBar;
    }

    public void setScrimAlpha(@IntRange(from = 0, to = 255) int scrimAlpha) {
        this.scrimAlpha = scrimAlpha;
    }

    public int getScrimAlpha() {
        return scrimAlpha;
    }

    @NonNull
    @Override
    public Style clone() throws CloneNotSupportedException {
        return (Style) super.clone();
    }
}
