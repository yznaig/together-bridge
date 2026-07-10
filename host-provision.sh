#!/usr/bin/env bash
# host-provision — create a new Together Bridge: make the GitHub repo, scaffold
# the folder from template/, wire the parent workspace, push, invite the partner.
#
# Usage:
#   host-provision.sh --name <repo> [--partner <github-user>] [--path <dir>] [--public] [--dry-run]
set -euo pipefail

PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$PKG/template"
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

run() { if [ "$DRY" = 1 ]; then echo "  [dry-run] $*"; else eval "$@"; fi; }

# preflight
if ! command -v gh >/dev/null; then
  if [ "$DRY" = 1 ]; then
    echo "  [dry-run] note: gh not found in this shell — it's required for a real run."
  else
    echo "GitHub CLI (gh) not found. Install: https://cli.github.com" >&2; exit 1
  fi
fi
if [ "$DRY" != 1 ]; then
  gh auth status >/dev/null 2>&1 || { echo "Not logged in. Run: gh auth login" >&2; exit 1; }
fi
[ -e "$DEST" ] && { echo "Path already exists: $DEST (choose another --path or remove it)" >&2; exit 1; }

OWNER="$( [ "$DRY" = 1 ] && echo "<you>" || gh api user -q .login )"
echo "📦 Creating $VIS repo '$NAME' for $OWNER"
run "gh repo create \"$NAME\" --$VIS --clone=false -d 'Together Bridge — shared sync folder' >/dev/null"

REPO_URL="https://github.com/$OWNER/$NAME"

echo "📁 Scaffolding bridge at: $DEST"
run "mkdir -p \"$DEST\""
run "cp -R \"$TEMPLATE/.\" \"$DEST/\""
run "git -C \"$DEST\" init -q"
run "git -C \"$DEST\" config user.name  >/dev/null 2>&1 || git -C \"$DEST\" config user.name  \"\${USER:-bridge-user}\""
run "git -C \"$DEST\" config user.email >/dev/null 2>&1 || git -C \"$DEST\" config user.email \"bridge@local\""
run "git -C \"$DEST\" add -A"
run "git -C \"$DEST\" commit -q -m 'init together bridge'"
run "git -C \"$DEST\" branch -M main"
run "git -C \"$DEST\" remote add origin \"$REPO_URL.git\""
run "git -C \"$DEST\" push -q -u origin main"

echo "🙈 Wiring parent workspace to ignore $NAMEB/"
run "touch \"$PARENT/.gitignore\""
run "grep -qxF \"$NAMEB/\" \"$PARENT/.gitignore\" || echo \"$NAMEB/\" >> \"$PARENT/.gitignore\""

if [ -n "$PARTNER" ]; then
  echo "✉️  Inviting $PARTNER (push access)"
  run "gh api -X PUT \"repos/$OWNER/$NAME/collaborators/$PARTNER\" -f permission=push >/dev/null"
fi

echo "👀 Starting auto-push watcher"
run "nohup bash \"$DEST/scripts/watch.sh\" >/dev/null 2>&1 &"

cat <<BLURB

✅ Bridge live: $REPO_URL
   Local folder: $DEST   (drop files in $NAMEB/shared/)

── Send this to your partner ──────────────────────────────────────
You're invited to a Together Bridge (shared sync folder).
1. Accept the GitHub invite: $REPO_URL/invitations
2. In the project folder you want to share from, run:
     git clone $REPO_URL.git bridge && bash bridge/setup.sh
   Or, if you use Claude Code:
     /together-bridge join $REPO_URL
3. Done — drop files in bridge/shared/ to share.
───────────────────────────────────────────────────────────────────
BLURB
