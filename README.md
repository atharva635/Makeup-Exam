# DevOps CI/CD Security Platform

## Project Name
**devops-cicd-security-platform**

## Objective
Design and implement a DevOps workflow that focuses on Linux administration, Git & GitHub collaboration, CI/CD automation, SonarQube integration, and Open Policy Agent policy enforcement.

---

## 1. Linux Administration & User Management

### Directory Structure
- `configs/`: Configuration files (deployment.yaml, pipeline.yaml, security.conf)
- `deployments/`: Deployment manifests
- `policies/`: OPA/Rego policy files
- `reports/`: SonarQube and OPA validation reports
- `artifacts/`: Build and deployment artifacts
- `scripts/`: Automation scripts
- `backups/`: Timestamped backups of configuration files

### Users and Groups
- **Users**: developer, tester, devopsadmin
- **Groups**: developers, operations
- **Permissions**:
  - `developers` group: read/write access to project directory
  - `devopsadmin`: full sudo administrative permissions

### Configuration Files
- `deployment.yaml`: Kubernetes deployment with security constraints
- `pipeline.yaml`: CI/CD pipeline stages configuration
- `security.conf`: Security policy enforcement settings

### Backups
All configuration files are backed up to `backups/` directory with timestamp format: `filename_YYYYMMDD_HHMMSS.bak`

### Execution
```bash
bash scripts/linux_setup.sh
```

---

## 2. Git & GitHub Workflow

### Repository
- **Name**: devops-cicd-security-platform
- **Branches**:
  - `master`: Production-ready code (main branch)
  - `development`: Day-to-day development with CI validation
  - `staging`: Pre-production environment validation
  - `production`: Production releases

### Branching Strategy
```
master (main)
├── development (CI validation)
├── staging (pre-production)
└── production (releases)
```

### Commits
Five separate commits for each requirement:
1. **Linux setup**: Users, groups, permissions configured
2. **Git workflow**: Branching strategy and version control operations
3. **CI/CD configuration**: GitHub Actions workflows implemented
4. **SonarQube integration**: Quality gates and security scanning
5. **OPA policies**: Rego rules for security enforcement

### Git Operations Demonstrated
- **stash**: Save uncommitted changes temporarily
- **cherry-pick**: Apply specific commits to current branch
- **rebase**: Reapply commits on top of another branch
- **revert**: Undo specific commits while maintaining history
- **reset**: Undo commits (soft reset keeps changes staged)
- **File Restoration**: Restore deleted files using `git restore`
- **Merge Conflicts**: Simulated between branches and resolved

### Graphical Commit History
Display commit history with branch visualization:
```bash
git log --oneline --graph --all --decorate
```

### GitHub Setup
To push branches to GitHub:
```bash
git remote add origin https://github.com/<USERNAME>/devops-cicd-security-platform.git
git push -u origin master development staging production
```

### Execution
```bash
bash scripts/git_workflow.sh
```

---

## 3. CI/CD Pipeline Implementation

### GitHub Actions Workflows

#### Development Pipeline (`ci.yml`)
**Trigger**: Push to `development` branch

**Stages**:
1. **Source Checkout**: Clone repository code
2. **Build**: Compile and prepare artifacts
3. **Test**: Execute test suites
4. **Security Validation**: OPA policy validation and SonarQube scanning
5. **Deployment**: Deploy to target environment

**Features**:
- Automatic trigger on push to development branch
- Build logs saved to `artifacts/build.log`
- Test logs saved to `artifacts/test.log`
- OPA validation report: `reports/opa-report.json`
- SonarQube quality gate validation (fails if gate not met)
- Deployment logs saved to `artifacts/deploy.log`
- Reports uploaded as artifacts

#### Production Pipeline (`production-deploy.yml`)
**Trigger**: Push to `production` branch

**Stages**:
1. **Source Checkout**: Clone repository code
2. **Build**: Production build
3. **Deployment**: Deploy to production environment
4. **Rollback on Failure**: Automatic rollback using `scripts/rollback.sh`

**Features**:
- Separate production deployment workflow
- Automatic rollback on failure
- Deployment artifacts stored in `artifacts/`

### Environment Variables
- `APP_ENV`: Set to "development" or "production"

### Secrets (Required)
Configure in GitHub repository settings:
- `SONAR_TOKEN`: SonarQube authentication token
- `SONAR_HOST_URL`: SonarQube server URL

### Artifacts Location
- `artifacts/`: Build logs, deployment reports, binaries
- `reports/`: Test results and validation reports
- `reports/sonarqube/`: SonarQube scan results

