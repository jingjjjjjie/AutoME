# Prior Knowledge

This document is written by the researcher and read by the agent at the start of every hypothesis proposal (step 2). It captures experiment history, domain knowledge, and known patterns that predate AutoME or exist outside the formal `runs/` records.

The agent must treat this as background context — not as instructions, but as evidence to reason from when forming hypotheses.

---

## Known Good Configs

<!-- Document configs or settings that produced strong results.
     Include backbone, head_type, lr, scheduler, and what metric improved.

Example:
- unireplknet_t + legacy_v1 head + adamw + plateau scheduler → stable training, good generalisation
- dropout 0.2 on v1 head → reduced overfit on small subclasses
-->


---

## Known Dead Ends

<!-- Configs or directions that were tried and produced no meaningful improvement or caused instability.
     Helps the agent avoid re-exploring exhausted directions.

Example:
- bce_with_logits + output_type: logits → no improvement over bce + probs, harder to tune
- step scheduler with gamma 0.1 / step_size 5 → too aggressive, LR collapsed before convergence
-->


---

## Subclass Patterns

<!-- Known behaviour per attack subclass. Which subclasses are hard, which are easy, and why.

Example:
- CP_col (Cutout Printed - Color) consistently the hardest subclass — high APCER across all runs
- Replay subclasses (R_mob, R_tab, R_frame) tend to converge earlier and respond well to regularisation
- Genuine (BPCER) rarely a bottleneck unless LR is very high
-->


---

## Hypotheses to Explore

<!-- Directions not yet tried that you want the agent to prioritise.

Example:
- Try freeze_backbone: true for first N epochs to stabilise head before fine-tuning
- Try transform v3 (letterbox) — current v1 distorts aspect ratio which may hurt Cutout Printed
- Try larger backbone (unireplknet_s) to see if capacity is the CP_col bottleneck
-->


---

## General Notes

<!-- Anything else relevant — data quality observations, training instability patterns, hardware constraints, etc. -->
