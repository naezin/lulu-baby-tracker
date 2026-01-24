#!/bin/bash

# i18n Compliance Checker
# This script checks for hardcoded English strings in Dart files

set -e

echo "🌍 Running i18n compliance check..."
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Run the Dart script
dart scripts/check_i18n.dart

# Exit code is passed through from the Dart script
