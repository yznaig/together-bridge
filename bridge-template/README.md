# Bridge

This is a **Together Bridge** — a shared sync folder. Drop files in `shared/` and the
other person gets them. This repo holds *data only*; the tools that run it live locally
on each machine (`~/.together-bridge/<repo-name>/`).

- **Share:** put a file in `shared/` (auto-pushed by the local watcher).
- **Get updates:** `bash ~/.together-bridge/<repo-name>/refresh.sh`
- **Leave:** `bash ~/.together-bridge/<repo-name>/clear.sh`

**Never put secrets in here** (`.env`, keys, tokens) — the folder is shared and lives in
git history. See the Together Bridge tool's `SECURITY.md` for the trust model.
