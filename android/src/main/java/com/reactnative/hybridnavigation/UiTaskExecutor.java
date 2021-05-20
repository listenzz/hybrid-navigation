package com.reactnative.hybridnavigation;

import android.os.Handler;
import android.os.Looper;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.OnLifecycleEvent;

import java.util.LinkedList;
import java.util.Queue;

public class UiTaskExecutor implements LifecycleObserver {

    private final Queue<Runnable> tasks = new LinkedList<>();

    private final LifecycleOwner lifecycleOwner;
    private final Handler handler;

    public UiTaskExecutor(LifecycleOwner lifecycleOwner, Handler handler) {
        this.lifecycleOwner = lifecycleOwner;
        this.handler = handler;
        getLifecycle().addObserver(this);
    }

    public void submit(Runnable task) {
        if (getLifecycle().getCurrentState() != Lifecycle.State.DESTROYED) {
            handler.post(() -> {
                tasks.add(task);
                considerExecute();
            });
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_ANY)
    void onStateChange() {
        if (getLifecycle().getCurrentState() == Lifecycle.State.DESTROYED) {
            getLifecycle().removeObserver(this);
            handler.removeCallbacks(executeTask);
        } else {
            handler.post(executeTask);
        }
    }

    private boolean executing;

    void considerExecute() {
        if (isAtLeastStarted() && !executing) {
            assertMainThread();
            executing = true;
            Runnable runnable = tasks.poll();
            while (runnable != null) {
                runnable.run();
                runnable = tasks.poll();
            }
            executing = false;
        }
    }

    private final Runnable executeTask = this::considerExecute;

    boolean isAtLeastStarted() {
        return getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED);
    }

    private Lifecycle getLifecycle() {
        return lifecycleOwner.getLifecycle();
    }

    private void assertMainThread() {
        if (!isMainThread()) {
            throw new IllegalStateException("You should perform the task at main thread.");
        }
    }

    static boolean isMainThread() {
        return Looper.getMainLooper().getThread() == Thread.currentThread();
    }

}
