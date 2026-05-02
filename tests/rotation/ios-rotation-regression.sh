#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_BUNDLE="${APP_BUNDLE:-tech.todoit.navigation}"
IOS_DEVICE="${IOS_DEVICE:-iPhone 17 Pro}"
FORCE_IOS_BUILD="${FORCE_IOS_BUILD:-0}"
IOS_PROACTIVE_RELOAD="${IOS_PROACTIVE_RELOAD:-0}"
SESSION="${AD_SESSION:-rotation-ios-regression}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/rotation/artifacts/rotation-ios-regression}"

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

normalize_navigation_root() {
	local normalized=false
	for _ in 1 2 3 4 5 6 7 8; do
		if snapshot_has "push" && snapshot_has "switch to tab 'Options'"; then
			normalized=true
			break
		fi

		if snapshot_has "Cancel"; then
			run ad find "Cancel" click --first
			run ad wait 1
			continue
		fi

		if snapshot_has "switch to tab 'Navigation'"; then
			run ad find "switch to tab" click --first
			run ad wait 1
			continue
		fi

		if snapshot_has "Back"; then
			run ad find "Back" click --first
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

echo "== iOS Rotation Regression Test =="
echo "App: $APP_BUNDLE | Device: $IOS_DEVICE | Session: $SESSION"

run ad boot
ensure_ios_app_ready
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
run ad find "Cancel" click --first
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

echo "PASS: iOS rotation regression test completed."
echo "Artifacts: $ARTIFACT_DIR"
