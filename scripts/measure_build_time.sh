#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════
# Lulu - 빌드 시간 측정 스크립트
# 용도: Clean Build 및 Incremental Build 시간 측정
# 사용: ./scripts/measure_build_time.sh
# ═══════════════════════════════════════════════════════════════════════

set -e

echo "📊 Lulu 빌드 시간 측정 시작..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

# 측정 시작 시간 기록
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE="build_performance_log.txt"

# ─────────────────────────────────────────────────────────────────────────
# 1. Clean Build 시간 측정
# ─────────────────────────────────────────────────────────────────────────
echo "🧹 Clean Build 시간 측정 중..."
echo ""

# Flutter clean
flutter clean > /dev/null 2>&1

# iOS Debug 빌드 (시간 측정)
echo "🍎 iOS Debug Build 측정..."
START_TIME=$(date +%s)
flutter build ios --debug --no-codesign > /dev/null 2>&1
END_TIME=$(date +%s)
CLEAN_BUILD_TIME=$((END_TIME - START_TIME))

echo "✅ Clean Build 완료: ${CLEAN_BUILD_TIME}초"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 2. Incremental Build 시간 측정
# ─────────────────────────────────────────────────────────────────────────
echo "⚡ Incremental Build 시간 측정 중..."
echo ""

# main.dart에 주석 추가 (최소 변경)
echo "// Build time test: $TIMESTAMP" >> lib/main.dart

# 증분 빌드 (시간 측정)
START_TIME=$(date +%s)
flutter build ios --debug --no-codesign > /dev/null 2>&1
END_TIME=$(date +%s)
INCREMENTAL_BUILD_TIME=$((END_TIME - START_TIME))

# 추가한 주석 제거 (원상복구)
sed -i '' '/Build time test/d' lib/main.dart

echo "✅ Incremental Build 완료: ${INCREMENTAL_BUILD_TIME}초"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 3. 결과 출력 및 로그 기록
# ─────────────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════"
echo "📊 빌드 성능 측정 결과"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "날짜: $TIMESTAMP"
echo ""
echo "Clean Build (iOS Debug):        ${CLEAN_BUILD_TIME}초 ($((CLEAN_BUILD_TIME / 60))분 $((CLEAN_BUILD_TIME % 60))초)"
echo "Incremental Build:              ${INCREMENTAL_BUILD_TIME}초"
echo ""

# 기준 대비 평가
if [ $CLEAN_BUILD_TIME -lt 300 ]; then
  echo "✅ Clean Build: 목표 달성 (< 5분)"
else
  echo "⚠️  Clean Build: 목표 미달 (>= 5분)"
fi

if [ $INCREMENTAL_BUILD_TIME -lt 30 ]; then
  echo "✅ Incremental Build: 목표 달성 (< 30초)"
else
  echo "⚠️  Incremental Build: 목표 미달 (>= 30초)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"

# 로그 파일에 기록
echo "" >> "$LOG_FILE"
echo "[$TIMESTAMP]" >> "$LOG_FILE"
echo "Clean Build: ${CLEAN_BUILD_TIME}s ($(git rev-parse --short HEAD 2>/dev/null || echo 'unknown'))" >> "$LOG_FILE"
echo "Incremental Build: ${INCREMENTAL_BUILD_TIME}s" >> "$LOG_FILE"

echo ""
echo "📝 결과가 $LOG_FILE 에 기록되었습니다."
echo ""
echo "💡 Tip: 이 측정을 주 1회 실행하여 성능 추이를 모니터링하세요."
echo ""
