---
name: actario-capture-chat
description: "Capture the conversation you are in right now into Actario, then distil it into decisions, facts and open questions for the user to confirm. Use when asked to save, capture, export, distil, analyse, or hand off this conversation to Actario or to another agent."
---

# Capture this conversation into Actario

Write a faithful record of the conversation you are in, hand it to the
`actario` MCP server, and — separately — distil it into entries the user will
confirm.

You produce **two things, and they stay two things**:

| | what it is | rule |
|---|---|---|
| the record | what was actually said | **no summarising, no grading, no redacting** |
| the DAF | your analysis of it | summarise here, and only here |

The record is raw material; the analysis is derived from it. Collapsing them
destroys the thing that makes the record worth keeping — a conversation
pre-compressed into conclusions cannot be re-analysed later, by better rules
or by anyone else.

## Before anything: is the server there?

The tools are `capture`, `list_runs`, `read_run`, `submit_daf`, `link` and
`doctor` on the `actario` MCP server. If they are not available in this
session, say so plainly and stop — do not fall back to writing files into
`~/.actario/inbox/` and asking the user to run a terminal command. That was
the old path and it strands the work half-done.

If a tool answers `not_linked`, this machine has no workspace configured. Ask
the user for their API URL and a capture token, then call `link`. Never guess
a token.

## Part 1 — the record

### The one rule that matters most: report, do not clean

The pipeline behind `capture` does everything downstream — unconditional
credential redaction, quality scoring, packing, upload.

- **Do not redact.** Write what was actually said. The hard redaction rules
  run on every record and cannot be disabled by any flag, including by this
  skill. Redacting here would create a second, weaker place for that
  guarantee to live, and a secret you quietly paraphrase away is a leak
  Actario can no longer report. (Do not *introduce* a credential that was
  never in the conversation, obviously.)
- **Do not score or grade the session.** No quality field, no verdict.
- **Do not summarise into conclusions.** Record turns, not your opinion of
  them. Your opinion goes in the DAF, in part 2.

### Build the record

```jsonc
{
  "format": "distill.chat/v1",            // required, exactly this
  "platform": "cowork",                   // or claude_code, claude_desktop
  "title": "<what this conversation was about>",
  "model": "<the model you are, if you know it>",
  "project": "<project name, only if explicitly known>",
  "repo_path": "<absolute repo path, only if explicitly known>",
  "started_at": "2026-09-16T11:02:00+08:00",
  "ended_at": "2026-09-16T11:30:00+08:00",
  "outcome": "completed",                 // completed | interrupted | failed | ongoing
  "turns": [
    { "role": "user", "at": "…", "content": "…" },
    { "role": "assistant", "at": "…", "content": "…",
      "tools": [ { "name": "Edit", "summary": "fixed the RLS policy" }, "Bash" ] }
  ]
}
```

Only `format` and `turns[].{role, content}` are required. Everything else is
optional and is treated as *absent by capability* when missing — leaving a
field out costs no quality points, so omit anything you do not actually know.

Field rules, in order of how badly getting them wrong hurts:

- **`project` / `repo_path`: only when explicitly known.** These bind the
  record to an agent identity. A conversation id is not a project and a
  guessed path is worse than none — a decision filed under the wrong agent is
  worse than a decision filed under no agent. If the user never named a
  project or repo, omit both.
- **`tools`: names and a short summary, never parameters.** Record that you
  ran `Edit`, not what you passed to it. Never reconstruct arguments from
  memory: invented parameters read as fact downstream. A bare string is fine
  when you have nothing to add.
- **`at`: only real timestamps.** Omit rather than estimate. Missing
  timestamps are free; wrong ones corrupt ordering-based analysis.
- **`content`: faithful.** User turns verbatim where you have them. Your own
  turns condensed to substance — the reasoning, the decision, the reason for
  the decision, what was rejected and why — because that is what Actario
  extracts. Do not promote a paraphrase to a quotation, and do not add
  reasoning you did not actually give at the time.
- **`outcome`**: `ongoing` is the honest answer while the user is still
  working. Omit if unsure.
- **`role`**: `user` and `assistant`. Other roles are kept as written.

The record is a *report*, not a transcript, and its fidelity is exactly your
fidelity. That is the price of this channel and the reason for every rule
above.

### Hand it over

```
capture({ record: <the object above>, slug: "short-name" })
```

Add `dry_run: true` first if the user wants to see the score before anything
is uploaded; the record stays in the inbox either way and the next real
capture includes it (the server deduplicates by content, so this is safe).

A successful call returns `upload_id`, `bundle_id` and a `report`. Relay the
report's own numbers — quality score, runs kept, parse level, tool calls, and
the **redaction line**. If anything was redacted, say so: that is the user's
signal that a credential was in the conversation and may need rotating.

## Part 2 — the analysis

This runs here, on the user's own subscription, so it costs nothing extra.
Do it **after** capture succeeds — never instead of it, and never folded into
it. A model that stalls here must not be able to cost someone their capture.

```
list_runs({})                      → run_hash, title, turn counts, daf_template
read_run({ run_hash: "…" })        → one run's turns, for each run you will cite
submit_daf({ daf: <your DAF> })    → validates, uploads, returns the verdict
```

Read `references/analysis-rubric.md` before writing your first DAF. The three
rules that are not recoverable if you get them wrong:

1. **Every entry needs `source_turn_idx`.** Anchors that do not resolve are
   discarded server-side — a claim with no source is worse than no claim,
   because it will be believed.
2. **Anchor with `(run_hash, turn_idx)`, never a UUID and never `run_ref`.**
   `run_hash` is the field at the top of each run `read_run` returns — copy
   the whole value. `run_ref` is shown for orientation only: one agent session
   id is stamped on every run split out of it, so several runs share it and
   anchoring by it lands the claim on a conversation it did not come from.
3. **Precision over recall.** A thin, correct analysis is useful. A thorough
   one with three fabrications teaches the user to distrust all of it. If you
   are unsure whether something was decided or only discussed, it is a
   `question`, not a `decision`.

**Read the runs you cite.** `list_runs` gives you titles and counts, not
content; anchoring to a turn you have not read through `read_run` is guessing.

One case deserves care that does not arise elsewhere: **you are analysing a
conversation you were part of.** Record what was decided, not what you would
now prefer had been decided, and do not promote your own suggestions into
decisions the user never accepted. The rubric's test is the right one — could
someone act differently tomorrow because of it?

## Part 3 — report back

Two sets of numbers, kept apart:

- **Capture**: quality score, runs kept, parse level, tool calls, redactions.
- **Analysis**: entries by type, and the validation line. If entries were
  dropped for unresolvable anchors, say how many and treat it as a signal
  about your own output rather than the user's problem.

Everything that lands is **pending**. Say so, and give the user the
`review_at` link `submit_daf` returns. You cannot mark anything confirmed and
must not describe it as final — a human confirming each claim against its
source turns is the only thing that lets it reach another agent.

Records are **not** deleted after capture: the server deduplicates on content
hash, so re-reading one is free, and a file the user can still open is easier
to trust than one that vanished.

## Expect a capture score in the low 80s, or higher

A narrative record declares no capabilities beyond roles, content and tool
names, so missing branches, artifacts and timestamps are reported as `not
available` with no score penalty. The remaining gap is real: a written account
is worth less than a captured transcript. Do not try to close it by adding
fields you are not sure of.

The score measures the **capture**, not the analysis. Two separate numbers;
do not merge them into one verdict.
