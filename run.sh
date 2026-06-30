#!/bin/bash
set -uo pipefail

EXPNAME="${1:?Usage: ./run.sh <expname>}"
RUNDIR="$(pwd)/runs/${EXPNAME}"
LOG="${RUNDIR}/session-output.md"
mkdir -p "$RUNDIR"

echo "# Codex Session — ${EXPNAME}" > "$LOG"
echo "Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$LOG"
echo "" >> "$LOG"

# Snapshot existing rollout files so we can find the new one after
SESSIONS_DIR="${HOME}/.codex/sessions"
TODAY=$(date -u +%Y/%m/%d)
mkdir -p "${SESSIONS_DIR}/${TODAY}"
BEFORE=$(ls "${SESSIONS_DIR}/${TODAY}"/rollout-*.jsonl 2>/dev/null | sort | tail -1)

finish() {
    code=$?
    # Find the new rollout file written during this session
    AFTER=$(ls "${SESSIONS_DIR}/${TODAY}"/rollout-*.jsonl 2>/dev/null | sort | tail -1)
    if [ -n "$AFTER" ] && [ "$AFTER" != "$BEFORE" ]; then
        cp "$AFTER" "${RUNDIR}/session.jsonl"
        echo "Session log: session.jsonl" >> "$LOG"
    fi
    echo "" >> "$LOG"
    if [ $code -eq 0 ]; then
        echo "Completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$LOG"
    else
        echo "STOPPED (exit $code): $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$LOG"
    fi
}
trap finish EXIT

script -q -f -e -a "$LOG" -c "codex --ask-for-approval never --sandbox danger-full-access 'program ${EXPNAME}'"
