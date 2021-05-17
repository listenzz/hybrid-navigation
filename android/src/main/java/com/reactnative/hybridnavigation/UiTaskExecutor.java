package com.reactnative.hybridnavigation;

import com.facebook.react.bridge.UiThreadUtil;

import java.util.LinkedList;
import java.util.Queue;

public class UiTaskExecutor {

    private Queue<Runnable> tasks = new LinkedList<>();

    public void submit(Runnable task) {
        UiThreadUtil.assertOnUiThread();
        tasks.add(task);
        considerExecute();
    }

    public void clear() {
        tasks.clear();
    }

    private boolean resumed;

    public void notifyResume() {
        resumed = true;
        considerExecute();
    }

    public void notifyPause() {
        resumed = false;
    }

    private boolean executing;

    private void considerExecute() {
        if (!executing && resumed) {
            executing = true;
            Runnable runnable = tasks.poll();
            while (runnable != null && resumed) {
                runnable.run();
                runnable = tasks.poll();
            }
            executing = false;
        }
    }

}
