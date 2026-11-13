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

BASELINE="${1:---}"
if [ "$BASELINE" = "-" ]; then
  BASELINE="tool/osv_baseline.txt"
fi

# Advisories accepted until the constraints around them change.
KNOWN="$(cat "$BASELINE" 2>/dev/null || true)"

query() {
  # $1: ecosystem (RubyGems or Pub), $2: package, $3: version
  jq -n --arg eco "$1" --arg pkg "$2" --arg ver "$3" \
    '{package: {ecosystem: $eco, name: $pkg}, version: $ver}' \
    | curl -fsS --max-time 30 -X POST 'https://api.osv.dev/v1/query' \
      -d @- \
    | jq -r '.vulns[]?.id // empty'
}

fail=0
hits=0

scan_file() {
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
    for advisory in $(query "$eco" "$pkg" "$ver"); do
      echo "$eco $pkg@$ver: $advisory"
    done
  done
}

RESULTS="$( { scan_file Gemfile.lock RubyGems; scan_file pubspec.lock Pub; } | sort )"

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
