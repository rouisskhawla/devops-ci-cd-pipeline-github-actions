# CI/CD Pipeline with GitHub Actions, Docker, SonarQube, and Deployments with Environment Handeling

This project demonstrates a complete CI/CD workflow for a simple Spring Boot application using **GitHub Actions**, **Docker**, **SonarQube**, and automated deployment to **Staging** and **Production** virtual machines.

It is designed to showcase DevOps skills such as versioning automation, artifact management, quality analysis, and environment-based deployments.

---

## 1. Architecture Overview

The pipeline is fully automated and divided into these stages:

- **Versioning** (snapshot or release)
- **Testing** (Maven tests)
- **Quality Code Analysis** (SonarQube)
- **Packaging** (JAR build)
- **Containerization** (Docker build & push)
- **Deployment**
  - Snapshot → Staging VM
  - Release → Production VM

Execution is handled by a **self-hosted GitHub Actions runner** installed on **Ubuntu WSL**, which communicates with three VMs: Sonar VM, Staging VM, and Production VM.

---

## 2. Versioning Strategy

A custom script `scripts/version.sh` automates semantic versioning:

### Snapshot builds
- Format: `X.Y.Z-SNAPSHOT.N`
- Stored in `.ci/snapshot-version.json`
- Each new snapshot increments the counter.

### Release builds
- Automatically bumps major, minor, or patch.
- Creates and pushes a Git tag `vX.Y.Z`.

The version is propagated to Docker images and deployment steps.

---

## 3. GitHub Actions Workflow Summary

### **CI Pipeline (`ci.yml`)**
Triggered on:
- Push to `main`
- Manual trigger via `workflow_dispatch`

Jobs:
- `version` → determines snapshot or release version
- `test` → runs Maven tests
- `sonar` → runs SonarQube scan
- `package` → builds the JAR and uploads as an artifact
- `docker` → builds & pushes Docker image, triggers deployment
  - Snapshot → deploys to Staging
  - Release → deploys to Production

### **Staging Deployment (`staging.yml`)**
Triggered automatically by the CI pipeline for snapshot builds.

### **Production Deployment (`production.yml`)**
Triggered automatically by the CI pipeline for release builds.

---

## 4. Infrastructure Setup

### Self-hosted Runner
Installed on Ubuntu WSL with:
- Docker
- Java 17
- Maven
- GitHub runner agent

### Virtual Machines
Three VMs running on Windows with VirtualBox:
- **SonarQube VM**
- **Staging VM**
- **Production VM**

Each VM has three network interfaces:
- NAT (internet access)
- Host-only (shared with WSL)
- Bridged (assigned LAN IP)

The **bridged IPs** allow the runner to communicate with the VMs.

---

## 5. Docker & Deployment Workflow

Applications are deployed using `docker-compose.yml`:

- **Docker Images Built & Pushed for Each Build:**
  - **Versioned image:** tagged with the calculated version (e.g., `1.2.3-SNAPSHOT.4` or `1.2.3`) to keep a historical record.
  - **Latest image:** tagged as `latest-snapshot` for snapshots or `latest` for releases, which is used in the automated deployment.
- **Deployment:**
  - Staging pulls `latest-snapshot` images for snapshot builds.
  - Production pulls `latest` images for release builds.
- Both environments use Docker Compose to run containers and automatically restart services on deploy.

---

## 6. Secrets & Access Management

Sensitive information is stored in GitHub Secrets:
- SSH keys for VMs
- Docker Hub credentials
- SonarQube token & URL
- GitHub PAT (for workflow dispatch)

This ensures secure access between GitHub runners and VMs.

---

## 7. Logs & Screenshots

A dedicated folder `/docs` contains screenshots and logs for:
- SonarQube dashboard
- Docker Hub image list
- Repository secrets
- CI pipeline run examples
- Staging and Production deployment
- Runner logs during execution
 
These demonstrate the full CI/CD workflow in action.

---

## Conclusion

This repository demonstrates a complete, production-style CI/CD pipeline with automated versioning, code quality checks, testing, Docker image creation, and multi-environment deployment.

