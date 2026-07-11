#!/usr/bin/env bash
# clear — leave the bridge. Stops the watcher, removes THIS local clone and the
# local runtime dir, and un-ignores the folder in the parent workspace. The
# GitHub repo and your partner are NOT affected.
set -euo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE="$(cat "$SELF/bridge.path" 2>/dev/null || true)"
[ -n "$BRIDGE" ] || { echo "bridge path missing ($SELF/bridge.path)"; exit 1; }
PARENT="$(dirname "$BRIDGE")"
NAME="$(basename "$BRIDGE")"

echo "⚠️  This disconnects YOUR machine from the bridge."
echo "    Removing local folder: $BRIDGE"
echo "    (Shared GitHub repo and your partner stay intact.)"
printf "Type 'leave' to confirm: "
read -r ans
[ "$ans" = "leave" ] || { echo "Aborted."; exit 1; }

# stop the watcher: TERM, wait, then escalate to KILL
WPID="$(cat "$SELF/.watch.pid" 2>/dev/null || true)"
if [ -n "${WPID:-}" ]; then
  kill "$WPID" 2>/dev/null || true
  for _ in 1 2 3; do kill -0 "$WPID" 2>/dev/null || break; sleep 1; done
  kill -9 "$WPID" 2>/dev/null || true
fi

# un-ignore the bridge in the parent workspace
if [ -f "$PARENT/.gitignore" ]; then
  grep -vxF "${NAME}/" "$PARENT/.gitignore" > "$PARENT/.gitignore.tmp" 2>/dev/null || true
  mv "$PARENT/.gitignore.tmp" "$PARENT/.gitignore" 2>/dev/null || true
fi

[ -d "$BRIDGE" ] && rm -rf "$BRIDGE"
# remove this runtime dir (safe: the running script is already in memory)
rm -rf "$SELF"
# if that was the last bridge, remove the shell self-heal hook too
[ -f "$HOME/.together-bridge/hook.sh" ] && bash "$HOME/.together-bridge/hook.sh" remove-if-empty 2>/dev/null || true
echo "✅ You've left the bridge. Local clone removed."
