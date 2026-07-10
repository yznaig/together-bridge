#!/usr/bin/env bash
# host-provision — create a new Together Bridge.
#
# Design: the GitHub repo is DATA-ONLY (a scaffold of shared/ + docs). The scripts
# that operate the bridge are installed LOCALLY at ~/.together-bridge/<name>/ from
# this trusted tool — never committed to the shared repo. So nothing a counterparty
# pushes can execute on your machine. See SECURITY.md.
#
# Usage:
#   host-provision.sh --name <repo> [--partner <github-user>] [--path <dir>] [--public] [--dry-run]
set -euo pipefail

PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$PKG/bridge-template"
RUNTIME_SRC="$PKG/runtime"
TOOL_REPO="${TOGETHER_BRIDGE_TOOL_REPO:-https://github.com/yznaig/together-bridge}"

NAME=""; PARTNER=""; DEST=""; VIS="private"; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name)    NAME="$2"; shift 2;;
    --partner) PARTNER="$2"; shift 2;;
    --path)    DEST="$2"; shift 2;;
    --public)  VIS="public"; shift;;
    --dry-run) DRY=1; shift;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done
[ -n "$NAME" ] || { echo "--name <repo> required" >&2; exit 2; }
DEST="${DEST:-$(pwd)/bridge}"
NAMEB="$(basename "$DEST")"
PARENT="$(dirname "$DEST")"
RUNTIME_DIR="$HOME/.together-bridge/$NAME"

run() { if [ "$DRY" = 1 ]; then echo "  [dry-run] $*"; else eval "$@"; fi; }

# preflight
if ! command -v gh >/dev/null; then
  if [ "$DRY" = 1 ]; then echo "  [dry-run] note: gh not found — required for a real run.";
  else echo "GitHub CLI (gh) not found. Install: https://cli.github.com" >&2; exit 1; fi
fi
if [ "$DRY" != 1 ]; then
  gh auth status >/dev/null 2>&1 || { echo "Not logged in. Run: gh auth login" >&2; exit 1; }
fi
[ -e "$DEST" ] && { echo "Path already exists: $DEST (choose another --path or remove it)" >&2; exit 1; }

OWNER="$( [ "$DRY" = 1 ] && echo "<you>" || gh api user -q .login )"
if [ "$VIS" = "public" ]; then
  echo "⚠️  PUBLIC bridge: everything in shared/ will be world-readable on GitHub."
  echo "    Bridges should almost always be private. Continuing because --public was passed."
fi
echo "📦 Creating $VIS repo '$NAME' for $OWNER"
run "gh repo create \"$NAME\" --$VIS --clone=false -d 'Together Bridge — shared sync folder (data only)' >/dev/null"

REPO_URL="https://github.com/$OWNER/$NAME"

echo "📁 Scaffolding DATA-ONLY bridge at: $DEST"
run "mkdir -p \"$DEST\""
run "cp -R \"$TEMPLATE/.\" \"$DEST/\""
run "git -C \"$DEST\" init -q"
run "git -C \"$DEST\" config user.name  >/dev/null 2>&1 || git -C \"$DEST\" config user.name  \"\${USER:-bridge-user}\""
run "git -C \"$DEST\" config user.email >/dev/null 2>&1 || git -C \"$DEST\" config user.email \"bridge@local\""
run "git -C \"$DEST\" add -A"
run "git -C \"$DEST\" commit -q -m 'init together bridge (data only)'"
run "git -C \"$DEST\" branch -M main"
run "git -C \"$DEST\" remote add origin \"$REPO_URL.git\""
run "git -C \"$DEST\" push -q -u origin main"

echo "🧩 Installing LOCAL runtime → $RUNTIME_DIR (never synced)"
run "mkdir -p \"$RUNTIME_DIR\""
run "cp \"$RUNTIME_SRC\"/*.sh \"$RUNTIME_DIR\"/"
run "chmod +x \"$RUNTIME_DIR\"/*.sh"
run "printf '%s\\n' \"$DEST\" > \"$RUNTIME_DIR/bridge.path\""

echo "🙈 Wiring parent workspace to ignore $NAMEB/"
run "touch \"$PARENT/.gitignore\""
run "grep -qxF \"$NAMEB/\" \"$PARENT/.gitignore\" || echo \"$NAMEB/\" >> \"$PARENT/.gitignore\""

if [ -n "$PARTNER" ]; then
  echo "✉️  Inviting $PARTNER (push access)"
  run "gh api -X PUT \"repos/$OWNER/$NAME/collaborators/$PARTNER\" -f permission=push >/dev/null"
fi

echo "👀 Starting auto-push watcher (from local runtime)"
run "nohup bash \"$RUNTIME_DIR/watch.sh\" >/dev/null 2>&1 &"

cat <<BLURB

✅ Bridge live: $REPO_URL   (data-only repo)
   Local folder : $DEST                      (drop files in $NAMEB/shared/)
   Local runtime: $RUNTIME_DIR   (refresh.sh · clear.sh · watch.sh)

── Send this to your partner ──────────────────────────────────────
You're invited to a Together Bridge (shared sync folder).
1. Accept the GitHub invite: $REPO_URL/invitations
2. Join it using the Together Bridge TOOL (this runs trusted code, not scripts
   from the bridge itself):
     • Claude Code:  /together-bridge join $REPO_URL
     • Any tool:     git clone $TOOL_REPO tb && bash tb/join.sh $REPO_URL
3. Done — drop files in bridge/shared/ to share.
───────────────────────────────────────────────────────────────────
BLURB
