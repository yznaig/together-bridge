#!/usr/bin/env bash
# refresh — pull the partner's latest shared files into this bridge.
set -euo pipefail
BRIDGE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BRIDGE"
echo "🔄 Refreshing bridge…"
git pull --rebase --autostash
echo "✅ Up to date. Shared files:"
if command -v find >/dev/null; then
  find shared -type f ! -name '.gitkeep' -printf '   • %P\n' 2>/dev/null || ls -1 shared | grep -v '^.gitkeep$' | sed 's/^/   • /' || true
fi
