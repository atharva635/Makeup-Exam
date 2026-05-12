#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT_NAME="${1:-sample-app}"
NAMESPACE="${2:-default}"

# Simple rollback using kubectl
kubectl rollout undo deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"

echo "Rollback executed for $DEPLOYMENT_NAME in $NAMESPACE"
