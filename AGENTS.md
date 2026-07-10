# Together Bridge — install & operate

Together Bridge is a **shared sync folder between two workspaces**, backed by a
GitHub repo. Drop a file in the bridge's `shared/` folder and the other person
gets it — no copy-paste, no email. It works with any agent-driven editor:
Claude Code, Cursor, Codex, or plain VS Code.

This file tells an AI agent how to install and drive it. (Human? See `README.md`.)

---

## Step 1 — Which task is this?

**A) Joining a bridge someone already made** → install NOTHING from this repo.
The host sent a repo URL. From the project folder you want to share from, run:

```
git clone <their-url>.git bridge && bash bridge/setup.sh
```

Everything needed (`setup.sh`, the bridge's own `AGENTS.md`) already lives inside
that bridge repo. Done — files go in `bridge/shared/`.

**B) Hosting your own bridges (this repo is the tool)** → continue below.

---

## Step 2 — Host install

**Requirements:** `git` and the GitHub CLI (`gh`) installed, and `gh auth login`
completed. That auth is the one unavoidable human step — if `gh auth status`
fails, tell the user to run `gh auth login` and stop.

### If the user is on Claude Code
Register the `/together-bridge` slash command globally:

```
bash install.sh
```

The user then creates a bridge in any workspace with:  `/together-bridge`

### Any other agent (Cursor, Codex, …)
No slash command — run the engine directly. **Show a `--dry-run` plan first**, get
a yes, then run for real:

```
bash host-provision.sh --name <repo-name> --partner <partner-github-username> --path ./bridge
```

Flags: `--public` (default private) · `--dry-run` (print the plan, change nothing).
It creates the GitHub repo, scaffolds `./bridge`, wires the parent workspace to
ignore it, pushes, invites the partner, and starts the auto-push watcher. It prints
an invite blurb — hand that to the partner verbatim.

---

## Step 3 — Operating a live bridge

Every bridge created above contains its **own** `AGENTS.md` that governs day-to-day
use; defer to it once a bridge exists. In short:

- **Share:** put a file in `bridge/shared/` (or ask the agent to) → auto-pushed.
- **Refresh:** `bash bridge/scripts/refresh.sh` → pull the partner's latest.
- **Leave:** `bash bridge/scripts/clear.sh` → disconnect this machine only; the
  GitHub repo and the partner are untouched.

---

## Hard rule — never share secrets

Never place `.env`, API keys, tokens, or `.pem`/`.key` files in a bridge — the
folder is shared and lives in git history. The template ships a `.gitignore` that
blocks the common ones, but agents must refuse to share secret-bearing files
regardless, warn the user, and suggest a proper secret channel.

---

## What's in this repo

| Path | What |
|------|------|
| `install.sh` | Registers `/together-bridge` into `~/.claude/` (Claude Code). |
| `host-provision.sh` | Tool-agnostic engine: create + scaffold + push a new bridge. |
| `command/together-bridge.md` | The `/together-bridge` slash command (Claude Code). |
| `template/` | Exactly what gets scaffolded into each new bridge. |
| `template/AGENTS.md` | The brain that ships *inside* every bridge. |
