#!/usr/bin/env bash
# install — make /together-bridge usable in EVERY workspace (Claude Code).
# Copies the slash command + engine (host-provision.sh, join.sh, runtime/,
# bridge-template/) into your user-level Claude directory.
set -euo pipefail
PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # this repo (the tool)
CMD="$PKG/command/together-bridge.md"

DEST_CMD="$HOME/.claude/commands"
DEST_PKG="$HOME/.claude/together-bridge"

command -v git >/dev/null || { echo "git is required." >&2; exit 1; }

mkdir -p "$DEST_CMD"
# stage the package (engine + templates — not the command dir or repo metadata)
rm -rf "$DEST_PKG.tmp"; mkdir -p "$DEST_PKG.tmp"
cp "$PKG/host-provision.sh" "$PKG/join.sh" "$DEST_PKG.tmp/"
cp -R "$PKG/runtime"          "$DEST_PKG.tmp/runtime"
cp -R "$PKG/hub"              "$DEST_PKG.tmp/hub"
cp -R "$PKG/bridge-template"  "$DEST_PKG.tmp/bridge-template"
rm -rf "$DEST_PKG" && mv "$DEST_PKG.tmp" "$DEST_PKG"
cp "$CMD" "$DEST_CMD/together-bridge.md"

echo "✅ Installed."
echo "   Command : $DEST_CMD/together-bridge.md   (available in every workspace)"
echo "   Package : $DEST_PKG"
echo "   Use it anywhere with:  /together-bridge"
