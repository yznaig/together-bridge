#!/usr/bin/env bash
# ensure-watchers — start the auto-push watcher for every registered bridge that
# isn't already running. Idempotent and cheap: safe to run on every terminal open
# (that's how a bridge "self-heals" after a reboot or a closed terminal). Also
# retires runtime dirs whose bridge folder no longer exists.
set -uo pipefail
HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # ~/.together-bridge

for d in "$HUB"/*/; do
  d="${d%/}"
  [ -f "$d/bridge.path" ] || continue
  BR="$(cat "$d/bridge.path" 2>/dev/null || true)"

  # bridge folder gone → retire this stale runtime dir and move on
  if [ -z "$BR" ] || [ ! -d "$BR" ]; then
    rm -rf "$d"
    continue
  fi

  # already running? (PID guard, same as watch.sh) → leave it
  PIDF="$d/.watch.pid"
  if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF" 2>/dev/null)" 2>/dev/null; then
    continue
  fi

  # start it, detached and quiet
  [ -f "$d/watch.sh" ] || continue
  nohup bash "$d/watch.sh" >/dev/null 2>&1 &
done
