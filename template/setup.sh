#!/usr/bin/env bash
# setup — one-time bridge installer. Run once from inside the cloned bridge folder:
#   git clone <url> bridge && bash bridge/setup.sh
# Wires the parent workspace to ignore the bridge, checks push access, and starts
# the auto-push watcher. Works on Mac, Linux, WSL, and Git-Bash (Windows).
set -euo pipefail
BRIDGE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT="$(dirname "$BRIDGE")"
NAME="$(basename "$BRIDGE")"
cd "$BRIDGE"

echo "🔗 Setting up Together Bridge at: $BRIDGE"

# 1) parent workspace ignores the bridge folder
touch "$PARENT/.gitignore"
grep -qxF "${NAME}/" "$PARENT/.gitignore" || echo "${NAME}/" >> "$PARENT/.gitignore"
echo "  ✔ parent workspace now ignores ${NAME}/"

# 2) verify push access
if git ls-remote --exit-code origin >/dev/null 2>&1; then
  echo "  ✔ remote reachable"
else
  echo "  ⚠ can't reach the remote — accept the GitHub invite and run 'gh auth login' (or set up git credentials), then re-run."
fi

# 3) auto-start the watcher when this workspace is opened (create-if-absent)
mkdir -p "$PARENT/.vscode"
if [ ! -f "$PARENT/.vscode/tasks.json" ]; then
  cat > "$PARENT/.vscode/tasks.json" <<JSON
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "together-bridge: watch",
      "type": "shell",
      "command": "bash ${NAME}/scripts/watch.sh",
      "runOptions": { "runOn": "folderOpen" },
      "isBackground": true,
      "presentation": { "reveal": "silent", "panel": "dedicated", "close": true },
      "problemMatcher": []
    }
  ]
}
JSON
  echo "  ✔ watcher will auto-start when you open this workspace"
else
  echo "  ℹ existing .vscode/tasks.json found — add a 'together-bridge: watch' task, or just run ${NAME}/scripts/watch.sh manually."
fi

# 4) start the watcher now
nohup bash "$BRIDGE/scripts/watch.sh" >/dev/null 2>&1 &
echo "  ✔ auto-push watcher started"

echo ""
echo "✅ Bridge ready. Drop files in ${NAME}/shared/ to share them."
echo "   Get partner updates:  bash ${NAME}/scripts/refresh.sh"
echo "   Leave the bridge:     bash ${NAME}/scripts/clear.sh"
