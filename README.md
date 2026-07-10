# Together Bridge

A shared folder that syncs between two people's editors over a GitHub repo. Drop a
file in `shared/`, your partner gets it — no copy-paste, no email. Works with Claude
Code, Cursor, Codex, or plain VS Code.

The trick: the sync mechanism is just git, and each bridge carries its own
`AGENTS.md`, so **any** AI agent that opens the folder already knows how to run it.

## Joining a bridge someone made

Nothing to install. They'll send you a repo URL:

```
git clone <url>.git bridge && bash bridge/setup.sh
```

Then drop files in `bridge/shared/`. Get their updates with `bash bridge/scripts/refresh.sh`.

## Hosting your own bridge

You need `git` + the GitHub CLI (`gh auth login` done once).

- **Claude Code:** `bash install.sh`, then run `/together-bridge` in any workspace.
- **Any agent / manual:** `bash host-provision.sh --name my-bridge --partner <their-github-user>`
  (add `--dry-run` to preview).

Either way you get a shareable invite to send your partner.

## Everyday use

| Do this | Command | …or just tell your agent |
|---------|---------|--------------------------|
| Share a file | put it in `shared/` (auto-pushes) | "share this on the bridge" |
| Get updates | `scripts/refresh.sh` / `.ps1` | "refresh the bridge" |
| Leave | `scripts/clear.sh` / `.ps1` | "leave the bridge" |

## How it stays out of your way

The bridge lives in a subfolder your real project `.gitignore`s, so it never mixes
with your actual repo. Sharing is **auto-push on add**; receiving is **manual pull**
(you take updates on your terms — nothing pings you).

## Never share secrets

The bridge is shared and lives in git history. Don't put `.env`, API keys, or private
keys in `shared/`. A `.gitignore` blocks the common ones as a backstop, but treat it
as a public space.
