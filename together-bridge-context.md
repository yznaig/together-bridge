# Together Bridge — Full Context & Onboarding

> An intro to **Together Bridge**, the tool we're going to use to share files.
> Read top to bottom once; it's everything you need. If you use an AI coding agent
> (Claude Code, Cursor, Codex), you can also just point it at this file.

Tool repo: **https://github.com/yznaig/together-bridge** (public, MIT-licensed)

---

## 1. What it is (the 30-second version)

Together Bridge gives us a **shared folder that syncs between our two setups**. You
drop a file in a `shared/` folder, and it shows up on my side — and vice versa. No
copy-paste, no email attachments, no Slack DMs of files back and forth.

Under the hood it's just a private GitHub repo wired up so that:
- **Sharing is automatic** — drop a file in `shared/`, it auto-pushes.
- **Receiving is on-demand** — you run "refresh" when you want the latest (nothing
  interrupts you or pings you constantly).

It works the same whether you're in **Claude Code, Cursor, Codex, or plain VS Code**,
on **Mac, Linux, or Windows (WSL)**.

---

## 2. The mental model

Think of it as a **dropbox that lives inside your project**, but git-powered:

```
your-project/                 ← whatever you're working in
├── ...your files...
└── bridge/                   ← the Together Bridge (ignored by your real project)
    └── shared/               ← THE folder that matters. Put files here to share them.
```

- **To share something:** put it in `bridge/shared/`. Done — it syncs to me.
- **To get my latest:** run "refresh."
- Everything outside `shared/` is just plumbing you can ignore.

Two verbs are all you'll ever really use: **share** (drop a file) and **refresh**
(pull mine).

---

## 3. How it actually works (optional, for the curious)

