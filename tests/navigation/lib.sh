#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LAYOUT_TOOL="$SCRIPT_DIR/set-demo-root-layout.mjs"

if [[ -x "$PROJECT_ROOT/node_modules/.bin/agent-device" ]]; then
	AGENT_DEVICE_BIN="$PROJECT_ROOT/node_modules/.bin/agent-device"
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

close_current_session() {
	if [[ "${KEEP_AD_SESSION:-0}" == "1" ]]; then
		return 0
	fi
	$AGENT_DEVICE_BIN --session "$SESSION" close >/dev/null 2>&1 || true
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
	ad snapshot >&2 || true
	return 1
}

wait_absent() {
	local unexpected="$1"
	local retries="${2:-5}"
	local i
	for ((i = 1; i <= retries; i++)); do
		if ! snapshot_has "$unexpected"; then
			return 0
		fi
		ad wait 1 >/dev/null
	done
	echo "Unexpected text still visible in snapshot: $unexpected" >&2
	ad snapshot >&2 || true
	return 1
}

assert_absent() {
	local unexpected="$1"
	if snapshot_has "$unexpected"; then
		echo "Unexpected text visible in snapshot: $unexpected" >&2
		ad snapshot >&2 || true
		return 1
	fi
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
	ad snapshot >&2 || true
	return 1
}

close_drawer_if_open() {
	if ! snapshot_has "New thread"; then
		return 0
	fi

	if tap_text "New thread" 2 || tap_text "Settings" 2; then
		wait_absent "New thread" 4 || true
		return 0
	fi

	return 1
}

normalize_navigation_root() {
	local normalized=false
	local i
	for ((i = 1; i <= 10; i++)); do
		if snapshot_has "Push scene" && snapshot_has "Switch to Options" && ! snapshot_has "Back"; then
			normalized=true
			break
		fi

		if snapshot_has "New thread"; then
			close_drawer_if_open || true
			ad wait 1 >/dev/null
			continue
		fi

		if snapshot_has "Switch to Navigation"; then
			tap_text "Switch to Navigation" || true
			ad wait 1 >/dev/null
			continue
		fi

		if snapshot_has "Back"; then
			tap_text "Back" || ad back || true
			ad wait 1 >/dev/null
			continue
		fi

		ad back >/dev/null 2>&1 || true
		ad wait 1 >/dev/null
	done

	if [[ "$normalized" != true ]]; then
		echo "Unable to normalize to Navigation root page." >&2
		ad snapshot >&2 || true
		return 1
	fi
}

get_demo_root_layout() {
	node "$LAYOUT_TOOL" --get
}

set_demo_root_layout() {
	local layout="$1"
	node "$LAYOUT_TOOL" "$layout"
}
