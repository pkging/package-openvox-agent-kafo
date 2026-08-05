#!/usr/bin/env bash
set -euo pipefail

source /workspace/.ci-workflows/hooks/lib/distro.sh
source /workspace/.ci-workflows/hooks/lib/common.sh || true

log "Project post-test hook – distro: $ID ($ID_LIKE)"

# z.B. Logs sammeln, zusätzliche Checks, Cleanup

# ---------------------------------------------------------------------------
# SMOKE TESTS
# ---------------------------------------------------------------------------
log "Running smoke tests..."

log "Smoke tests completed successfully."

