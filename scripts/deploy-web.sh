#!/usr/bin/env bash
# Build the Flutter web app and deploy it to Vercel — one command.
#
#   ./scripts/deploy-web.sh                 # preview deploy (offline/sample data)
#   API_BASE_URL=https://api.mystables.ae ./scripts/deploy-web.sh --prod
#
# Prerequisites (one time):
#   - Flutter installed (flutter doctor)
#   - Vercel CLI:   npm i -g vercel
#   - Logged in:    vercel login
#
# API_BASE_URL (optional): when set, the app talks to that API. When empty, the
# app runs in offline mode with sample data — handy for a shareable preview.
set -euo pipefail

cd "$(dirname "$0")/.."

PROD=""
if [[ "${1:-}" == "--prod" ]]; then PROD="--prod"; fi

DEFINES=()
if [[ -n "${API_BASE_URL:-}" ]]; then
  DEFINES+=(--dart-define=API_BASE_URL="$API_BASE_URL")
fi
if [[ -n "${API_STABLE_ID:-}" ]]; then
  DEFINES+=(--dart-define=API_STABLE_ID="$API_STABLE_ID")
fi

echo "==> flutter build web ${DEFINES[*]:-(offline mode)}"
flutter build web --release "${DEFINES[@]:-}"

echo "==> deploying build/web to Vercel ${PROD:-(preview)}"
vercel deploy build/web --yes $PROD

echo "==> done. The URL above is your live app."
