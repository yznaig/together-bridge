#!/usr/bin/env bash
# clear — leave the bridge. Stops the watcher, removes THIS local clone, and
# un-ignores the folder in the parent workspace. The GitHub repo and your
# partner are NOT affected.
set -euo pipefail
BRIDGE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT="$(dirname "$BRIDGE")"
NAME="$(basename "$BRIDGE")"

echo "⚠️  This disconnects YOUR machine from the bridge."
echo "    Removing local folder: $BRIDGE"
echo "    (Shared GitHub repo and your partner stay intact.)"
printf "Type 'leave' to confirm: "
read -r ans
[ "$ans" = "leave" ] || { echo "Aborted."; exit 1; }

# stop the watcher: TERM, wait, then escalate to KILL if it's stubborn
WPID="$(cat "$BRIDGE/.watch.pid" 2>/dev/null || true)"
if [ -n "${WPID:-}" ]; then
  kill "$WPID" 2>/dev/null || true
  for _ in 1 2 3; do kill -0 "$WPID" 2>/dev/null || break; sleep 1; done
  kill -9 "$WPID" 2>/dev/null || true
fi
# belt-and-suspenders: sweep any lingering watcher for THIS bridge, but never
# kill this script or any of its ancestors (a caller's command line could
# happen to contain the watch.sh path).
skip=" $$ $PPID "
p="$PPID"; while [ "$p" -gt 1 ] 2>/dev/null; do p="$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')"; [ -n "$p" ] || break; skip="$skip$p "; done
for w in $(pgrep -f "$BRIDGE/scripts/watch.sh" 2>/dev/null); do
  case "$skip" in *" $w "*) continue;; esac
  kill -9 "$w" 2>/dev/null || true
done
rm -f "$BRIDGE/.watch.pid"

# un-ignore the bridge in the parent workspace
if [ -f "$PARENT/.gitignore" ]; then
  grep -vxF "${NAME}/" "$PARENT/.gitignore" > "$PARENT/.gitignore.tmp" 2>/dev/null || true
  mv "$PARENT/.gitignore.tmp" "$PARENT/.gitignore" 2>/dev/null || true
fi

cd "$PARENT"
rm -rf "$BRIDGE"
echo "✅ You've left the bridge. Local clone removed."
