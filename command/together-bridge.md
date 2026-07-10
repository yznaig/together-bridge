---
name: together-bridge
description: Set up or join a Together Bridge — a shared sync folder between two workspaces over a private GitHub repo. Drop files in shared/, the other person gets them, no copy-paste. Tool-agnostic (Claude Code, Cursor, Codex, VS Code). Use when the user says "set up a bridge", "share a folder with someone", "together bridge", or "/together-bridge join <url>".
---

# /together-bridge — Shared Sync Bridge

You are provisioning or joining a **Together Bridge**: a folder that syncs between
two people's workspaces over a private GitHub repo. Files dropped in `shared/` are
shared automatically. No copy-paste, no email.

## Step 0: Locate the package

Find the together-bridge package (contains `host-provision.sh` and `template/`):
- If installed globally (via `install.sh`): `~/.claude/together-bridge/`
- Otherwise: the directory this command lives beside — look for `host-provision.sh` next to a `template/` folder.

Use whichever exists. Call its scripts by absolute path.

## Step 1: Determine the mode

- The user typed `join <url>` (or gave a GitHub URL, or said "join") → **JOIN mode** (Step 3).
- Otherwise → **HOST mode** (Step 2).

If genuinely ambiguous, ask once: "Creating a new bridge, or joining one your partner made? (paste their repo URL to join)".

---

## Step 2: HOST mode — create a new bridge

**2a. Preflight.** Run `gh auth status`. If not logged in, tell the user to run `gh auth login` and stop. This is the one unavoidable human step.

**2b. Collect inputs** (one prompt, skip anything already given):
> Name for the bridge repo? · Partner's GitHub username? · Where should the local `bridge/` folder go? (default: `./bridge` in the current workspace) · Private or public? (default: private)

**2c. Dry-run first.** Run `host-provision.sh` with `--dry-run` and the collected args, show the user the plan (repo to create, path to scaffold, partner to invite). Get a yes.

**2d. Provision.** Run `host-provision.sh` for real:
```
bash <package>/host-provision.sh --name "<repo>" --partner "<user>" --path "<dest>" [--public]
```
It creates the repo, scaffolds from `template/`, wires the parent `.gitignore`, pushes, invites the partner, and starts the watcher.

**2e. Hand off.** Present the partner-invite blurb the script prints, verbatim, in a copy-paste block. Remind the user: the partner must **accept the GitHub invite** before they can push.

---

## Step 3: JOIN mode — join a partner's bridge

**3a.** Confirm the repo URL (from the `join <url>` arg or ask). Confirm they've **accepted the GitHub invite** — if not, point them to `<url>/invitations`.

**3b.** Choose where the bridge lands (default: `./bridge` in the current workspace). Ensure that path doesn't already exist.

**3c.** Clone and set up:
```
git clone <url>.git <dest> && bash <dest>/setup.sh
```
`setup.sh` wires the parent `.gitignore`, verifies push access, wires the folder-open watcher, and starts auto-push.

**3d.** Confirm: bridge is live, files go in `<dest>/shared/`.

---

## Step 4: Verify (both modes)

Quick smoke test, offer to run it:
1. Write a tiny `shared/hello-from-<name>.md`.
2. Push it (host/join watcher will, or push manually).
3. Tell the user: "Ask your partner to refresh — they should see `hello-from-<name>.md`."

Report what was created: repo URL, local path, watcher status, and the partner blurb (host mode).

---

## Ongoing operation (after setup)

Once a bridge exists in a workspace, `AGENTS.md` inside it governs day-to-day use.
When the user asks you to:
- **Share X** → write/copy X into `<bridge>/shared/`, then `git -C <bridge> add shared/ && git -C <bridge> commit -m "share: X" && git -C <bridge> push`. Don't rely on the watcher — push explicitly.
- **Refresh / "what did they send"** → `git -C <bridge> pull --rebase --autostash`, then list & summarize `shared/`.
- **Leave** → run `<bridge>/scripts/clear.sh`.

**Never** put secrets in `shared/` (`.env`, keys, tokens) — the folder is shared and lives in git history. Warn and refuse if asked.

---

## Making it reusable everywhere

To use `/together-bridge` in any workspace (not just Command HQ), run once:
```
bash <package>/install.sh
```
This copies the command + package into `~/.claude/`, so the skill is globally available.

---

## Error handling

| Situation | Action |
|-----------|--------|
| `gh` not installed | Point to https://cli.github.com and stop. |
| Not logged in to GitHub | Tell user to run `gh auth login`, stop. |
| Dest path exists | Ask for a different path or confirm removal. |
| Partner can't push | They haven't accepted the invite — send them `<url>/invitations`. |
| Push fails (offline) | Watcher retries on next change; `refresh`/manual push once back online. |
| Existing `.vscode/tasks.json` on partner side | `setup.sh` won't overwrite it — tell them to add a `together-bridge: watch` task or run `scripts/watch.sh` manually. |
| User tries to share a secret | Refuse, explain the folder is shared + in git history, suggest a proper secret channel. |
