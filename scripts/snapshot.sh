#!/bin/zsh
#
# Builds the app and captures the showcase screenshots used in the README.
# Usage: ./scripts/snapshot.sh [simulator-name]
#
set -e
cd "$(dirname "$0")/.."

SIM_NAME="${1:-iPhone 17}"
SCHEME="AlineaAmountEntry"
BUNDLE="com.valikhim.AlineaAmountEntry"
APP="build/Build/Products/Debug-iphonesimulator/${SCHEME}.app"

DEV=$(xcrun simctl list devices available | grep -m1 "$SIM_NAME (" | grep -oE '[0-9A-F-]{36}')
if [ -z "$DEV" ]; then echo "Simulator '$SIM_NAME' not found"; exit 1; fi

echo "Building…"
xcodebuild -project "${SCHEME}.xcodeproj" -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$DEV" -derivedDataPath build -configuration Debug -quiet build

xcrun simctl boot "$DEV" 2>/dev/null || true
xcrun simctl bootstatus "$DEV" -b >/dev/null 2>&1 || true
xcrun simctl install "$DEV" "$APP"
mkdir -p screenshots

capture() {  # name  prefill
  xcrun simctl terminate "$DEV" "$BUNDLE" 2>/dev/null || true
  if [ -z "$2" ]; then
    xcrun simctl launch "$DEV" "$BUNDLE" >/dev/null
  else
    SIMCTL_CHILD_AMOUNT_PREFILL="$2" xcrun simctl launch "$DEV" "$BUNDLE" >/dev/null
  fi
  python3 -c "import time; time.sleep(2.0)"
  xcrun simctl io "$DEV" screenshot "screenshots/$1.png" >/dev/null 2>&1
  echo "  screenshots/$1.png"
}

capture 01-empty ""
capture 02-entered 2000
capture 03-large-scaling 1234567890
capture 04-decimal 1234.56
xcrun simctl terminate "$DEV" "$BUNDLE" 2>/dev/null || true
echo "Done."
