#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
POLICY_DIR="$PROJECT_DIR/policies"
DEPLOYMENT_FILE="$PROJECT_DIR/deployments/deployment.yaml"

mkdir -p "$REPORT_DIR"

if ! command -v conftest >/dev/null 2>&1; then
  echo "Conftest not found. Install it from https://www.conftest.dev/"
  exit 1
fi

conftest test "$DEPLOYMENT_FILE" -p "$POLICY_DIR" -o json > "$REPORT_DIR/opa-report.json"

echo "OPA validation report saved to $REPORT_DIR/opa-report.json"
