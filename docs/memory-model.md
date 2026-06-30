# Memory Model

## Overview

Memory is split by who reads what, when. The split keeps planning cost flat as run history grows.

| Store | What it is | Read when | Cost |
|---|---|---|---|
| `runs/{exp}/runs.jsonl` | Append-only scan layer, one summary line per run | Every Planner turn | O(history) but ~90 tokens per line |
| `runs/{exp}/{id}/history.json` | Full detail record for one run | On demand, only for interesting runs | Fat, but read rarely |

Both stores live inside the AutoME repo. Static reference files (`docs/loop.md`, `docs/schemas/experiment-schema.md`) are read-mostly.

## File Layout

```
AutoME repo
└── runs/
    ├── exp1/
    │   ├── runs.jsonl                ← per-experiment scan index
    │   ├── 001_0621/
    │   │   ├── history.json          ← full detail record (see docs/schemas/experiment-schema.md)
    │   │   └── config.yaml ◄──────── artifacts.config_ref points here
    │   └── 002_0622/ ...
    └── exp2/ ...

$RUNS_DIR (external — managed by AutoTorch, AutoME does not own these)
└── exp1/
    └── 001_0621/
        ├── checkpoints/
        ├── eval_predictions.csv
        └── breakdown.json            ← AutoME reads this in step 8
```

## The Golden Rule

Each run has one full record: `runs/{exp}/{id}/history.json`.

That record must follow `docs/schemas/experiment-schema.md` and `docs/schemas/experiment-schema.json`. It is the complete audit trail for the run: hypothesis, artifacts, cost, metrics, analysis, and `next_action`.

`runs/{exp}/runs.jsonl` is the compact planner index derived from those full records. Each line must follow `docs/schemas/runs-line-schema.json`, and every field in the line should be copied or summarized from the matching `history.json`.

During routine planning, `runs/{exp}/runs.jsonl` is the planner's source of truth. The agent scans it first and opens a full `history.json` only when it needs detailed context for a specific run.

- The summary line's hyperparam copies (`lr`, `wd`) are projected from `config.yaml` (`training.learning_rate`, `training.weight_decay`).
- If `runs.jsonl` disagrees with a full record, treat it as a consistency bug: inspect the matching `history.json` and `config.yaml`, then repair the projection.

## The Config Rule

Config is stored once, in `runs/{exp}/{id}/config.yaml` — the file AutoTorch actually consumes. The detail record (`runs/{exp}/{id}/history.json`) holds only a `config_ref` pointer, never an inlined copy.

```json
"artifacts": {
  "config_ref": "runs/exp1/001_0621/config.yaml"
}
```

This prevents the record's copy drifting from what really ran. Never inline config values directly into the history record.

## The Schema Rule

Add fields, never rename. The JSON store is append-only; renaming a field breaks every past record. New fields are always safe (`additionalProperties: true` at the top level). This is why the validator allows extra keys but locks enums and required fields.

## Summary Line Shape (runs/{exp}/runs.jsonl)

Each line carries everything the planner needs to triage and decide. It is a projection of the matching `history.json`, not an independent record. No detail files are needed for routine turns.

Field definitions and `sub` key abbreviations: `docs/schemas/runs-line-schema.md` (machine-readable: `docs/schemas/runs-line-schema.json`).

The planner derives current best, subclass health, and active branches from the scan layer alone — no `history.json` opens needed for routine planning.

## The Relay (how next_action threads through the loop)

1. **Step 9** — after analysis, write `next_action` into `runs/{exp}/{id}/history.json` and append the summary line to `runs/{exp}/runs.jsonl`.
2. **Step 1** — Planner scans `runs/{exp}/runs.jsonl`; no detail files opened.
3. **Step 2** — Planner opens the one `history.json` it's continuing from, reads `reason` + `proposed_config` to form the hypothesis.
4. **Step 4** — materialise the full config: copy `proposed_config.base`, apply `proposed_config.overrides` → write new `config.yaml`. The baton stays tiny; the full config only ever lives in `config.yaml`.

`proposed_config` is `null` when `type == "stop_branch"`.
