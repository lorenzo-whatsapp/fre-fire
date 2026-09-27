#!/usr/bin/env bash
set -Eeuo pipefail

DURATION_MINUTES="${1:-120}"

if ! [[ "$DURATION_MINUTES" =~ ^[0-9]+$ ]]; then
  echo "Invalid duration: $DURATION_MINUTES"
  exit 1
fi

echo "Waiting for Android device..."
adb wait-for-device

echo "Android device:"
adb shell getprop ro.build.version.release || true
adb shell getprop ro.product.model || true

APK_COUNT=0

for apk in apps/*.apk; do
  [ -f "$apk" ] || continue

  APK_COUNT=$((APK_COUNT + 1))
  echo "=== Installing: $apk ==="
  adb install -r "$apk"

  AAPT="$(find "$ANDROID_HOME/build-tools" -type f -name aapt | sort -V | tail -n 1)"
  if [ -z "$AAPT" ]; then
    echo "Android build-tools aapt was not found."
    exit 1
  fi

  PACKAGE="$(
    "$AAPT" dump badging "$apk" 2>/dev/null |
      sed -n "s/^package: name='\([^']*\)'.*/\1/p" |
      head -n 1
  )"

  if [ -z "$PACKAGE" ]; then
    echo "Could not detect package name for $apk"
    exit 1
  fi

  echo "Package: $PACKAGE"
  adb shell monkey -p "$PACKAGE" 1 >/tmp/monkey.log 2>&1 || {
    cat /tmp/monkey.log
    exit 1
  }
  echo "Application launched: $PACKAGE"
done

if [ "$APK_COUNT" -eq 0 ]; then
  echo "No APK files were found in apps/."
  exit 1
fi

echo "Installed and launched $APK_COUNT APK(s)."
echo "Keeping emulator alive for ${DURATION_MINUTES} minute(s)..."

END_TIME=$(( $(date +%s) + DURATION_MINUTES * 60 ))
LAST_HEARTBEAT=-300

while true; do
  NOW=$(date +%s)
  REMAINING=$(( END_TIME - NOW ))
  [ "$REMAINING" -gt 0 ] || break

  ELAPSED=$(( DURATION_MINUTES * 60 - REMAINING ))
  if [ "$ELAPSED" -ge $(( LAST_HEARTBEAT + 300 )) ]; then
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] Emulator alive. ${REMAINING}s remaining."
    adb shell dumpsys activity activities | grep -m 1 "mResumedActivity" || true
    LAST_HEARTBEAT="$ELAPSED"
  fi

  sleep 30
done

echo "Run finished."