### Rollback Mechanism
Failed deployments trigger automatic rollback:
```bash
kubectl rollout undo deployment <deployment-name> -n <namespace>
```

### CI/CD Status Badge
```markdown
[![CI](https://github.com/<USERNAME>/devops-cicd-security-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/<USERNAME>/devops-cicd-security-platform/actions)
```

---

## 4. SonarQube Integration

### Configuration
File: `sonar-project.properties`
- Project Key: `devops-cicd-security-platform`
- Sources: Entire repository
- Inclusions: YAML files, shell scripts, Rego policies
- Exclusions: Reports, artifacts, .github directories

### Scanning
SonarQube scans the following file types:
- **YAML files**: `*.yml`, `*.yaml`
- **Shell scripts**: `*.sh`
- **OPA policies**: `*.rego`

### Reports Generated
SonarQube generates detailed reports for:
- **Bugs**: Code defects and errors
- **Vulnerabilities**: Security issues
- **Code Smells**: Code quality issues
- **Duplicated Code**: Code duplication analysis

### Quality Gates
- Configured in SonarQube server
- CI pipeline fails if quality gate threshold not met
- Gate validation step: `SonarQube Quality Gate`

### Reports Location
- `reports/sonarqube/`: SonarQube reports and analysis

### Setup
1. Install and configure SonarQube server
2. Set `SONAR_TOKEN` and `SONAR_HOST_URL` as GitHub secrets
3. SonarQube scan runs automatically on push to `development` branch

---

## 5. Open Policy Agent (OPA) / Conftest

### Installation
```bash
# Install Conftest
curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.56.0/conftest_0.56.0_Linux_x86_64.tar.gz | tar xz
sudo mv conftest /usr/local/bin/
```

### Policies Location
All policies stored in `policies/` directory

### Policy Files

#### 1. `deployment.rego` - Deployment Validation
Enforces:
- Container images must be specified (not empty)
- Image tag `:latest` is not allowed (enforce specific versioning)

#### 2. `security.rego` - Security Validation
Enforces:
- Pod must run as non-root user
- Containers must run as non-root
- Prevents root user execution

#### 3. `container.rego` - Container Validation
Enforces:
- Privileged containers are not allowed
- Privilege escalation is not allowed
- Prevents privileged container execution

### Validation
Validate deployment configuration against policies:
```bash
conftest test deployments/deployment.yaml -p policies -o json > reports/opa-report.json
```

### Reports
OPA validation reports saved to:
- `reports/opa-report.json`: JSON formatted validation results

### Failure Handling
- Deployment fails if policies are violated
- CI/CD pipeline stops and reports violations
- Violations must be fixed before deployment

### Execution
```bash
bash scripts/opa_validate.sh
```

---

## Quick Start

### 1. Linux Setup
```bash
bash scripts/linux_setup.sh
```
Creates users, groups, permissions, backups with timestamps, and project archive.

### 2. Git Initialization
```bash
bash scripts/git_workflow.sh
```
Initializes Git repository, creates branches, commits, demonstrates all git operations.

### 3. OPA Validation
```bash
bash scripts/opa_validate.sh
```
Validates deployment configuration against OPA policies.

### 4. GitHub Setup
```bash
git remote add origin https://github.com/<USERNAME>/devops-cicd-security-platform.git
git push -u origin master development staging production
```

---

## Project Structure
```
company-devops-platform/
├── .github/workflows/
│   ├── ci.yml                          # Development CI pipeline
│   └── production-deploy.yml           # Production deployment
├── artifacts/                          # Build and deployment artifacts
├── backups/                            # Timestamped config backups
├── configs/
│   ├── deployment.yaml                 # Kubernetes deployment config
│   ├── pipeline.yaml                   # CI/CD pipeline stages
│   └── security.conf                   # Security settings
├── deployments/
│   └── deployment.yaml                 # Deployment manifests
├── policies/
│   ├── deployment.rego                 # OPA deployment validation
│   ├── security.rego                   # OPA security validation
│   └── container.rego                  # OPA container validation
├── reports/
│   └── sonarqube/                      # SonarQube reports
├── scripts/
│   ├── linux_setup.sh                  # Linux user/group setup
│   ├── git_workflow.sh                 # Git operations automation
│   ├── opa_validate.sh                 # OPA policy validation
│   └── rollback.sh                     # Deployment rollback
├── README.md                           # This file
└── sonar-project.properties            # SonarQube configuration
```

---

## Requirements Met
✅ Linux Administration & User Management  
✅ Git & GitHub Workflow & Collaboration  
✅ CI/CD Pipeline Implementation (GitHub Actions)  
✅ SonarQube Integration  
✅ Open Policy Agent (OPA) Policy Enforcement
