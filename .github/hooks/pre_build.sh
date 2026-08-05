#!/usr/bin/env bash
set -euo pipefail

# Libs aus dem ausgecheckten Workflow im Container
source /workspace/.ci-workflows/hooks/lib/distro.sh
source /workspace/.ci-workflows/hooks/lib/common.sh || true

log "Project pre-build hook – distro: $ID ($ID_LIKE)"
