#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_PACKAGE="${APP_PACKAGE:-com.reactnative.hybridnavigation.example}"
ANDROID_SERIAL="${ANDROID_SERIAL:-}"
FORCE_ANDROID_BUILD="${FORCE_ANDROID_BUILD:-0}"
SESSION="${AD_SESSION:-rotation-android-regression}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/rotation/artifacts/rotation-android-regression}"

mkdir -p "$ARTIFACT_DIR"

if [[ -x "./node_modules/.bin/agent-device" ]]; then
	AGENT_DEVICE_BIN="./node_modules/.bin/agent-device"
else
	AGENT_DEVICE_BIN="npx agent-device"
fi

run() {
	echo ">> $*"
	"$@"
}

extract_conflicting_session() {
	local output="$1"
	if [[ "$output" =~ session[[:space:]]+\"([^\"]+)\" ]]; then
		printf '%s\n' "${BASH_REMATCH[1]}"
	fi
}

close_conflicting_session() {
	local conflicting_session="$1"
	if [[ -z "$conflicting_session" || "$conflicting_session" == "$SESSION" ]]; then
		return 1
	fi
	echo "Closing conflicting session: $conflicting_session"
	$AGENT_DEVICE_BIN --session "$conflicting_session" close >/dev/null
}

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

	echo ">> ad open $APP_PACKAGE"
	if open_output="$(ad open "$APP_PACKAGE" 2>&1)"; then
		echo "$open_output"
		return 0
	fi

	echo "$open_output" >&2
	if grep -Fq "DEVICE_IN_USE" <<<"$open_output"; then
		conflicting_session="$(extract_conflicting_session "$open_output")"
		if close_conflicting_session "$conflicting_session"; then
			run ad open "$APP_PACKAGE"
			return 0
		fi
		echo "Unable to recover from conflicting device session." >&2
		return 1
	fi

	echo "Unable to open $APP_PACKAGE. Trying yarn android to install/rebuild..."
	run yarn android
	run ad open "$APP_PACKAGE"
}

snapshot_has() {
	local expected="$1"
	ad snapshot | grep -Fq "$expected"
}

wait_has() {
	local expected="$1"
	local retries="${2:-10}"
	local i
	for ((i = 1; i <= retries; i++)); do
		if snapshot_has "$expected"; then
			return 0
		fi
		ad wait 1 >/dev/null
	done
	echo "Expected text not found in snapshot: $expected" >&2
	return 1
}

tap_text() {
	local text="$1"
	local retries="${2:-6}"
	local i
	for ((i = 1; i <= retries; i++)); do
		if ad find "$text" click --first >/dev/null 2>&1; then
			return 0
		fi
		ad wait 1 >/dev/null
	done
	echo "Unable to tap text: $text" >&2
	return 1
}

normalize_navigation_root() {
	local normalized=false
	for _ in 1 2 3 4 5 6 7 8; do
		if snapshot_has "push" && snapshot_has "switch to tab 'Options'"; then
			normalized=true
			break
		fi

		if snapshot_has "Cancel"; then
			tap_text "Cancel" || run ad back
			run ad wait 1
			continue
		fi

		if snapshot_has "switch to tab 'Navigation'"; then
			tap_text "switch to tab" || true
			run ad wait 1
			continue
		fi

		if snapshot_has "Back"; then
			tap_text "Back" || run ad back
			run ad wait 1
			continue
		fi

		run ad back
		run ad wait 1
	done

	if [[ "$normalized" != true ]]; then
		echo "Unable to normalize to Navigation root page." >&2
		exit 1
	fi
}

echo "== Android Rotation Regression Test =="
echo "App: $APP_PACKAGE | Serial: ${ANDROID_SERIAL:-auto} | Session: $SESSION"

ensure_android_target
run ad boot
ensure_android_app_ready
normalize_navigation_root

# Case 1: push stack + rotate + popToRoot should recover to root navigation page.
run ad find "push" click --first
run ad wait 1
run ad find "push" click --first
run ad wait 1
run ad rotate landscape-left
run ad wait 1
run ad rotate portrait
run ad wait 1
run ad find "popToRoot" click --first
run ad wait 1
wait_has "switch to tab 'Options'"
run ad screenshot "$ARTIFACT_DIR/case1-popToRoot.png"

# Case 2: switch tab -> forced landscape page -> rotate both directions.
run ad find "switch to tab" click --first
run ad wait 1
wait_has "Landscape"
run ad find "Landscape" click --first
run ad wait 1
wait_has "showModal"
run ad rotate landscape-left
run ad wait 1
wait_has "Back"
run ad rotate landscape-right
run ad wait 1
wait_has "Back"
run ad screenshot "$ARTIFACT_DIR/case2-landscape-rotations.png"

# Case 3: show modal in landscape, dismiss, and ensure return path still works.
run ad find "showModal" click --first
run ad wait 1
wait_has "Male"
wait_has "Cancel"
run ad rotate landscape-left
run ad wait 1
wait_has "Cancel"
if ! tap_text "Cancel"; then
	run ad back
fi
run ad wait 1
wait_has "showModal"
run ad rotate portrait
run ad wait 1
run ad find "Back" click --first
run ad wait 1
wait_has "switch to tab 'Navigation'"
run ad find "switch to tab" click --first
run ad wait 1
wait_has "push"
run ad screenshot "$ARTIFACT_DIR/case3-modal-return-path.png"

echo "PASS: Android rotation regression test completed."
echo "Artifacts: $ARTIFACT_DIR"
