package com.navigationhybrid;


public interface ReactRootViewHolder {

    interface VisibilityObserver {
        void inspectVisibility(int visibility);
        boolean isOptimizationEnabled();
    }

    void setVisibilityObserver(VisibilityObserver observer);

}
