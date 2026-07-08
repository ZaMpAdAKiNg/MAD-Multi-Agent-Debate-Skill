# Example (synthetic) — `mad` output

> ⚠️ **Illustrative, hand-written.** This is not a captured real debate — it only shows
> the shape of the synthesis. Real debates are saved under `$MAD_DEBATE_DIR`, outside the repo.
> Prompts default to English; run `MAD_LANG=pt mad "..."` for a Portuguese debate.

Command:

```bash
mad "Job queue: Postgres LISTEN/NOTIFY (reuse the DB) or a dedicated broker (Redis/SQS)?"
```

Output (`stdout`):

---

# MAD Synthesis — 20260101-120000

> Question: Job queue: Postgres LISTEN/NOTIFY (reuse the DB) or a dedicated broker (Redis/SQS)?

> Debaters: Claude (Opus) ⇄ Codex (GPT) · judge: claude · transcript: `~/.local/share/mad/debates/20260101-120000-job-queue`

---

## Convergence (high confidence)

- Start with **Postgres** while volume is low/medium: one less dependency, you can enqueue
  and mutate the domain in the **same transaction** (no dual-write), and inspection is
  trivial via SQL.
- The pain of Postgres-as-a-queue shows up under **high fan-out and aggressive polling** —
  lock contention and wasted connections. It's not a theoretical limit, it's operational.

## Divergences (for the decision-maker to decide)

1. **When to migrate.** One side wants to switch to a dedicated broker only when a real SLO
   breaks (dispatch latency, throughput); the other wants to leave earlier, at the first
   sign of contention, because migrating a queue under traffic is expensive. *It matters*
   because it decides whether you pay complexity now or migration risk later.
2. **`SELECT ... FOR UPDATE SKIP LOCKED` vs `LISTEN/NOTIFY`.** One prefers polling with
   `SKIP LOCKED` (durable, survives reconnects); the other accepts `NOTIFY` for lower
   latency. *It matters* because `NOTIFY` drops events if nobody is listening.

## Recommendation

Start on Postgres with `SELECT ... FOR UPDATE SKIP LOCKED` and an explicit jobs table.
Instrument dispatch latency and queue depth from day one. Switch to a dedicated broker when
a measured SLO breaks — not before.

## Risks and what to validate before committing

- Define the dispatch SLO now, otherwise "when it hurts" never arrives objectively.
- Test behavior under reconnect / dead worker (stuck job vs re-delivered).
- Estimate connections: a queue on the app's pool can starve web requests.
