# mad — Multi-Agent Debate

Make **Claude (Opus)** and **Codex (GPT)** debate the same architecture question in
adversarial rounds — *blind proposals → adversarial critique → revision → synthesis* —
then have a judge consolidate the result.

The value comes from **model diversity**: Claude and Codex fail in different ways.
Where the two **disagree** is exactly where the real trade-off or risk lives. The final
synthesis isn't "who won" — it's **convergence (high confidence) + divergences (your call)**.

Ships as two things that share one source of truth:

- **`bin/mad`** — a single Bash engine (the whole tool).
- **`SKILL.md`** — a trigger so an agent (Claude Code / Codex) can invoke the engine.

## Protocol (adaptive)

| Phase | What happens |
|-------|--------------|
| Round 0 | Both models answer **blind** — neither sees the other. |
| Round 1..N | Each model **critiques the other adversarially** and revises its own take. Stops early when they converge, otherwise after N rounds (default 2). |
| Synthesis | A judge consolidates: convergence / divergences / recommendation / risks. |

## Requirements

Both CLIs must be installed **and authenticated** — this is the real barrier to entry,
not the install:

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — provides `claude`
- [Codex CLI](https://github.com/openai/codex) — provides `codex`

The engine is a POSIX-style Bash script. It runs anywhere Bash does: macOS, Linux, and
Windows via WSL2 or Git Bash.

## Install

```bash
git clone https://github.com/ZaMpAdAKiNg/mad.git
cd mad
./install.sh
```

`install.sh` is non-destructive: it symlinks `bin/mad` into `~/.local/bin`, checks that
the target dir is on your `PATH`, verifies both CLIs are reachable, and **prints** (never
auto-copies) the one line to wire up `SKILL.md` for your agent runtime.

### Per-platform notes

<details>
<summary><strong>macOS</strong></summary>

```bash
git clone https://github.com/ZaMpAdAKiNg/mad.git && cd mad
./install.sh
```

macOS does not include `~/.local/bin` on the `PATH` by default. If the installer warns
about it, add this to `~/.zshrc` (or `~/.bash_profile`) and restart your shell:

```bash
export PATH="$HOME/.local/bin:$PATH"
```
</details>

<details>
<summary><strong>Ubuntu / Linux</strong></summary>

```bash
sudo apt-get update && sudo apt-get install -y git      # if needed
git clone https://github.com/ZaMpAdAKiNg/mad.git && cd mad
./install.sh
```

On most distros `~/.local/bin` is already on the `PATH`. If the installer says otherwise,
add to `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```
</details>

<details>
<summary><strong>Windows</strong></summary>

The engine needs a Bash environment. Two supported paths:

**WSL2 (recommended).** Install both CLIs *inside* your Linux distro, then follow the
Ubuntu steps above:

```powershell
wsl --install        # first time only, then reboot
```

```bash
# inside the WSL2 shell
git clone https://github.com/ZaMpAdAKiNg/mad.git && cd mad
./install.sh
```

**Git Bash (alternative).** In the Git Bash shell:

```bash
git clone https://github.com/ZaMpAdAKiNg/mad.git && cd mad
MAD_BIN_DIR="$HOME/bin" ./install.sh
```

Make sure `claude` and `codex` are reachable from the same Bash session, and that your
install dir is on `PATH`. On Git Bash, `ln -s` may copy the file instead of creating a
real symlink; to update later, delete the installed copy first (or run with
`MSYS=winsymlinks:nativestrict ./install.sh`). Native PowerShell/CMD are **not**
supported — run `mad` from WSL2 or Git Bash.
</details>

## Enable the skill (Claude Code & Codex)

`SKILL.md` is a plain skill file with YAML front-matter — the **same file works in both
Claude Code and Codex**, which share the skill format. `install.sh` prints these lines;
you can also link it by hand:

```bash
# Claude Code (global skills)
mkdir -p ~/.claude/skills/mad && ln -sf "$PWD/SKILL.md" ~/.claude/skills/mad/SKILL.md

# Codex (global skills)
mkdir -p ~/.codex/skills/mad && ln -sf "$PWD/SKILL.md" ~/.codex/skills/mad/SKILL.md
```

The exact skills directory can vary by version/runtime — check yours first. Once it's
linked, ask either agent to *"mad &lt;your architecture question&gt;"* and it runs the engine.

## Usage

```bash
mad "Should I use event-sourcing or CRUD for the orders module?"
mad -f question.md              # question from a file
echo "monolith or services?" | mad
mad --rounds 1 "..."            # shallow debate (single critique round)
MAD_DRY_RUN=1 mad "..."         # mock run — spends no tokens, exercises the flow
MAD_LANG=pt mad "..."           # run the debate in Portuguese
```

`stdout` is the final synthesis. The full round-by-round transcript is saved under
`$MAD_DEBATE_DIR/<timestamp>-<slug>/` so you can read the raw debate — the judge has a
mild bias toward its own side, so the transcript is the tie-breaker.

## Configuration (env)

| Var | Default | Meaning |
|-----|---------|---------|
| `MAD_LANG` | `en` | prompt language (`en` or `pt`) |
| `MAD_OWNER` | `decision-maker` | how the judge addresses whoever decides |
| `MAD_JUDGE` | `claude` | who writes the synthesis (`codex` to flip) |
| `MAD_CLAUDE_MODEL` / `MAD_CODEX_MODEL` | session default | model per side |
| `MAD_CLAUDE_BIN` / `MAD_CODEX_BIN` | `claude` / `codex` | binary names/paths |
| `MAD_DEBATE_DIR` | `${XDG_DATA_HOME:-~/.local/share}/mad/debates` | where transcripts go |

Prompts ship in English and Portuguese (both models are bilingual); set `MAD_LANG`, or
edit `bin/mad` to add another language.

## When *not* to use it

Trivial decisions, direct implementation tasks, or anything one opinion settles. MAD is
expensive (two models, several rounds). Reserve it for architecture decisions that cost a
lot if you get them wrong.

## License

MIT © ZaMpA
