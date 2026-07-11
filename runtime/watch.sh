#!/usr/bin/env bash
# watch — auto-push: when files in the bridge's shared/ change, commit & push.
#
# SECURITY: this runs from the LOCAL runtime dir (~/.together-bridge/<name>/),
# installed from the trusted tool — NEVER from inside the synced bridge. So no
# file a counterparty pushes can alter the code that executes on your machine.
# Zero dependencies (git + bash). Debounced by poll interval. Quiet when idle.
set -uo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE="$(cat "$SELF/bridge.path" 2>/dev/null || true)"
[ -n "$BRIDGE" ] && [ -d "$BRIDGE" ] || { echo "bridge path missing/invalid ($SELF/bridge.path)"; exit 1; }
cd "$BRIDGE"
INTERVAL="${BRIDGE_WATCH_INTERVAL:-4}"
PIDF="$SELF/.watch.pid"

# don't start a second watcher
if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF" 2>/dev/null)" 2>/dev/null; then
  echo "Watcher already running (pid $(cat "$PIDF"))."; exit 0
fi
echo $$ > "$PIDF"
trap 'rm -f "$PIDF"' EXIT
trap 'exit 0' INT TERM

# fallback identity so commits work even if git user.name/email aren't set
git config user.name  >/dev/null 2>&1 || git config user.name  "${USER:-bridge-user}"
git config user.email >/dev/null 2>&1 || git config user.email "bridge@local"

echo "👀 Watching $BRIDGE/shared — auto-push every ${INTERVAL}s when it changes. Ctrl-C to stop."
while true; do
  date +%s > "$SELF/.watch.heartbeat" 2>/dev/null || true   # liveness signal for `status`
  if [ -n "$(git status --porcelain shared/ 2>/dev/null)" ]; then
    sleep "$INTERVAL"                         # let a burst of files settle (debounce)
    if [ -n "$(git status --porcelain shared/ 2>/dev/null)" ]; then
      git add shared/
      if git commit -q -m "share: update $(date -u +%Y-%m-%dT%H:%M:%SZ)"; then
        if git push -q 2>/dev/null; then
          echo "⬆️  pushed $(date +%H:%M:%S)"
        else
          echo "⚠️  commit made but push failed (offline?) — will retry on next change."
        fi
      else
        echo "⚠️  couldn't commit — is your git identity set? (git config user.email)"
      fi
    fi
  fi
  sleep "$INTERVAL"
done
