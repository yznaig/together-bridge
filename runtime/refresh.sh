#!/usr/bin/env bash
# refresh — pull the partner's latest shared files into the bridge.
# Runs from the local runtime dir; locates the bridge via bridge.path.
set -euo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE="$(cat "$SELF/bridge.path" 2>/dev/null || true)"
[ -n "$BRIDGE" ] && [ -d "$BRIDGE" ] || { echo "bridge path missing/invalid ($SELF/bridge.path)"; exit 1; }
cd "$BRIDGE"
echo "🔄 Refreshing bridge…"
git pull --rebase --autostash
echo "✅ Up to date. Shared files:"
find shared -type f ! -name '.gitkeep' -printf '   • %P\n' 2>/dev/null \
  || { ls -1 shared 2>/dev/null | grep -v '^.gitkeep$' | sed 's/^/   • /'; true; }
