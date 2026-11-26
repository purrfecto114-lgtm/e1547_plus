#!/usr/bin/env bash
# Scans the locked Ruby and Pub dependencies against the OSV database.
#
# Usage: tool/osv_scan.sh [--baseline path]
#
# Exits non-zero when an advisory hits a locked version that is not in
# the baseline file. The baseline lists advisories that are known but
# currently unfixable within the tooling constraints, one GHSA/OSV id
# per line, so the scan stays useful in CI instead of failing forever.
set -euo pipefail

cd "$(dirname "$0")/.."

BASELINE="${1:--}"
if [ "$BASELINE" = "-" ]; then
  BASELINE="tool/osv_baseline.txt"
fi

# Advisories accepted until the constraints around them change.
KNOWN="$(cat "$BASELINE" 2>/dev/null || true)"

# Packages sent to OSV per batched request. The batch endpoint collapses
# ~350 per-package queries (each one HTTP round trip, about a minute in
# CI) into a handful of requests.
BATCH_SIZE=100

fail=0
hits=0

collect_file() {
  # $1: lockfile, $2: ecosystem (RubyGems or Pub)
  local file="$1" eco="$2"
  [ -f "$file" ] || return 0
  # RubyGems: "    gem (1.2.3)" lines inside the GEM specs block
  # Pub: '  name:' followed by '    version:' in pubspec.lock
  if [ "$eco" = "RubyGems" ]; then
    awk '/^  specs:/{flag=1;next} /^  [A-Z]/{flag=0} flag && /^    [a-zA-Z0-9_-]+ \(/{print}' "$file" \
      | sed -E 's/^    ([^ ]+) \(([^)]+)\).*$/\1 \2/'
  else
    awk '
      /^  [a-z0-9_]+:$/ {pkg=$1; gsub(":","",pkg)}
      /^    version: "/ {gsub(/"|version: | /,"",$0); if (pkg!="") {print pkg" "$0; pkg=""}}
    ' "$file"
  fi | while read -r pkg ver; do
    echo "$eco $pkg $ver"
  done
}

scan_batches() {
  # $1: file with "ecosystem package version" lines; prints one
  # "ecosystem pkg@ver: advisory" line per hit. Every failure aborts the
  # scan: a query that never ran must not count as a clean pass.
  local lines="$1" start total line eco pkg ver rest response
  local -a chunk
  local chunk_json advisory idx results
  response="$(mktemp)"
  total=$(wc -l < "$lines")
  for ((start = 0; start < total; start += BATCH_SIZE)); do
    mapfile -t chunk < <(sed -n "$((start + 1)),$((start + BATCH_SIZE))p" "$lines")
    chunk_json=$(
      printf '%s\n' "${chunk[@]}" | jq -R '
        split(" ") | {package: {ecosystem: .[0], name: .[1]}, version: .[2]}
      ' | jq -s '{queries: .}'
    )
    if ! curl -fsS --max-time 30 -X POST 'https://api.osv.dev/v1/querybatch' \
      -H 'Content-Type: application/json' \
      -d "$chunk_json" -o "$response"; then
      echo "::error::OSV batch query failed (packages $((start + 1))-$((start + ${#chunk[@]})))"
      exit 1
    fi
    # The batch answers with one result per query, in order; anything
    # else means the payload was malformed and some packages went
    # unscanned.
    results="$(jq -c '.results' "$response")"
    if [ "$(jq 'length' <<<"$results")" -ne "${#chunk[@]}" ]; then
      echo "::error::OSV batch answered ${#chunk[@]} queries with $(jq 'length' <<<"$results") results"
      exit 1
    fi
    for idx in "${!chunk[@]}"; do
      line="${chunk[$idx]}"
      eco="${line%% *}"
      rest="${line#* }"
      pkg="${rest%% *}"
      ver="${rest#* }"
      # $results is already the per-query result array; a jq failure
      # here must abort, or an advisory would pass unnoticed.
      while IFS= read -r advisory; do
        [ -n "$advisory" ] && echo "$eco $pkg@$ver: $advisory"
      done < <(jq -r --argjson idx "$idx" \
        '.[$idx].vulns[]?.id // empty' <<<"$results") || exit 1
    done
  done
  rm -f "$response"
}

PACKAGES="$(mktemp)"
trap 'rm -f "$PACKAGES"' EXIT
{ collect_file Gemfile.lock RubyGems; collect_file pubspec.lock Pub; } \
  > "$PACKAGES"
RESULTS="$(scan_batches "$PACKAGES" | sort)"

if [ -n "$RESULTS" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    hits=$((hits + 1))
    id="$(echo "$line" | awk '{print $NF}')"
    if echo "$KNOWN" | grep -qxF "$id"; then
      echo "KNOWN   $line"
    else
      echo "UNFIXED $line"
      fail=1
    fi
  done <<< "$RESULTS"
fi

if [ "$fail" -ne 0 ]; then
  echo "::error::OSV scan found advisories outside the baseline ($BASELINE)"
  exit 1
fi
echo "OSV scan passed ($hits known advisories, all within the baseline)"
