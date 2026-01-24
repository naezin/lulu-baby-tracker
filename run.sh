#!/bin/bash

echo "🌙 Starting Lulu App..."
echo ""
echo "The app will open in Chrome browser."
echo "First build may take 1-2 minutes. Please wait..."
echo ""
echo "Controls:"
echo "  r  - Hot reload (after code changes)"
echo "  R  - Hot restart"
echo "  q  - Quit app"
echo ""
echo "==================================="
echo ""

cd "$(dirname "$0")"
flutter run -d chrome --dart-define=OPENAI_API_KEY=demo-mode
