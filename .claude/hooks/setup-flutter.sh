#!/usr/bin/env bash
# Installs the Flutter SDK for cloud sessions so `flutter analyze` / `flutter test` work.
# Android SDK is NOT installed here: dl.google.com is blocked by the default network policy,
# so APK/AAB builds run in GitHub Actions / Codemagic instead.
set -euo pipefail
FLUTTER_VERSION="${FLUTTER_VERSION:-3.35.5}"
if [ ! -x /opt/flutter/bin/flutter ]; then
  echo "[setup] downloading Flutter $FLUTTER_VERSION"
  curl -sSL -o /tmp/flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  tar -xJf /tmp/flutter.tar.xz -C /opt && rm /tmp/flutter.tar.xz
fi
git config --global --add safe.directory /opt/flutter >/dev/null 2>&1 || true
export PATH="/opt/flutter/bin:$PATH"
flutter config --no-analytics >/dev/null 2>&1 || true
cd "$(dirname "$0")/../.."
flutter pub get >/dev/null
flutter gen-l10n >/dev/null
echo "[setup] Flutter ready: $(flutter --version | head -1). Add /opt/flutter/bin to PATH."
