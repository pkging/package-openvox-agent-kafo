#!/usr/bin/env bash
set -euo pipefail

source /workspace/.ci-workflows/hooks/lib/distro.sh
source /workspace/.ci-workflows/hooks/lib/common.sh || true

log "Project post-build hook – distro: $ID ($ID_LIKE)"

# z.B. Artefakte aufräumen, zusätzliche Checks, etc.

