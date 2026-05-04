package com.reactnative.hybridnavigation;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.interfaces.TaskInterface;
import com.facebook.react.interfaces.fabric.ReactSurface;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

final class ReactSurfaceCleanup {

	private static final Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());
	private static final ExecutorService EXECUTOR = Executors.newSingleThreadExecutor(runnable -> {
		Thread thread = new Thread(runnable, "ReactSurfaceCleanup");
		thread.setDaemon(true);
		return thread;
	});

	private ReactSurfaceCleanup() {
	}

	static void stopThenRun(
		@NonNull ReactSurface surface,
		@Nullable TaskInterface<Void> startTask,
		@NonNull Runnable completion
	) {
		EXECUTOR.execute(() -> {
			// RN 0.84/0.85 can ignore stopSurface if it runs before startSurface marks the surface running.
			waitForTask(startTask);
			try {
				waitForTask(surface.stop());
			} catch (RuntimeException ignored) {
			}
			MAIN_HANDLER.post(completion);
		});
	}

	private static void waitForTask(@Nullable TaskInterface<Void> task) {
		if (task == null) {
			return;
		}

		try {
			task.waitForCompletion();
		} catch (InterruptedException ignored) {
			Thread.currentThread().interrupt();
		}
	}
}
