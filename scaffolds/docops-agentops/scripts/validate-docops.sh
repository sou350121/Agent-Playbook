#!/usr/bin/env bash
set -euo pipefail

fail() { echo "[FAIL] $*"; exit 1; }
warn() { echo "[WARN] $*"; }

shopt -s nullglob
stories=(stories/*.md)
[[ ${#stories[@]} -gt 0 ]] || fail "No stories found under stories/*.md"

missing=0
for story in "${stories[@]}"; do
  base="$(basename "$story" .md)"
  prompt="prompts/${base}.md"
  failures="sessions/${base}/failures.md"
  status="docs/features/${base}/status.md"

  [[ -f "$prompt" ]] || { echo "Missing $prompt"; missing=1; }
  [[ -f "$failures" ]] || { echo "Missing $failures"; missing=1; }
  [[ -f "$status" ]] || { echo "Missing $status"; missing=1; }

  if [[ -f "$status" ]]; then
    grep -q "$story" "$status" || warn "$status does not reference $story"
    grep -q "$prompt" "$status" || warn "$status does not reference $prompt"
  fi

done

[[ $missing -eq 0 ]] || fail "Evidence chain incomplete"

echo "[OK] DocOps evidence chain looks good"