#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# 1-2. Create directories
mkdir -p "$PROJECT_DIR"/{configs,deployments,policies,reports,artifacts,backups}

# 3-6. Users, groups, permissions (requires sudo)
# Create groups
sudo groupadd -f developers
sudo groupadd -f operations

# Create users if not exist
for u in developer tester devopsadmin; do
  if ! id "$u" >/dev/null 2>&1; then
    sudo useradd -m "$u"
  fi
 done

# Add users to groups
sudo usermod -aG developers developer
sudo usermod -aG developers tester
sudo usermod -aG operations devopsadmin

# Assign permissions
sudo chown -R :developers "$PROJECT_DIR"
sudo chmod -R g+rw "$PROJECT_DIR"

# Full administrative permissions for devopsadmin
sudo usermod -aG sudo devopsadmin

# 7. Create config files
cat > "$PROJECT_DIR/configs/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
        - name: sample-app
          image: nginx:1.27.1
          ports:
            - containerPort: 80
          securityContext:
            runAsNonRoot: true
            allowPrivilegeEscalation: false
            privileged: false
      securityContext:
        runAsNonRoot: true
EOF

cat > "$PROJECT_DIR/configs/pipeline.yaml" <<'EOF'
stages:
  - checkout
  - build
  - test
  - security
  - deploy
EOF

cat > "$PROJECT_DIR/configs/security.conf" <<'EOF'
ENFORCE_NON_ROOT=true
ALLOW_PRIVILEGED=false
REQUIRE_IMAGE_TAG=true
FAIL_ON_POLICY_VIOLATION=true
EOF

# 8-9. Backup with timestamps
mkdir -p "$BACKUP_DIR"
for f in "$PROJECT_DIR/configs"/*; do
  base="$(basename "$f")"
  cp "$f" "$BACKUP_DIR/${base%.yaml}_${TIMESTAMP}.bak" || cp "$f" "$BACKUP_DIR/${base}_${TIMESTAMP}.bak"
 done

# 10. Display structure
command -v tree >/dev/null 2>&1 && tree "$PROJECT_DIR" || find "$PROJECT_DIR" -maxdepth 3 -print

# 11. Background process and terminate
sleep 300 &
BG_PID=$!
kill "$BG_PID"

# 12. Process tree
ps -f --forest

# 13. Archive project
tar -czf "$PROJECT_DIR/../company-devops-platform_${TIMESTAMP}.tar.gz" -C "$PROJECT_DIR" .

echo "Linux setup complete."
