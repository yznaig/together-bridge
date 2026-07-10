# Together Bridge

A shared folder that syncs between two people's editors over a GitHub repo. Drop a
file in `shared/`, your partner gets it — no copy-paste, no email. Works with Claude
Code, Cursor, Codex, or plain VS Code.

The trick: the sync mechanism is just git, and each bridge carries its own
`AGENTS.md`, so **any** AI agent that opens the folder already knows how to run it.

## Joining a bridge someone made

Join through **this tool** (not scripts inside the bridge — that's what keeps you safe).
They'll send you a repo URL:

```
# with this tool:
git clone <this-tool-url> tb && bash tb/join.sh <their-bridge-url>
# or on Claude Code:
/together-bridge join <their-bridge-url>
```

Then drop files in `bridge/shared/`. Get their updates with
`bash ~/.together-bridge/<repo-name>/refresh.sh`.

## Hosting your own bridge

You need `git` + the GitHub CLI (`gh auth login` done once).

- **Claude Code:** `bash install.sh`, then run `/together-bridge` in any workspace.
- **Any agent / manual:** `bash host-provision.sh --name my-bridge --partner <their-github-user>`
  (add `--dry-run` to preview).

Either way you get a shareable invite to send your partner.

## Everyday use

The operating scripts live locally at `~/.together-bridge/<repo-name>/`.

| Do this | Command | …or just tell your agent |
|---------|---------|--------------------------|
| Share a file | put it in `shared/` (auto-pushes) | "share this on the bridge" |
| Get updates | `~/.together-bridge/<repo-name>/refresh.sh` | "refresh the bridge" |
| Leave | `~/.together-bridge/<repo-name>/clear.sh` | "leave the bridge" |

## How it stays out of your way

The bridge lives in a subfolder your real project `.gitignore`s, so it never mixes
with your actual repo. Sharing is **auto-push on add**; receiving is **manual pull**
(you take updates on your terms — nothing pings you). The bridge repo holds **data
only** — the code that runs lives locally, so a partner can never push code to you.

## Security & trust

Together Bridge separates **code from data**: the synced repo holds data only, while the
scripts that run live locally (installed from this trusted tool). So a counterparty can
change what's in `shared/` but **never the code that runs on your machine.** On top of
that: no silent auto-run task, a secret-guard `.gitignore`, and AI agents are told to
treat shared content as untrusted data. Read **[SECURITY.md](SECURITY.md)** before
creating or joining a bridge.

## Never share secrets

The bridge is shared and lives in git history. Don't put `.env`, API keys, or private
keys in `shared/`. A `.gitignore` blocks the common ones as a backstop, but treat it
as a public space.
