# Together Bridge 🌉

A shared folder that syncs between you and one partner over a private GitHub repo.
Drop a file in `shared/`, your partner gets it. No copy-paste, no Slack, no email.

## Everyday use
| I want to… | Double-click | Or tell your agent |
|------------|--------------|--------------------|
| Share a file | *(just drop it in `shared/`)* | "share this on the bridge" |
| Get their latest | `scripts/refresh` | "refresh the bridge" |
| Leave the bridge | `scripts/clear` | "leave the bridge" |

Files live in **`shared/`**. That's the whole thing.

## Rules
- Never put secrets in here (`.env`, keys, tokens) — this folder is shared and lives in git history.
- One file per thing you're sharing. Don't co-edit the same file simultaneously.

First-time setup was handled by `setup.sh`. See `AGENTS.md` for how agents drive it.
