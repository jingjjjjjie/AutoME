# AutoMe v1

## Invocation

This agent is started with `/goal program {EXPNAME}` — for example `/goal program exp1`.

`EXPNAME` is the experiment name for this session. It determines two fixed directories that must never be renamed or restructured mid-experiment:

| Directory | Purpose |
|---|---|
| `runs/{EXPNAME}/` | Internal scan layer — `runs.jsonl` + per-run `history.json` records (inside this repo) |
| `/mnt3/repo_and_weights/agent/{EXPNAME}/` | External output dir — checkpoints, predictions, breakdown (outside this repo, managed by AutoTorch) |

**Only ever append new run folders. Never rename, move, or delete existing ones.**

---

## Context

You are an LLM agent that improves the `ori` single-model training pipeline through iterative experiments.

For each trial, you read previous experiment results from `runs.jsonl`, propose a new hypothesis, create a training config, run training in AutoTorch, run evaluation, analyze the results, and write the outcome to `history.json`.

The loop continues until the target metrics are reached or no useful experiment direction remains.

## Goal

Improve the `ori` single-model performance through evidence-based experiment proposals.

All three targets must be met simultaneously:

| Metric | Target |
|---|---|
| Global APCER | < 1% |
| Colour Print APCER (`Printed - Color`, `Cutout Printed - Color`) | < 2% each |
| Global BPCER | < 3% |

Global APCER is the hard constraint — do not sacrifice it to hit the subclass or BPCER targets. Among runs that satisfy all three, prefer the one with the lowest global APCER.

## Data

Currently, AutoMe does not need to experiment with different dataset sets.

The config already defines 3 dataset splits:

- Training data:
- Validation data:
- Testing data:

## What AutoMe Should Do

0. **Bootstrap (first run only).** If `runs/{EXPNAME}/runs.jsonl` does not exist, create it:
   ```bash
   mkdir -p runs/{EXPNAME}
   touch runs/{EXPNAME}/runs.jsonl
   ```
   Skip this step on all subsequent runs.

1. Read `runs/{EXPNAME}/runs.jsonl` (scan all summary lines). Each line contains global metrics and per-subclass health (`sub`) — no detail files needed to understand what has been tried and what the current best is.
2. Read `docs/prior-knowledge.md` for researcher context (known patterns, dead ends, hypotheses to prioritise). Then propose a new hypothesis based on previous results. If continuing a branch, open that run's `history.json` and read `next_action.reason` + `proposed_config`.
3. Generate the experiment ID (`{EXPNAME}_{NNN}_{MMDD}`) and create the metadata folder:
   ```bash
   mkdir -p runs/{EXPNAME}/{NNN}_{MMDD}
   ```
   Write the initial `history.json` with `experiment_id`, `start_time`, `status: running`, and `artifacts`. AutoTorch will create the external output folder automatically.
4. Materialise the config: copy `proposed_config.base`, apply `proposed_config.overrides`, write to `runs/{EXPNAME}/{NNN}_{MMDD}/config.yaml`. Set `run_dir: $RUNS_DIR/{EXPNAME}/{NNN}_{MMDD}` inside the config so AutoTorch saves outputs externally. Only use keys and values defined in `docs/base-config.yaml`. **Always quote `experiment.save_name` with double quotes** (e.g. `"001_0630"`) — unquoted values like `001_0630` are parsed as octal integers by PyYAML.
5. Run training (from `AutoTorch/src`):
   ```bash
   TQDM_DISABLE=1 CUDA_VISIBLE_DEVICES=0 torchrun --nproc_per_node=1 --master_port=29500 train.py --config runs/{EXPNAME}/{NNN}_{MMDD}/config.yaml
   ```
   Checkpoint selection runs automatically at the end — writes `checkpoint_selection.csv`.
6. Run evaluation (from `AutoTorch/src`):
   ```bash
   CUDA_VISIBLE_DEVICES=0 python evaluate.py --run-dir $RUNS_DIR/{EXPNAME}/{NNN}_{MMDD}
   ```
   Writes `eval_predictions.csv` to `$RUNS_DIR/{EXPNAME}/{NNN}_{MMDD}/`.
7. Run the per-subclass breakdown (from `AutoTorch/src`):
   ```bash
   python breakdown.py --run-dir $RUNS_DIR/{EXPNAME}/{NNN}_{MMDD}
   ```
   Writes `breakdown.json` to `$RUNS_DIR/{EXPNAME}/{NNN}_{MMDD}/`.
8. Copy `breakdown.json` contents into `history.json` under `metrics.evaluation_results` and `metrics.per_subclass`.
9. Analyze results. Write `analysis` and `next_action` into `history.json`. Set `finish_time` and `status: completed`.
10. Read the latest `token_count` event from the current Codex session log (written automatically to `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` — find today's file). Map the Codex fields to `cost.tokens_used` in `history.json` as follows: `input_tokens` → `prompt`, `cached_input_tokens` → `cache_read`, `output_tokens` → `completion`, `input_tokens + output_tokens` → `total`. Note: these are cumulative session totals, not isolated to this run. Then append a summary line to `runs/{EXPNAME}/runs.jsonl`.
11. Repeat from step 1. Stop only when all three targets are met (global APCER < 1%, Colour Print APCER < 2%, global BPCER < 3%) or there are no remaining hypotheses to explore across all branches.

## What you CANNOT do

- **Only touch the config.** All experiments are config-only changes — hyperparameters, architecture choice, scheduler settings. Do not modify AutoTorch source code, data preprocessing, augmentation pipelines, or dataset files. That scope is reserved for v2.

## Config constraints

Every config you write must be a valid AutoTorch config. The only keys that exist, the only values each key accepts, and what each setting does are defined in:

- `docs/base-config.yaml` — **the authoritative annotated reference for every config key and its valid values**

**Rules:**
- You may only use keys listed in `docs/base-config.yaml`. Do not invent keys.
- For the first run of a new experiment, use `docs/base-config.yaml` as the base.
- For subsequent runs, use the previous run's `runs/{exp}/{id}/config.yaml` as the base and apply only the changed keys as `proposed_config.overrides`.
- `data.*` keys are fixed — do not change dataset paths between runs.


## Output schema

Every run produces two outputs. Their shapes are defined and validated in:

- `docs/schemas/experiment-schema.md` — annotated example of `runs/{exp}/{id}/history.json`
- `docs/schemas/experiment-schema.json` — JSON Schema for validation
- `docs/schemas/runs-line-schema.json` — JSON Schema for each line in `runs/{exp}/runs.jsonl`
- `docs/memory-model.md` — how the stores relate and the abbreviation map for `sub`