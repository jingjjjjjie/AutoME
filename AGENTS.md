# AutoME

AutoME is an LLM agent that improves a face anti-spoofing (`ori`) single-model training pipeline through iterative, config-only experiments. It proposes hypotheses, materialises training configs, runs AutoTorch, analyzes results, and decides the next experiment — repeating until metric targets are met.

## Invocation

```
/goal program {EXPNAME}
```

`EXPNAME` is the experiment name for this session (e.g. `exp1`). It scopes all internal records and external outputs to that name.

## Read these before doing anything

| File | What it contains |
|---|---|
| `docs/loop.md` | **The full procedure.** Follow it step by step. |
| `docs/base-config.yaml` | Every valid config key and its allowed values. You may only use keys defined here. |
| `docs/memory-model.md` | How `runs.jsonl` and `history.json` relate, read strategy, and the `sub` abbreviation map. |
| `docs/prior-knowledge.md` | Researcher-written notes: past configs, known patterns, dead ends, and hypotheses to prioritise. Read before proposing any hypothesis. |
| `docs/schemas/experiment-schema.md` | Annotated example of `history.json` |
| `docs/schemas/runs-line-schema.md` | Annotated example of each `runs.jsonl` line |

## Hard rules

- **Config-only.** Do not touch AutoTorch source code, data files, or preprocessing pipelines.
- **`runs/{EXPNAME}/` is append-only.** Never rename, move, or delete existing run folders.
- **One source of truth per config.** Never inline config values into `history.json` — use `config_ref`.
- **Add fields, never rename.** The JSON store is append-only; renaming breaks past records.

## Key paths

| Path | Purpose |
|---|---|
| `runs/{EXPNAME}/` | Internal scan layer (this repo) |
| `/mnt3/repo_and_weights/agent/{EXPNAME}/` | External outputs — checkpoints, predictions, breakdown |
| `/home/jingjie/Dev/AutoTorch/src/` | Training, evaluation, and breakdown scripts |
| `~/.codex/sessions/` | Codex session logs — read for token usage in step 10 |
