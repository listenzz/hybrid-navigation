#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

PLATFORM="${PLATFORM:-all}"
LAYOUTS="${LAYOUTS:-stack-drawer-tabs drawer-stack-tabs}"
ORIGINAL_LAYOUT="$(get_demo_root_layout)"

restore_layout() {
	set_demo_root_layout "$ORIGINAL_LAYOUT" >/dev/null 2>&1 || true
}

trap restore_layout EXIT

run_android() {
	local layout="$1"
	AD_SESSION="${AD_SESSION:-navigation-android-$layout}" \
	ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/navigation/artifacts/navigation-android-$layout}" \
	bash "$SCRIPT_DIR/android-drawer-regression.sh"
}

run_ios() {
	local layout="$1"
	AD_SESSION="${AD_SESSION:-navigation-ios-$layout}" \
	ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/tests/navigation/artifacts/navigation-ios-$layout}" \
	bash "$SCRIPT_DIR/ios-drawer-regression.sh"
}

case "$PLATFORM" in
	all | android | ios) ;;
	*)
		echo "Unsupported PLATFORM=$PLATFORM. Use all, android, or ios." >&2
		exit 1
		;;
esac

echo "== Navigation Root Layout Regression Matrix =="
echo "Original layout: $ORIGINAL_LAYOUT"
echo "Layouts: $LAYOUTS"
echo "Platform: $PLATFORM"

for layout in $LAYOUTS; do
	echo "== Layout: $layout =="
	set_demo_root_layout "$layout"
	run yarn tsc

	if [[ "$PLATFORM" == "all" || "$PLATFORM" == "android" ]]; then
		run_android "$layout"
	fi

	if [[ "$PLATFORM" == "all" || "$PLATFORM" == "ios" ]]; then
		run_ios "$layout"
	fi
done

restore_layout
trap - EXIT

echo "PASS: navigation root layout regression matrix completed."
echo "Restored layout: $(get_demo_root_layout)"
