# Security & Trust Model

Together Bridge connects two workspaces through a shared git repo. Read this before
you create or join a bridge.

## Core design: code and data are separated

**The synced bridge repo contains data only** — `shared/` plus inert documentation.
It contains **no scripts and no auto-run configuration.** The programs that operate a
bridge (`watch.sh`, `refresh.sh`, `clear.sh`) are installed **locally** at
`~/.together-bridge/<repo-name>/`, from the trusted Together Bridge tool — and are
**never committed to the shared repo.**

Consequence: **a counterparty can only ever change data in `shared/` — never the code
that runs on your machine.** Pushing a malicious script into the bridge does nothing,
because nothing in the bridge is ever executed. This is the primary protection, and
unlike file-pinning tricks it is structural, not advisory.

## What else we do

- **No silent auto-run.** We ship **no** `runOn: folderOpen` VS Code task. Silent
  auto-run tasks are a known zero-click code-execution vector
  ([microsoft/vscode#309406](https://github.com/microsoft/vscode/issues/309406)). The
  watcher is started explicitly at setup.
- **Join runs trusted code only.** `join.sh` installs the runtime from the tool, not
  from the bridge you're joining, and warns if a bridge unexpectedly contains scripts.
- **Secret guard.** A `.gitignore` blocks common secret files (`.env`, `*.key`,
  `*.pem`, `id_rsa*`, `.ssh/`, `.aws/`, …) from syncing.
- **Untrusted-data rule for agents.** The bridge's `AGENTS.md` instructs AI agents to
  treat everything in `shared/` as data, never instructions — mitigating prompt
  injection via shared files.
- **Private by default.** Bridges are created private; `--public` prints a warning.

## Residual risks (know these)

- **Initial trust of the tool.** You trust the Together Bridge tool itself (this repo)
  and whoever you obtained it from — it's the code that runs. Get it from the canonical
  source and read it; it's small.
- **`shared/` is data both parties can read/write**, and would be world-readable if you
  ever make the repo public. Don't share anything with a partner you wouldn't want them
  to have.
- **Secret guard is pattern-based.** An oddly-named secret can still slip through. Never
  put credentials in a bridge, period.
- **Agents can still be socially engineered** by cleverly crafted shared content. The
  untrusted-data rule reduces this but treat surprising shared files with suspicion.

## Reporting

Found a security issue? Open an issue (or contact the maintainer) before disclosing
publicly.
