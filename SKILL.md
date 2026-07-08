---
name: mad
description: Multi-Agent Debate (MAD) for high-stakes architecture decisions — makes Claude (Opus) and Codex (GPT) debate the same question in adversarial rounds (blind proposals → critique → revision → synthesis), exploiting model diversity to surface trade-offs and risks. Use when the user asks to "mad", "/mad", "debate this", "multi-agent debate", "have Codex debate me", "debate isso", "discussão multi-agente", or for ANY expensive/irreversible architecture decision where hearing two strong models with different blind spots beats one opinion. Do NOT use for trivial tasks or direct implementation.
---

# MAD — Multi-Agent Debate (Claude ⇄ Codex)

The value comes from **model diversity**: Claude and Codex fail differently. Where the two **disagree** is exactly where the trade-off/risk that deserves the decider's attention lives. The final synthesis isn't "who won" — it's **convergence (high confidence) + divergences (your call)**.

All the work lives in the `mad` engine (single source of truth, identical under Claude Code and Codex). This skill is only the trigger.

## How to run

1. Take the user's architecture question. If they didn't give a clear, debatable one, **ask for it first** — a specific sentence (e.g. "event-sourcing or CRUD for the orders module?").
2. Run the engine via Bash, passing the question as an argument:

   ```bash
   mad "<the user's architecture question>"
   ```

   - Shallow debate (1 critique round): `mad --rounds 1 "..."`
   - The default is **adaptive**: it stops when the models converge or after 2 rounds.
   - Each call spends real tokens on both sides and takes ~1-3 min. Warn the user if it'll be slow.
   - Prompts default to English. For a debate in Portuguese: `MAD_LANG=pt mad "..."`.

3. `stdout` is the **final synthesis**, already formatted (convergence / divergences / recommendation / risks). Present it to the user. The full round-by-round transcript is saved under `$MAD_DEBATE_DIR/<timestamp>-<slug>/` (XDG default) — mention the path so they can revisit it.

## When NOT to use it

Trivial decisions, direct implementation tasks, or anything one opinion settles. MAD is expensive (two models, several rounds) — reserve it for architecture decisions that cost a lot if you get them wrong.

## Notes

- Default judge = Claude (`MAD_JUDGE=codex` flips it). The judge has a mild bias toward its own side; that's why the transcript is saved — the user can read the raw debate.
- Overrides: `MAD_LANG`, `MAD_OWNER`, `MAD_CLAUDE_MODEL`, `MAD_CODEX_MODEL`, `MAD_CLAUDE_BIN`, `MAD_CODEX_BIN`, `--rounds N`, `-f file.md` (question from a file).
- Test the flow without spending tokens: `MAD_DRY_RUN=1 mad "..."`.
