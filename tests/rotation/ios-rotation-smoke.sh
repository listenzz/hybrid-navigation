#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_BUNDLE="${APP_BUNDLE:-tech.todoit.navigation}"
IOS_DEVICE="${IOS_DEVICE:-iPhone 17 Pro}"
FORCE_IOS_BUILD="${FORCE_IOS_BUILD:-0}"
IOS_PROACTIVE_RELOAD="${IOS_PROACTIVE_RELOAD:-0}"
SESSION="${AD_SESSION:-rotation-ios}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/rotation/artifacts/rotation-ios}"

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
	$AGENT_DEVICE_BIN "$@" --platform ios --device "$IOS_DEVICE" --session "$SESSION" --session-lock strip
}

ensure_ios_app_ready() {
	local open_output
	local conflicting_session

	if [[ "$FORCE_IOS_BUILD" == "1" ]]; then
		echo "FORCE_IOS_BUILD=1; running yarn ios before test..."
		run yarn ios --simulator "$IOS_DEVICE"
	fi

	echo ">> ad open $APP_BUNDLE"
	if open_output="$(ad open "$APP_BUNDLE" 2>&1)"; then
		echo "$open_output"
		echo "App opened successfully; skipping yarn ios."
		:
	else
		echo "$open_output" >&2
		if grep -Fq "DEVICE_IN_USE" <<<"$open_output"; then
			conflicting_session="$(extract_conflicting_session "$open_output")"
			if close_conflicting_session "$conflicting_session"; then
				run ad open "$APP_BUNDLE"
				return 0
			fi
			echo "Unable to recover from conflicting device session." >&2
			return 1
		fi
		echo "Unable to open $APP_BUNDLE. Trying yarn ios to install/rebuild..."
		run yarn ios --simulator "$IOS_DEVICE"
		run ad open "$APP_BUNDLE"
	fi

	if [[ "$IOS_PROACTIVE_RELOAD" == "1" ]]; then
		echo "IOS_PROACTIVE_RELOAD=1; relaunching app for proactive reload..."
		ad close "$APP_BUNDLE" >/dev/null 2>&1 || true
		run ad open "$APP_BUNDLE"
	fi
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

snapshot_has() {
	local expected="$1"
	ad snapshot | grep -Fq "$expected"
}

scroll_down_until_visible() {
	local expected="$1"
	local retries="${2:-6}"
	local i
	for ((i = 1; i <= retries; i++)); do
		if snapshot_has "$expected"; then
			return 0
		fi
		ad scroll down 0.65 >/dev/null
		ad wait 1 >/dev/null
	done
	echo "Unable to locate text after scrolling: $expected" >&2
	return 1
}

echo "== iOS Screen Rotation Smoke Test =="
echo "App: $APP_BUNDLE | Device: $IOS_DEVICE | Session: $SESSION"

run ad boot
ensure_ios_app_ready

# Normalize navigation state to Options page so we can enter Landscape scene.
normalized=false
for _ in 1 2 3 4 5 6; do
	if snapshot_has "Landscape"; then
		normalized=true
		break
	fi

	if snapshot_has "push"; then
		run ad find 'switch to tab' click --first
		run ad wait 1
		continue
	fi

	if snapshot_has "Options"; then
		run ad find 'Options' click --last
		run ad wait 1
		continue
	fi

	if snapshot_has "Back"; then
		run ad find 'Back' click --first
		run ad wait 1
		continue
	fi

	run ad back
	run ad wait 1
done

if [[ "$normalized" != true ]]; then
	echo "Unable to navigate to Options page automatically." >&2
	exit 1
fi

# Enter landscape-only page.
scroll_down_until_visible "Landscape"
run ad find 'Landscape' click --first
wait_visible "Back"

# Rotate between both landscape directions and verify page is still interactive.
run ad rotate landscape-left
run ad wait 1
wait_visible "Back"
run ad screenshot "$ARTIFACT_DIR/landscape-left.png"

run ad rotate landscape-right
run ad wait 1
wait_visible "Back"
run ad screenshot "$ARTIFACT_DIR/landscape-right.png"

# Leave landscape page and ensure app recovers to portrait flow.
run ad find 'Back' click --first
run ad wait 1
run ad rotate portrait
run ad wait 1
wait_visible "Landscape"
run ad screenshot "$ARTIFACT_DIR/portrait-after-pop.png"

echo "PASS: iOS rotation smoke test completed."
echo "Artifacts: $ARTIFACT_DIR"
