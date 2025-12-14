# Application Deployment Plan

**Status:** Planning Phase  
**Started:** 2025-12-14  
**Current Phase:** Foundation Setup

## Overview

Build a simple, automated way to deploy containerized applications to the k3s cluster, starting with Nginx Proxy Manager for SSL certificate management, then expanding to self-hosted services.

---

## Phase 1: Foundation & Networking 🔧

**Goal:** Get cluster networking and ingress working properly

### 1.1 Install CNI (Container Network Interface)
- [ ] Install Cilium for pod networking
- [ ] Verify pods can communicate across nodes
- [ ] Test DNS resolution within cluster

**Why:** Currently nodes are "NotReady" because we disabled networking (--flannel-backend=none)

**Commands:**
```bash
# Install Cilium
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
  --namespace kube-system \
  --set operator.replicas=1

# Verify
kubectl get nodes  # Should show "Ready"
```

### 1.2 Configure Ingress
- [ ] Verify Traefik is running (comes with k3s)
- [ ] Or install preferred ingress controller
- [ ] Test basic HTTP ingress

### 1.3 DNS Configuration
- [ ] Configure internal DNS for *.lab.home
- [ ] Point domains to cluster IP

---

## Phase 2: Nginx Proxy Manager (Priority 1) 🌐

**Goal:** SSL certificate management and reverse proxy

### Deployment Details
- **Method:** Helm chart (custom)
- **Namespace:** `proxy-system`
- **Image:** `jc21/nginx-proxy-manager:latest`
- **Ports:** 80 (HTTP), 443 (HTTPS), 81 (Admin)

### Tasks
- [ ] Create applications directory structure
- [ ] Create Helm chart for Nginx Proxy Manager
- [ ] Configure persistent storage
- [ ] Deploy and verify
- [ ] Configure Let's Encrypt
- [ ] Test SSL certificate generation

---

## Phase 3: Application Deployment Framework 🚀

**Goal:** Create reusable deployment patterns

### 3.1 Deployment Script
Create `deploy-app.sh` with features:
- One-command deployment
- Update capability
- Remove capability
- List all apps

### 3.2 Helm Chart Template
- Standard deployment pattern
- ConfigMap/Secret management
- Service/Ingress templates
- PVC templates

---

## Phase 4: Self-Hosted Services 📦

### 4.1 GitLab (Priority 2)
**Purpose:** Self-hosted Git, CI/CD, container registry

**Requirements:**
- PostgreSQL database
- Redis cache
- Large storage (50GB+)
- CI/CD runners

**Complexity:** High
**Resources:** 4GB RAM minimum

---

### 4.2 Mumble (Priority 3)
**Purpose:** Voice chat server

**Requirements:**
- Single container
- Persistent config storage
- UDP port exposure

**Complexity:** Low
**Image:** `mumblevoip/mumble-server:latest`

---

### 4.3 Arr-Stack (Priority 4)
**Purpose:** Media automation

**Components:**
- Sonarr (TV)
- Radarr (Movies)
- Prowlarr (Indexers)
- qBittorrent (Downloads)
- Jellyfin/Plex (Media server)

**Complexity:** Medium (interdependent services)

**Storage Structure:**
```
/mnt/media/
├── movies/
├── tv/
├── downloads/
└── configs/
```

---

### 4.4 Manga Reader (Priority 5)
**Purpose:** Self-hosted manga reading

**Components:**
- Komga (Library manager): `gotson/komga:latest`
- Suwayomi (Web reader): `ghcr.io/suwayomi/tachidesk:latest`

**Complexity:** Low-Medium

---

### 4.5 Audiobook/Book Reader (Priority 6)
**Purpose:** Book/audiobook management

**Application:** Audiobookshelf (all-in-one)
**Image:** `ghcr.io/advplyr/audiobookshelf:latest`

**Features:**
- Audiobook player
- Ebook reader
- Podcast support
- User management

**Complexity:** Low

---

## Directory Structure

```
lab/
├── infrastructure/              # ✅ DONE
│   ├── terraform/
│   ├── ansible/
│   └── deploy-k3s-cluster.sh
│
└── applications/                # 🆕 NEW
    ├── PLAN.md                  # This file
    ├── README.md
    ├── deploy-app.sh            # Deployment script
    │
    ├── base/                    # Base configs
    │   ├── namespaces.yaml
    │   └── storage-class.yaml
    │
    ├── charts/                  # Helm charts
    │   ├── nginx-proxy-manager/
    │   ├── gitlab/
    │   ├── mumble/
    │   ├── arr-stack/
    │   ├── komga/
    │   ├── suwayomi/
    │   └── audiobookshelf/
    │
    └── docs/
        └── guides/
```

---

## Resource Planning

**Current Cluster:**
- Control plane: 2 cores, 4GB RAM
- Worker 1: 2 cores, 2GB RAM
- Worker 2: 2 cores, 2GB RAM
- **Total: 6 cores, 8GB RAM**

**Estimated Requirements:**
- Nginx Proxy Manager: 0.5 cores, 512MB
- GitLab: 2 cores, 4GB
- Mumble: 0.1 cores, 128MB
- Arr-stack: 1 core, 2GB
- Book services: 1.5 cores, 1.5GB
- System: 1 core, 1GB
- **Total: ~6 cores, ~9GB**

⚠️ **May need additional resources**

**Storage Estimate:**
- GitLab: 50GB
- Media: 500GB+
- Books/Manga: 100GB
- Configs: 10GB
- **Total: ~660GB minimum**

---

## Namespace Strategy

```
proxy-system     # Nginx Proxy Manager
dev-tools        # GitLab, CI/CD
media            # Arr-stack, Jellyfin
books            # Komga, Audiobookshelf, Suwayomi
comms            # Mumble
monitoring       # Prometheus, Grafana (future)
```

---

## Next Session - Quick Start

**1. Install CNI:**
```bash
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace kube-system
kubectl get nodes  # Should show "Ready"
```

**2. Create directory structure:**
```bash
cd ~/repos/github.com/eelisrossi/lab
mkdir -p applications/{base,charts,values,docs}
cd applications/charts
mkdir -p nginx-proxy-manager/templates
```

**3. Start Nginx Proxy Manager Helm chart**

**4. Create deploy-app.sh script**

---

## Success Criteria

### Phase 1 Complete:
- [ ] All nodes "Ready"
- [ ] Pods communicate across nodes
- [ ] Ingress working

### Phase 2 Complete:
- [ ] Nginx Proxy Manager accessible
- [ ] SSL certificates generating
- [ ] At least one proxy host with SSL

### Phase 4 Complete:
- [ ] All services deployed
- [ ] All services have SSL
- [ ] Data persists across restarts

---

## Resources

- **Nginx Proxy Manager:** https://nginxproxymanager.com/
- **Cilium:** https://docs.cilium.io/
- **Helm Charts:** https://helm.sh/docs/
- **GitLab Docker:** https://docs.gitlab.com/ee/install/docker.html
- **Audiobookshelf:** https://www.audiobookshelf.org/
- **Komga:** https://komga.org/

---

**Last Updated:** 2025-12-14  
**Status:** Ready to start Phase 1
