#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

APP_PACKAGE="${APP_PACKAGE:-com.reactnative.hybridnavigation.example}"
ANDROID_SERIAL="${ANDROID_SERIAL:-}"
FORCE_ANDROID_BUILD="${FORCE_ANDROID_BUILD:-0}"
ANDROID_PROACTIVE_RELOAD="${ANDROID_PROACTIVE_RELOAD:-1}"
ANDROID_DRAWER_SWIPE="${ANDROID_DRAWER_SWIPE:-5 1000 900 1000 800}"
SESSION="${AD_SESSION:-navigation-android-drawer}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/navigation/artifacts/navigation-android-drawer}"

mkdir -p "$ARTIFACT_DIR"
trap close_current_session EXIT

ad() {
	if [[ -n "$ANDROID_SERIAL" ]]; then
		$AGENT_DEVICE_BIN "$@" --platform android --serial "$ANDROID_SERIAL" --session "$SESSION" --session-lock strip
	else
		$AGENT_DEVICE_BIN "$@" --platform android --session "$SESSION" --session-lock strip
	fi
}

has_android_target() {
	local output
	output="$($AGENT_DEVICE_BIN devices --platform android 2>/dev/null || true)"
	[[ -n "${output//[[:space:]]/}" ]]
}

ensure_android_target() {
	if [[ "$FORCE_ANDROID_BUILD" == "1" ]]; then
		echo "FORCE_ANDROID_BUILD=1; running yarn android before test..."
		run yarn android
	elif [[ -n "$ANDROID_SERIAL" ]]; then
		echo "Using ANDROID_SERIAL=$ANDROID_SERIAL; skipping yarn android."
		return 0
	elif has_android_target; then
		echo "Android target detected; skipping yarn android."
		return 0
	else
		echo "No Android device detected. Trying to build and run app via yarn android..."
		run yarn android
	fi

	local i
	for ((i = 1; i <= 20; i++)); do
		if has_android_target; then
			return 0
		fi
		sleep 2
	done

	echo "No Android device became available after running yarn android." >&2
	return 1
}

ensure_android_app_ready() {
	local open_output conflicting_session
	local open_args=(open "$APP_PACKAGE")
	if [[ "$ANDROID_PROACTIVE_RELOAD" == "1" ]]; then
		open_args+=(--relaunch)
	fi

	echo ">> ad ${open_args[*]}"
	if open_output="$(ad "${open_args[@]}" 2>&1)"; then
		echo "$open_output"
		return 0
	fi

	echo "$open_output" >&2
	if grep -Fq "DEVICE_IN_USE" <<<"$open_output"; then
		conflicting_session="$(extract_conflicting_session "$open_output")"
		if close_conflicting_session "$conflicting_session"; then
			run ad "${open_args[@]}"
			return 0
		fi
		echo "Unable to recover from conflicting device session." >&2
		return 1
	fi

	echo "Unable to open $APP_PACKAGE. Trying yarn android to install/rebuild..."
	run yarn android
	run ad "${open_args[@]}"
}

echo "== Android Drawer Navigation Regression Test =="
echo "App: $APP_PACKAGE | Serial: ${ANDROID_SERIAL:-auto} | Session: $SESSION"
echo "Layout: $(get_demo_root_layout)"

ensure_android_target
run ad boot
ensure_android_app_ready
normalize_navigation_root
run ad screenshot "$ARTIFACT_DIR/root.png"

# Regression: after pushing a page, one system back gesture must pop the page,
# and must not leave the drawer opened as a side effect.
tap_text "Push scene"
run ad wait 1
wait_has "Back"
run ad screenshot "$ARTIFACT_DIR/pushed.png"

run ad back --system
run ad wait 1
wait_has "Push scene"
wait_absent "Back"
assert_absent "New thread"
run ad screenshot "$ARTIFACT_DIR/after-system-back.png"

# Regression: after returning to the root page, the drawer gesture must still work
# without requiring the menu button to be tapped first.
# shellcheck disable=SC2086
run ad swipe $ANDROID_DRAWER_SWIPE
run ad wait 1
wait_has "New thread"
run ad screenshot "$ARTIFACT_DIR/drawer-after-return-swipe.png"

tap_text "New thread"
run ad wait 1
wait_absent "New thread"
wait_has "Push scene"

# Keep the explicit menu button path covered too; it exercises toggleMenu in the
# same root state where the gesture was just enabled.
tap_text "Menu"
run ad wait 1
wait_has "New thread"
tap_text "New thread"
run ad wait 1
wait_absent "New thread"
run ad screenshot "$ARTIFACT_DIR/after-menu-button-close.png"

echo "PASS: Android drawer navigation regression test completed."
echo "Artifacts: $ARTIFACT_DIR"
