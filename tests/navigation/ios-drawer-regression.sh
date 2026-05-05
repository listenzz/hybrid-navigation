#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

APP_BUNDLE="${APP_BUNDLE:-tech.todoit.navigation}"
IOS_DEVICE="${IOS_DEVICE:-}"
FORCE_IOS_BUILD="${FORCE_IOS_BUILD:-0}"
IOS_PROACTIVE_RELOAD="${IOS_PROACTIVE_RELOAD:-1}"
IOS_BACK_ACTION="${IOS_BACK_ACTION:-button}"
IOS_BACK_SWIPE="${IOS_BACK_SWIPE:-5 420 360 420 700}"
SESSION="${AD_SESSION:-navigation-ios-drawer}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/navigation/artifacts/navigation-ios-drawer}"

mkdir -p "$ARTIFACT_DIR"
trap close_current_session EXIT

ad() {
	if [[ -n "$IOS_DEVICE" ]]; then
		$AGENT_DEVICE_BIN "$@" --platform ios --device "$IOS_DEVICE" --session "$SESSION" --session-lock strip
	else
		$AGENT_DEVICE_BIN "$@" --platform ios --session "$SESSION" --session-lock strip
	fi
}

ensure_ios_app_ready() {
	local open_output conflicting_session
	local open_args=(open "$APP_BUNDLE")

	if [[ "$FORCE_IOS_BUILD" == "1" ]]; then
		echo "FORCE_IOS_BUILD=1; running yarn ios before test..."
		if [[ -n "$IOS_DEVICE" ]]; then
			run yarn ios --simulator "$IOS_DEVICE"
		else
			run yarn ios
		fi
	fi

	if [[ "$IOS_PROACTIVE_RELOAD" == "1" ]]; then
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

	echo "Unable to open $APP_BUNDLE. Trying yarn ios to install/rebuild..."
	if [[ -n "$IOS_DEVICE" ]]; then
		run yarn ios --simulator "$IOS_DEVICE"
	else
		run yarn ios
	fi
	run ad "${open_args[@]}"
}

pop_pushed_page() {
	if [[ "$IOS_BACK_ACTION" == "swipe" ]]; then
		# shellcheck disable=SC2086
		run ad swipe $IOS_BACK_SWIPE
	else
		tap_text "Back"
	fi
}

echo "== iOS Drawer Navigation Regression Test =="
echo "App: $APP_BUNDLE | Device: ${IOS_DEVICE:-auto} | Session: $SESSION"
echo "Layout: $(get_demo_root_layout)"

run ad boot
ensure_ios_app_ready
normalize_navigation_root
run ad screenshot "$ARTIFACT_DIR/root.png"

tap_text "Push scene"
run ad wait 1
wait_has "Back"
run ad screenshot "$ARTIFACT_DIR/pushed.png"

pop_pushed_page
run ad wait 1
wait_has "Push scene"
wait_absent "Back"
assert_absent "New thread"
run ad screenshot "$ARTIFACT_DIR/after-back.png"

tap_text "Menu"
run ad wait 1
wait_has "New thread"
run ad screenshot "$ARTIFACT_DIR/drawer-after-back.png"

tap_text "New thread"
run ad wait 1
wait_absent "New thread"
wait_has "Push scene"
run ad screenshot "$ARTIFACT_DIR/after-menu-close.png"

echo "PASS: iOS drawer navigation regression test completed."
echo "Artifacts: $ARTIFACT_DIR"
