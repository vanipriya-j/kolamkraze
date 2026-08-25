#!/usr/bin/env bash
# Build the Flutter web app for Vercel (or any static host).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
export PATH="$FLUTTER_ROOT/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter SDK into $FLUTTER_ROOT"
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_ROOT"
fi

flutter --version
flutter config --no-analytics --enable-web
flutter precache --web
cd "$ROOT/mobile"
flutter pub get
flutter build web --release --no-wasm-dry-run --no-web-resources-cdn

echo "Built to mobile/build/web"
