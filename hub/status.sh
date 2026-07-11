#!/usr/bin/env bash
# status — show every registered bridge and whether its auto-push watcher is
# alive, plus how long since its last heartbeat. Use this to confirm sharing is
# actually running (no more silent "I thought it was syncing").
set -uo pipefail
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
now="$(date +%s)"
found=0

echo "Together Bridge — watcher status"
for d in "$HUB"/*/; do
  d="${d%/}"
  [ -f "$d/bridge.path" ] || continue
  found=1
  name="$(basename "$d")"
  BR="$(cat "$d/bridge.path" 2>/dev/null || true)"
  PIDF="$d/.watch.pid"; HB="$d/.watch.heartbeat"

  if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF" 2>/dev/null)" 2>/dev/null; then
    state="ALIVE (pid $(cat "$PIDF"))"
    if [ -f "$HB" ]; then
      beat="$(cat "$HB" 2>/dev/null || echo "$now")"
      state="$state, last beat $(( now - beat ))s ago"
    fi
  else
    state="DOWN — restart: bash $d/watch.sh   (or just open a new terminal)"
  fi
  [ -n "$BR" ] && [ ! -d "$BR" ] && state="$state  [bridge folder missing: $BR]"

  printf '  • %-22s %s\n' "$name" "$state"
done
[ "$found" = 1 ] || echo "  (no bridges registered)"
