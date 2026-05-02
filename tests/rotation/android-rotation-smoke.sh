#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_PACKAGE="${APP_PACKAGE:-com.reactnative.hybridnavigation.example}"
ANDROID_SERIAL="${ANDROID_SERIAL:-}"
FORCE_ANDROID_BUILD="${FORCE_ANDROID_BUILD:-0}"
SESSION="${AD_SESSION:-rotation-android}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/rotation/artifacts/rotation-android}"

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

wait_visible() {
	local expected="$1"
	local retries="${2:-8}"
	local i
	for ((i = 1; i <= retries; i++)); do
		if ad snapshot | grep -Fq "$expected"; then
			return 0
		fi
		ad wait 1 >/dev/null
	done
	echo "Expected text not found in snapshot: $expected" >&2
	return 1
}

echo "== Android Screen Rotation Smoke Test =="
echo "App: $APP_PACKAGE | Serial: ${ANDROID_SERIAL:-auto} | Session: $SESSION"

ensure_android_target
run ad boot
ensure_android_app_ready
wait_visible "push"

# Rotate to landscape and verify navigation controls still respond.
run ad rotate landscape-left
run ad wait 1
wait_visible "push"
run ad screenshot "$ARTIFACT_DIR/landscape-left.png"

run ad find 'push' click --first
run ad wait 1
wait_visible "pop"

# Rotate back to portrait and ensure we can still return.
run ad rotate portrait
run ad wait 1
wait_visible "pop"
run ad find 'pop' click --first
run ad wait 1
wait_visible "push"
run ad screenshot "$ARTIFACT_DIR/portrait-after-pop.png"

echo "PASS: Android rotation smoke test completed."
echo "Artifacts: $ARTIFACT_DIR"
