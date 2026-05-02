# Hybrid Navigation Agent Guide

This project is preconfigured with three Callstack skills:

- `$agent-device`: Device/simulator automation for iOS and Android.
- `$react-native-best-practices`: React Native performance and optimization playbook.
- `$react-devtools`: Runtime inspection/profiling via `agent-react-devtools`.

`agent-device` requires Node.js `>=22`.

## Runtime Debugging Workflow

1. Start Metro:
   - `yarn start`
2. Start Agent React DevTools daemon:
   - `yarn devtools:start`
3. Check DevTools connection status:
   - `yarn devtools:status`
4. Inspect/profiling examples:
   - `npx agent-react-devtools get tree --depth 3`
   - `npx agent-react-devtools find <ComponentName>`
   - `npx agent-react-devtools profile start`
   - `npx agent-react-devtools profile stop`
   - `npx agent-react-devtools profile slow --limit 10`

## Combined Flow: agent-device + react-devtools

Use `agent-device` to reproduce user flows and `agent-react-devtools` to inspect internal React state/perf in the same run.

1. Boot or select device:
   - `yarn device:boot:ios` or `yarn device:boot:android`
2. Discover app id:
   - `yarn device:apps:ios` or `yarn device:apps:android`
3. Open app and reproduce:
   - `npx agent-device open <AppNameOrBundleId> --platform ios`
   - `npx agent-device snapshot -i`
   - `npx agent-device click @eN`
4. Profile around the same interaction:
   - `npx agent-react-devtools profile start`
   - (repeat interaction with `agent-device`)
   - `npx agent-react-devtools profile stop`
   - `npx agent-react-devtools profile slow --limit 10`
5. Drill down component internals:
   - `npx agent-react-devtools get tree --depth 4`
   - `npx agent-react-devtools get component @cN`

For Android physical devices, run:

- `adb reverse tcp:8097 tcp:8097`

## Mobile Build/Reload Policy (Debug/Automation)

When running iOS/Android debug or automation tasks:

- If a target is already available and the app can open, do **not** run `yarn ios`/`yarn android`.
- For React Native JS/TS changes, rely on Fast Refresh first.
- If Fast Refresh is stale, reload by relaunching the app (`close` then `open`) before attempting a rebuild.
- Run `yarn ios`/`yarn android` only when the app cannot be opened/installed, when no usable target exists, or after native iOS/Android code changes that require rebuild/reinstall.
- If automation fails with session/device lock conflicts (for example `DEVICE_IN_USE`), resolve the conflict first instead of rebuilding by default.

## Skill Restore

Project skills are tracked in `skills-lock.json`.
If skills are missing, run:

- `yarn skills:restore`
