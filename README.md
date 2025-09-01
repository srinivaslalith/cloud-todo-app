# Cloud-Native To-Do App

A resume-ready project showcasing a full cloud-native stack:

**Frontend (HTML/JS) → Backend (FastAPI) → PostgreSQL**
→ Docker → Kubernetes → CI/CD (GitHub Actions) → Terraform (EKS + RDS) → Monitoring (Prometheus + Grafana).

---

## Quickstart (Local, no Kubernetes)

1) Start Postgres (Docker):
```bash
docker run --name todo-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=tododb -p 5432:5432 -d postgres:16
```

2) Backend (FastAPI):
```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL="postgresql+psycopg2://postgres:postgres@localhost:5432/tododb"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

3) Frontend (HTML/JS):
Just open `frontend/index.html` in your browser (or serve it):
```bash
cd frontend
python -m http.server 5173
```

---

## Containers

Build & run locally:
```bash
# Backend
docker build -f docker/backend.Dockerfile -t cloud-todo-backend:local .
docker run --rm -p 8000:8000 --env DATABASE_URL="postgresql+psycopg2://postgres:postgres@host.docker.internal:5432/tododb" cloud-todo-backend:local

# Frontend
docker build -f docker/frontend.Dockerfile -t cloud-todo-frontend:local ./frontend
docker run --rm -p 5173:80 cloud-todo-frontend:local
```

---

## Kubernetes (Minikube)

```bash
# Start minikube and enable ingress (optional)
minikube start
kubectl apply -f k8s-manifests/postgres-statefulset.yaml
kubectl apply -f k8s-manifests/postgres-service.yaml
kubectl apply -f k8s-manifests/configmap.yaml
kubectl apply -f k8s-manifests/secret.sample.yaml  # Replace with your own secret before production
kubectl apply -f k8s-manifests/backend-deployment.yaml
kubectl apply -f k8s-manifests/backend-service.yaml
kubectl apply -f k8s-manifests/frontend-deployment.yaml
kubectl apply -f k8s-manifests/frontend-service.yaml
```

Get the frontend URL (Minikube):
```bash
minikube service frontend-svc --url
```

---

## CI/CD (GitHub Actions)

- Builds & pushes Docker images to GHCR (GitHub Container Registry).
- Applies K8s manifests with `kubectl` (needs cluster credentials as GitHub Secrets).

Required GitHub Secrets:
- `GHCR_USERNAME`, `GHCR_TOKEN` (or use `GITHUB_TOKEN` with proper permissions)
- `KUBE_CONFIG` (Base64-encoded kubeconfig for your cluster)
- `DB_URL` (e.g., `postgresql+psycopg2://user:pass@host:5432/tododb`)

---

## Terraform (AWS EKS + RDS)

A minimal skeleton is provided in `terraform/aws/`:
- Creates an EKS cluster
- Provisions a PostgreSQL RDS instance
- Exposes outputs (cluster endpoint, DB endpoint)

> Note: You'll need AWS credentials and to review/adjust VPC CIDRs, instance sizes, and security settings before use in production.

---

## Monitoring

- The backend exposes Prometheus-compatible metrics at `/metrics`.
- Recommended: install kube-prometheus-stack with Helm and add a `ServiceMonitor` (if using Prometheus Operator).

```bash
# Example (requires Helm and CRDs already installed):
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Then create a `ServiceMonitor` (example not included by default—depends on Prometheus Operator CRDs).

---

## Repo Structure

```
cloud-todo-app/
  backend/
  frontend/
  k8s-manifests/
  terraform/
  docker/
  .github/workflows/
  README.md
```
