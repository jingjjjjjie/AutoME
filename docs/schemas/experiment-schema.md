{
    "experiment_id": "001_0621",   // NNN_MMDD — maps to runs/{exp_name}/{NNN}_{MMDD}/ (exp name is the parent folder)
    "parent_id": "000_0620",       // id of the run this branched from; null for the first run in an experiment
    "start_time": "2026-06-21T13:12:00Z",        // ISO 8601, when training started
    "finish_time": "2026-06-21T14:32:00Z",       // ISO 8601, when the run completed
    "status": "completed",                       // completed | failed | stopped_limit

    "artifacts": {
        "config_ref":      "runs/exp1/001_0621/config.yaml",                 // inside AutoME repo — config used for this run
        "experiment_dir":  "$RUNS_DIR/exp1/001_0621",                        // external — root folder for heavy outputs
        "checkpoint_path": "$RUNS_DIR/exp1/001_0621/checkpoints/epoch_4.pt"  // external — best checkpoint .pt file
    },

    "cost": {
        "wall_time_sec": 4820,                          // total wall-clock time for the run
        "wall_time_min": 80.3,                          // derived: wall_time_sec / 60
        "per_epoch_sec": [990, 965, 958, 962, 945],     // per-epoch timings; useful for spotting slowdowns
        "tokens_used": {                // agent reads the final result line from session.log (stream-json output) and extracts usage
            "prompt":      12400,
            "completion":  3200,
            "total":       15600,
            "cache_read":  11660,
            "cache_write": 6842
        },
        "cost_usd": 0.0447           // total USD cost, from Claude Code result line
    },

    "metrics": {
        "best_epoch": 4,                                                           // epoch chosen by checkpoint_selection.csv
        "validation_stats":   { "loss": 0.312, "accuracy": 0.871 },                // written by the trainer
        "validation_results": { "Threshold": 0.5, "APCER": 0.871, "BPCER": 0.42 }, // written by the trainer
        "evaluation_results": { "Threshold": 0.5, "APCER": 0.871, "BPCER": 0.42 }, // written by breakdown.py on the held-out eval set
        "per_subclass": {                                                          // attack subclasses report APCER; Genuine reports BPCER; n = samples scored
            
            "Cutout Printed - Color":     { "APCER": 0.91, "n": 200 },
            "Cutout Printed - Grayscale": { "APCER": 0.91, "n": 200 },
            "Genuine":                    { "BPCER": 0.91, "n": 200 },
            "Printed - Color":            { "APCER": 0.91, "n": 200 },
            "Printed - Grayscale":        { "APCER": 0.91, "n": 200 },
            "Replay - Frameless":         { "APCER": 0.91, "n": 200 },
            "Replay - Mobile":            { "APCER": 0.91, "n": 200 },
            "Replay - Monitor":           { "APCER": 0.91, "n": 200 },
            "Replay - Tablet":            { "APCER": 0.91, "n": 200 }
        }
    },

    "analysis": {
        "summary": "Dropout 0.2 helped generalise; Cutout Printed Color still lagging.", // one-line outcome
        "findings": [                                                                    // numbered observations drawn from the metrics
            "Global APCER improved by 1.2% over current best.",
            "Cutout Printed Color remains highest-error subclass at 0.91 APCER.",
            "Replay subclasses all within target."
        ],
        "hypothesis": "Higher dropout reduced overfitting on small attack subclasses.", // why it turned out this way
        "beats_current_best": true,                                                     // true if this run's APCER beats the current project best
        "potential": "high",                                                            // high | medium | low — headroom for further improvement
        "justification": "Replay-Monitor responded strongly to dropout and is still the worst attack — more headroom in this direction before diminishing returns."
    },

    "next_action": {
        "type": "branch_experiment",              // branch_experiment | stop_branch
        "reason": "Replay-Monitor still worst attack; raise weight_decay to curb overfit",
        "proposed_config": {                      // diff only — null when type == stop_branch
            "base": "runs/exp1/001_0621/config.yaml",  // config to copy from (inside AutoME repo)
            "overrides": { "weight_decay": 1e-4 } // only the fields that change
        }
    }
}
