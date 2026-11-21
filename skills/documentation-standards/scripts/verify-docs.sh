#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
WARNINGS=0

echo "=== Verifying Dual-Audience Documentation Standards in: $TARGET ==="

while IFS= read -r -d '' file; do
  lines=$(wc -l < "$file")
  base=$(basename "$file")

  # 1. Check file length caps (README <= 150, other docs <= 250)
  if [[ "$base" == "README.md" && "$lines" -gt 150 ]]; then
    echo "  [WARN] $file: $lines lines (exceeds 150-line Gateway README cap; split into docs/*.md)"
    WARNINGS=$((WARNINGS + 1))
  elif [[ "$base" != "README.md" && "$lines" -gt 250 ]]; then
    echo "  [WARN] $file: $lines lines (exceeds 250-line S1000D/Diataxis module cap)"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Strip fenced code blocks and inline backticks for prose/link checks so examples don't false-positive
  prose_only=$(awk '/^```/{flag=!flag; next} !flag' "$file" | sed -E 's/`[^`]*`//g')

  # 2. Check for banned ASD-STE100 filler phrases in non-code prose
  if echo "$prose_only" | grep -niE '\b(simply|easily|basically|obviously|in order to|please note|it should be noted)\b' >/dev/null 2>&1; then
    echo "  [WARN] $file: Contains banned ASD-STE100 filler words in prose:"
    echo "$prose_only" | grep -niE '\b(simply|easily|basically|obviously|in order to|please note|it should be noted)\b' | sed 's/^/         Line /'
    WARNINGS=$((WARNINGS + 1))
  fi

  # 3. Check relative file links exist (outside fenced code blocks and inline backticks)
  dir=$(dirname "$file")
  while IFS= read -r link; do
    clean_link="${link%%#*}"
    [[ -z "$clean_link" || "$clean_link" =~ ^(https?|mailto|file|conversation):// ]] && continue
    if [[ ! -e "$dir/$clean_link" ]]; then
      echo "  [WARN] $file: Broken relative link -> '$link'"
      WARNINGS=$((WARNINGS + 1))
    fi
  done < <(echo "$prose_only" | grep -oE '\[[^]]+\]\(([^)]+)\)' | sed -E 's/.*\(([^)]+)\)/\1/' || true)

  # 4. Runbook QRH check: ensure runbooks have **Verify:** markers
  if [[ "$file" == *"runbooks/"* ]] && ! grep -q '\*\*Verify:\*\*' "$file"; then
    echo "  [WARN] $file: Runbook missing aviation QRH '**Verify:**' step checks"
    WARNINGS=$((WARNINGS + 1))
  fi
done < <(find "$TARGET" -type f -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -print0)

if [[ "$WARNINGS" -eq 0 ]]; then
  echo "  [OK] All Markdown files pass Dual-Audience (STE100 / Diataxis / QRH) checks."
else
  echo "=== Completed with $WARNINGS warning(s) ==="
fi
