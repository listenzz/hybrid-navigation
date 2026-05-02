# Screen Rotation Tests

This folder contains executable smoke tests for screen rotation using `agent-device`.

## iOS

Command:

```bash
yarn test:rotate:ios
yarn test:rotate:ios:regression
```

What it verifies:

1. Opens the app and navigates to the `Options` tab.
2. Enters the `Landscape` page (forced landscape scene).
3. Rotates `landscape-left` and `landscape-right`.
4. Verifies the page remains interactive (`Back` is visible).
5. Returns to portrait and confirms the app flow recovers (`Landscape` button visible again).
6. If app opens successfully, script skips `yarn ios`.
7. If app cannot be opened (for example not installed), script will try `yarn ios` and continue.
8. Optional proactive reload can relaunch app before test when Fast Refresh is stale.
9. If simulator is locked by another `agent-device` session (`DEVICE_IN_USE`), script fails fast instead of rebuilding.

`test:rotate:ios:regression` additionally verifies:

1. `push -> push -> rotate -> popToRoot` still returns to root.
2. `Options -> Landscape` forced-landscape page remains usable across left/right rotations.
3. `Landscape -> showModal -> Cancel -> Back` return path stays stable after rotations.

Optional env vars:

- `IOS_DEVICE` (default: `iPhone 17 Pro`)
- `APP_BUNDLE` (default: `tech.todoit.navigation`)
- `FORCE_IOS_BUILD` (default: `0`; set `1` when native iOS code changed and rebuild is required)
- `IOS_PROACTIVE_RELOAD` (default: `0`; set `1` to close/open app before test when RN Fast Refresh is not enough)
- `AD_SESSION` (default: `rotation-ios`)
- `ARTIFACT_DIR` (default: `<project>/tests/rotation/artifacts/rotation-ios`)

## Android

Command:

```bash
yarn test:rotate:android
yarn test:rotate:android:regression
```

What it verifies:

1. Opens the app.
2. Rotates to landscape and confirms controls are still visible.
3. Executes `push`, rotates back to portrait, executes `pop`.
4. Confirms navigation remains usable after rotation.
5. If an Android target already exists, script skips `yarn android`.
6. If no Android target is detected, script will try `yarn android` first, then continue.

`test:rotate:android:regression` additionally verifies:

1. `push -> push -> rotate -> popToRoot` still returns to root.
2. `Options -> Landscape` forced-landscape page remains usable across left/right rotations.
3. `Landscape -> showModal -> Cancel -> Back` return path stays stable after rotations.
4. If an Android target already exists, script skips `yarn android`.
5. If no Android target is detected, script will try `yarn android` first, then continue.

Optional env vars:

- `ANDROID_SERIAL` (default: auto-selected by `agent-device`)
- `APP_PACKAGE` (default: `com.reactnative.hybridnavigation.example`)
- `FORCE_ANDROID_BUILD` (default: `0`; set `1` when native Android code changed and rebuild is required)
- `AD_SESSION` (default: `rotation-android`)
- `ARTIFACT_DIR` (default: `<project>/tests/rotation/artifacts/rotation-android`)
