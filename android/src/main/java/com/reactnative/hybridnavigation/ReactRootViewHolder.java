package com.reactnative.hybridnavigation;

public interface ReactRootViewHolder {

    interface VisibilityObserver {
        void inspectVisibility(int visibility);
    }

    void setVisibilityObserver(VisibilityObserver observer);

}
