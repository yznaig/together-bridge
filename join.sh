#!/usr/bin/env bash
# join — join a Together Bridge someone shared with you.
#
# SECURITY: run this from the Together Bridge TOOL (this repo), which is trusted.
# It clones the partner's bridge as DATA ONLY and installs the operating scripts
# from THIS tool — it never executes code that came from the bridge repo. See
# SECURITY.md.
#
# Usage:  bash join.sh <bridge-repo-url> [--path <dir>]
set -euo pipefail

PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_SRC="$PKG/runtime"

URL=""; DEST=""
while [ $# -gt 0 ]; do
  case "$1" in
    --path) DEST="$2"; shift 2;;
    -*)     echo "unknown flag: $1" >&2; exit 2;;
    *)      URL="$1"; shift;;
  esac
done
[ -n "$URL" ] || { echo "usage: join.sh <bridge-repo-url> [--path <dir>]" >&2; exit 2; }
command -v git >/dev/null || { echo "git is required." >&2; exit 1; }

URL="${URL%.git}"
NAME="$(basename "$URL")"
DEST="${DEST:-$(pwd)/bridge}"
NAMEB="$(basename "$DEST")"
PARENT="$(dirname "$DEST")"
RUNTIME_DIR="$HOME/.together-bridge/$NAME"
[ -e "$DEST" ] && { echo "Path already exists: $DEST (choose another --path or remove it)" >&2; exit 1; }

echo "📥 Cloning bridge (data only) → $DEST"
git clone -q "$URL.git" "$DEST" || { echo "Clone failed — accept the GitHub invite ($URL/invitations) and check 'gh auth login' / git credentials, then retry." >&2; exit 1; }

# safety: a data-only bridge should contain NO executable scripts. If it does,
# someone put code where only data belongs — warn loudly and do not run it.
if find "$DEST" -path "$DEST/.git" -prune -o -type f \( -name '*.sh' -o -name '*.ps1' -o -name '*.bat' -o -name '*.command' \) -print 2>/dev/null | grep -q .; then
  echo "⚠️  WARNING: this bridge contains scripts — a data-only bridge should not."
  echo "    They will NOT be run. Inspect them before trusting this bridge."
fi

echo "🧩 Installing LOCAL runtime → $RUNTIME_DIR (from the trusted tool, never synced)"
mkdir -p "$RUNTIME_DIR"
cp "$RUNTIME_SRC"/*.sh "$RUNTIME_DIR"/
chmod +x "$RUNTIME_DIR"/*.sh
printf '%s\n' "$DEST" > "$RUNTIME_DIR/bridge.path"

echo "🙈 Wiring parent workspace to ignore $NAMEB/"
touch "$PARENT/.gitignore"
grep -qxF "$NAMEB/" "$PARENT/.gitignore" || echo "$NAMEB/" >> "$PARENT/.gitignore"

echo "👀 Starting auto-push watcher (from local runtime)"
nohup bash "$RUNTIME_DIR/watch.sh" >/dev/null 2>&1 &

cat <<DONE

✅ Joined the bridge. Drop files in $DEST/shared/ to share them.
   Get updates:  bash $RUNTIME_DIR/refresh.sh
   Leave:        bash $RUNTIME_DIR/clear.sh
DONE
