{
    "id":        "001_0621",           // NNN_MMDD — maps to runs/{exp}/{id}/history.json
    "ts":        "2026-06-21T14:32:00Z", // finish_time from history.json
    "st":        "completed",          // status: running | completed | failed | stopped_limit
    "APCER":     0.871,                // metrics.evaluation_results.APCER; null on failed runs
    "BPCER":     0.42,                 // metrics.evaluation_results.BPCER; null on failed runs
    "best":      true,                 // analysis.beats_current_best
    "pot":       "high",               // analysis.potential: high | medium | low
    "parent_id": "000_0620",           // history.parent_id; null for the first run in an experiment
    "next":      "branch_experiment",  // next_action.type: branch_experiment | stop_branch
    "cost_s":    4820,                 // cost.wall_time_sec
    "lr":  1e-4,                        // training.learning_rate from config.yaml
    "wd":  1e-4,                        // training.weight_decay from config.yaml
    "sub": {                           // per-subclass error rates (abbreviated keys); null on failed runs
        "CP_col":  0.91,   // Cutout Printed - Color      → APCER
        "CP_gray": 0.45,   // Cutout Printed - Grayscale  → APCER
        "P_col":   0.23,   // Printed - Color             → APCER
        "P_gray":  0.31,   // Printed - Grayscale         → APCER
        "R_frame": 0.12,   // Replay - Frameless          → APCER
        "R_mob":   0.08,   // Replay - Mobile             → APCER
        "R_mon":   0.91,   // Replay - Monitor            → APCER
        "R_tab":   0.15,   // Replay - Tablet             → APCER
        "genuine": 0.42    // Genuine                     → BPCER
    }
}
