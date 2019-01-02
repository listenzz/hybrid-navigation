package com.navigationhybrid;


public interface ReactRootViewHolder {

    interface VisibilityObserver {
        void inspectVisibility(int visibility);
    }

    void setVisibilityObserver(VisibilityObserver observer);

}
