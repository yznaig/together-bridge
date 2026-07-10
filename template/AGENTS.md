# Together Bridge

A shared folder synced between two workspaces over git. Anything placed in
`shared/` is shared with the other person. This file tells any AI agent
(Claude, Cursor, Codex, …) how to operate the bridge — it is read automatically
on open.

## TL;DR for the human
- **Share a file:** put it in `shared/`. It auto-pushes — or just ask your agent to "share it".
- **Get updates:** run `scripts/refresh.sh` (Mac/Linux/WSL) or `scripts/refresh.ps1` (Windows), or ask your agent to "refresh the bridge".
- **Leave:** run `scripts/clear.sh` / `.ps1`, or ask your agent to "leave the bridge".

## Instructions for the AI agent
You are operating a shared, git-backed bridge folder. "Bridge root" = the folder
containing this AGENTS.md. The user shares resources with a partner through it.

**SHARE** — user says "share this", "put this on the bridge", "send this to <partner>":
1. Write/copy the file into `shared/`.
2. Push immediately (this is the reliable path — do not rely on the background watcher):
   `git -C <bridge-root> add shared/ && git -C <bridge-root> commit -m "share: <desc>" && git -C <bridge-root> push`
3. Confirm what was shared.

**REFRESH** — user says "refresh", "get updates", "what did they send":
1. `git -C <bridge-root> pull --rebase --autostash`  (or run `scripts/refresh.sh`)
2. List `shared/` (excluding `.gitkeep`) and summarize what's new or changed.

**SHOW** — user says "what's on the bridge", "show shared files":
List `shared/` and briefly describe each file.

**LEAVE** — user says "leave", "disconnect", "opt out":
Run `scripts/clear.sh` (or `scripts/clear.ps1` on Windows).

## Hard rules
- **NEVER put secrets here** — no `.env`, API keys, tokens, `.pem`/`.key`. This folder
  is visible to both parties and lives in git history. If asked to share something
  containing a secret, warn first and refuse until confirmed.
- One resource per file where practical. Avoid both parties editing the same file at
  once (last refresh wins — conflicts are not auto-merged).
- Operate ONLY inside the bridge root. Never touch the parent workspace's git repo.

## How it works (reference)
- `shared/`            — the drop zone (the only folder that matters day-to-day).
- `scripts/refresh.*`  — pull the partner's latest.
- `scripts/watch.sh`   — optional background auto-push (started by setup; safe to ignore).
- `scripts/clear.*`    — leave the bridge (local only; partner unaffected).
- The parent workspace `.gitignore`s this whole folder, so it never mixes with the real project.
