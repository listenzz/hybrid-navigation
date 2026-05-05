# Navigation Drawer Regression Tests

This folder contains device-level regression tests for the demo drawer, stack, and tab nesting.

These tests use `agent-device` because the target regressions depend on native containers and system gestures. Run Metro separately before the tests when using a debug build:

```bash
yarn start
```

## Commands

Current demo layout only:

```bash
yarn test:navigation:android
yarn test:navigation:ios
```

Both root layouts:

```bash
yarn test:navigation:android:layouts
yarn test:navigation:ios:layouts
yarn test:navigation:layouts
```

The layout matrix temporarily switches `src/index.ts` between:

- `stack-drawer-tabs`
- `drawer-stack-tabs`

It restores the original layout when the script exits.

## What Is Covered

Android:

1. Opens the app and normalizes to the Navigation root.
2. Pushes another Navigation scene.
3. Uses the Android system back gesture/button once.
4. Verifies the pushed page is popped and the drawer is not opened as a side effect.
5. Swipes from the left edge to confirm the drawer can still open after returning.
6. Checks the explicit Menu button path.

iOS:

1. Opens the app and normalizes to the Navigation root.
2. Pushes another Navigation scene.
3. Returns to root using the Back button by default.
4. Verifies the drawer is not opened as a side effect.
5. Checks the explicit Menu button path.

Set `IOS_BACK_ACTION=swipe` to use an edge-swipe pop instead of the Back button.

## Optional Env Vars

- `ANDROID_SERIAL` (default: auto-selected by `agent-device`)
- `APP_PACKAGE` (default: `com.reactnative.hybridnavigation.example`)
- `FORCE_ANDROID_BUILD` (default: `0`; set `1` after native Android changes)
- `ANDROID_PROACTIVE_RELOAD` (default: `1`)
- `ANDROID_DRAWER_SWIPE` (default: `5 1000 900 1000 800`)
- `IOS_DEVICE` (default: auto-selected by `agent-device`)
- `APP_BUNDLE` (default: `tech.todoit.navigation`)
- `FORCE_IOS_BUILD` (default: `0`; set `1` after native iOS changes)
- `IOS_PROACTIVE_RELOAD` (default: `1`)
- `IOS_BACK_ACTION` (default: `button`; use `swipe` for interactive pop)
- `AD_SESSION` (default: per script/layout)
- `ARTIFACT_DIR` (default: `tests/navigation/artifacts/...`)
- `KEEP_AD_SESSION` (default: `0`; set `1` to leave the device session open for debugging)
- `PLATFORM` for `root-layout-regression.sh` (default: `all`; use `android` or `ios`)
- `LAYOUTS` for `root-layout-regression.sh` (default: `stack-drawer-tabs drawer-stack-tabs`)
