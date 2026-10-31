#!/usr/bin/env bash
# Governance G-1: File Line Limit Check
# Absolute Ceiling: 250 lines
# Warning Threshold: 100 lines

set -euo pipefail

MAX_LIMIT=250
WARN_LIMIT=100
VIOLATIONS=0
WARNINGS=0

echo "Running Governance G-1 line count check..."

while IFS= read -r file; do
  lines=$(wc -l < "$file" | tr -d ' ')
  if [ "$lines" -gt "$MAX_LIMIT" ]; then
    echo "VIOLATION: $file has $lines lines (limit: $MAX_LIMIT)"
    VIOLATIONS=$((VIOLATIONS + 1))
  elif [ "$lines" -gt "$WARN_LIMIT" ]; then
    echo "WARNING: $file has $lines lines (warning threshold: $WARN_LIMIT)"
    WARNINGS=$((WARNINGS + 1))
  fi
done < <(find backend frontend scripts -type f \( -name "*.go" -o -name "*.dart" \) \
  ! -path "*/.dart_tool/*" \
  ! -path "*/build/*" \
  ! -path "*/canvaskit/*" \
  ! -path "*/vendor/*" | sort)

echo ""
echo "Summary:"
echo "- Violations (>250 lines): $VIOLATIONS"
echo "- Warnings (>100 lines): $WARNINGS"

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "FAILED: Governance G-1 check failed with $VIOLATIONS violations."
  exit 1
else
  echo "PASSED: All files conform to Governance G-1 absolute ceiling (<250 lines)."
  exit 0
fi
