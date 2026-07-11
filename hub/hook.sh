#!/usr/bin/env bash
# hook — manage the shell-profile line that self-heals bridge watchers on every
# terminal open (so they come back after a reboot or a closed terminal).
#
#   hook.sh install          add the guarded block to your shell profile(s)
#   hook.sh remove-if-empty  remove it, but only if no bridges remain
#   hook.sh remove           remove it unconditionally
#
# Idempotent. Cross-platform (bash/zsh, uses awk not sed -i).
set -uo pipefail
HUB="$HOME/.together-bridge"
BEGIN="# >>> together-bridge >>>"
END="# <<< together-bridge <<<"

block() {
  printf '%s\n' "$BEGIN"
  printf '%s\n' '[ -f "$HOME/.together-bridge/ensure-watchers.sh" ] && bash "$HOME/.together-bridge/ensure-watchers.sh" >/dev/null 2>&1'
  printf '%s\n' "$END"
}

# profiles that exist; default to creating ~/.bashrc if none do
target_profiles() {
  local any=0
  for f in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$f" ] && { echo "$f"; any=1; }
  done
  [ "$any" = 1 ] || { touch "$HOME/.bashrc"; echo "$HOME/.bashrc"; }
}

install_hook() {
  local f
  while IFS= read -r f; do
    grep -qF "$BEGIN" "$f" 2>/dev/null && continue
    { printf '\n'; block; } >> "$f"
  done < <(target_profiles)
}

remove_from() {
  local f="$1"
  [ -f "$f" ] || return 0
  grep -qF "$BEGIN" "$f" 2>/dev/null || return 0
  awk -v b="$BEGIN" -v e="$END" '
    $0==b { skip=1 }
    skip==0 { print }
    $0==e { skip=0 }
  ' "$f" > "$f.tbtmp" && mv "$f.tbtmp" "$f"
}

remove_hook() {
  for f in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do remove_from "$f"; done
}

case "${1:-}" in
  install)          install_hook ;;
  remove)           remove_hook ;;
  remove-if-empty)  ls -d "$HUB"/*/bridge.path >/dev/null 2>&1 || remove_hook ;;
  *) echo "usage: hook.sh install|remove-if-empty|remove" >&2; exit 2 ;;
esac
