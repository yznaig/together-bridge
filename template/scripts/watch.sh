#!/usr/bin/env bash
# watch — auto-push: when files in shared/ change, commit & push.
# Zero dependencies (git + bash). Debounced by poll interval. Quiet when idle.
set -uo pipefail
BRIDGE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BRIDGE"
INTERVAL="${BRIDGE_WATCH_INTERVAL:-4}"

# don't start a second watcher
if [ -f "$BRIDGE/.watch.pid" ] && kill -0 "$(cat "$BRIDGE/.watch.pid" 2>/dev/null)" 2>/dev/null; then
  echo "Watcher already running (pid $(cat "$BRIDGE/.watch.pid"))."
  exit 0
fi
echo $$ > "$BRIDGE/.watch.pid"
# EXIT cleans up the pidfile; INT/TERM must actually exit (which then fires EXIT).
# Without the explicit `exit`, a TERM trap that only rm's the pidfile lets the
# loop keep running — orphaning the watcher and defeating clear.sh's kill.
trap 'rm -f "$BRIDGE/.watch.pid"' EXIT
trap 'exit 0' INT TERM

# fallback identity so commits work even if git user.name/email aren't configured
git config user.name  >/dev/null 2>&1 || git config user.name  "${USER:-bridge-user}"
git config user.email >/dev/null 2>&1 || git config user.email "bridge@local"

echo "👀 Watching shared/ — auto-push every ${INTERVAL}s when it changes. Ctrl-C to stop."
while true; do
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