- The bridge is a **private GitHub repo** we both have push access to.
- A tiny local **watcher** notices when you add a file to `shared/` and pushes it
  automatically (commit + push — you don't touch git).
- **Refresh** is a `git pull` under the hood — you decide when to take my updates.
- The repo holds **data only**. The scripts that run live *locally* on your machine
  (installed from the trusted tool), never inside the shared repo. (More on why in
  the Security section — it's the thing that makes this safe.)

You never have to know any git for day-to-day use. Ask your agent, or use the
one-word commands.

---

## 4. Getting set up (one time, ~2 minutes)

### 4a. Prerequisites
- **A GitHub account** — and you'll **accept an invite** I send you (one click). This
  is the only step that can't be automated; it's GitHub granting you access.
- **Git installed** + signed in (`gh auth login`, or your usual git credentials).
- Your editor/agent of choice — nothing new to install there.

### 4b. Accept the invite
I'll send you a bridge repo URL. First, accept the collaborator invite:
`<BRIDGE_URL>/invitations` (or from your GitHub notifications). Without this you
can't push.

### 4c. Join the bridge

**If you use Claude Code** (with the tool installed — see 4d):
```
/together-bridge join <BRIDGE_URL>
```

**Any other agent, or manual:**
```
git clone https://github.com/yznaig/together-bridge tb && bash tb/join.sh <BRIDGE_URL>
```
This clones the bridge as **data only** and installs the operating scripts locally at
`~/.together-bridge/<repo-name>/`. It also starts the auto-push watcher.

That's it. Files now go in `bridge/shared/`.

### 4d. (Optional) Install the tool globally
If you want `/together-bridge` available in every workspace (Claude Code):
```
git clone https://github.com/yznaig/together-bridge tb && bash tb/install.sh
```
Not required just to join — the one-liner in 4c works without it — but handy if you'll
host your own bridges later.

---

## 5. Everyday use

The operating scripts live at `~/.together-bridge/<repo-name>/` (`<repo-name>` is the
bridge's GitHub repo name).

| What you want | Command | …or just tell your agent |
|---------------|---------|--------------------------|
| **Share a file** | put it in `bridge/shared/` (auto-pushes) | "share this on the bridge" |
| **Get my latest** | `bash ~/.together-bridge/<repo-name>/refresh.sh` | "refresh the bridge" |
| **See what's shared** | look in `bridge/shared/` | "what's on the bridge?" |
| **Check it's syncing** | `bash ~/.together-bridge/status.sh` | "is the bridge running?" |
| **Leave the bridge** | `bash ~/.together-bridge/<repo-name>/clear.sh` | "leave the bridge" |

Notes:
- **Sharing is instant-ish:** the watcher pushes within a few seconds of a file
  landing in `shared/`. If you (or your agent) want it pushed *right now*, just ask
  the agent to share it — it'll commit + push immediately.
- **The watcher self-heals.** It runs in the background and restarts itself whenever
  you open a terminal, so after a reboot or a closed terminal it comes back the next
  time you start working. It does **not** survive a reboot entirely on its own — if
  you're unsure, run **status** (above); if it says DOWN, open a new terminal or run
  the restart command it prints. Sharing via your agent always pushes immediately
  regardless of the watcher.
- **Refresh is manual on purpose** — you pull my updates when you're ready, so you're
  never interrupted.
- **Leaving** only disconnects *your* machine. The repo and my side are untouched, and
  you can re-join anytime.

---

## 6. Working with your AI agent

Because each bridge ships its own `AGENTS.md` (read automatically by Claude, Cursor,
Codex, etc.), your agent already knows how to operate it once the folder is open. You
can just say things like:
- "Share the latest build output with my partner."
- "Refresh the bridge and summarize what they sent."
- "Put the file we just made on the bridge."

The agent handles the git mechanics.

---

## 7. Security & trust (please read)

This tool is deliberately built to be safe, but there are a couple of things to
understand:

- **The repo is data-only; code runs locally.** The scripts that execute on your
  machine come from the trusted tool and live *outside* the shared repo. That means I
  (or anyone) **cannot push code that runs on your machine** through the bridge — a
  malicious push could only ever change inert files in `shared/`. This is the core
  safety property.
- **No silent auto-run.** The tool intentionally ships **no** auto-running VS Code
  task (a known malware vector). The watcher is started explicitly.
- **Treat shared files as data, not instructions.** If a file that shows up in
  `shared/` contains text telling your agent to run commands or change settings, that's
  a red flag — agents are instructed to refuse and surface it. (This applies to both of
  us; it's just good hygiene for a shared space.)

Full details: **https://github.com/yznaig/together-bridge/blob/main/SECURITY.md**

---

## 8. The two hard rules

1. **Never put secrets in `shared/`** — no `.env` files, API keys, tokens, private
   keys, passwords. The folder is shared and lives in git history forever. There's a
   `.gitignore` that blocks the common ones automatically, but don't rely on it — just
   don't put credentials in there. If you need to send me a secret, use a proper secret
   channel, not the bridge.
2. **Don't run scripts that arrive *inside* a bridge.** The real operating scripts are
   the ones installed locally at `~/.together-bridge/`. A data-only bridge shouldn't
   contain executable scripts; if one does, don't run it.

---

## 9. Troubleshooting

| Symptom | Fix |
|---------|-----|
| "Permission denied" / can't push or clone | You haven't accepted the GitHub invite yet — go to `<BRIDGE_URL>/invitations`. |
| Files I dropped aren't showing up for my partner | Give the watcher a few seconds; or ask your agent to "share it" (forces an immediate push). Check you're online. |
| I'm not seeing my partner's files | Run **refresh** — receiving is manual, so you pull when ready. |
| Not sure sharing is running | Run `bash ~/.together-bridge/status.sh`. It shows ALIVE/DOWN per bridge. |
| Watcher shows DOWN (after reboot/closed terminal) | Open a new terminal (it self-heals), or run the restart command status prints. Or just ask your agent to share — it pushes directly. |
| `gh` not installed | Install from https://cli.github.com, then `gh auth login`. |
| I want out | `bash ~/.together-bridge/<repo-name>/clear.sh` — disconnects only your machine. |

---

## 10. Cheat sheet

```
JOIN     /together-bridge join <BRIDGE_URL>
         # or: git clone https://github.com/yznaig/together-bridge tb && bash tb/join.sh <BRIDGE_URL>

SHARE    drop a file in  bridge/shared/     (or: "share this on the bridge")
REFRESH  bash ~/.together-bridge/<repo-name>/refresh.sh   (or: "refresh the bridge")
STATUS   bash ~/.together-bridge/status.sh                (is it running?)
LEAVE    bash ~/.together-bridge/<repo-name>/clear.sh
```

---

## 11. FAQ

**Do I need to know git?** No. Drop files and run refresh, or just ask your agent.

**Does it work with my editor?** Yes — Claude Code, Cursor, Codex, and plain VS Code
all work, on Mac/Linux/Windows(WSL).

**Will it mess with my actual project's git?** No. The bridge lives in a `bridge/`
subfolder that your real project is set to ignore. They never mix.

**Is it real-time?** Sharing is near-instant (auto-push). Receiving is when you refresh
— by design, so you're not constantly interrupted.

**Can I be in more than one bridge?** Yes — each gets its own local runtime folder
under `~/.together-bridge/<repo-name>/`.

**What if I want to stop?** Run the leave command. Nothing on my side is affected, and
you can re-join later.

---

*Questions? Ask me, or point your agent at this file and the tool repo.*
