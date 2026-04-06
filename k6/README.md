# k6 Load Testing — ReTiCh

Test de charge distribué sur Kubernetes avec **k6 Operator** + **Prometheus** + **Grafana**.

## Architecture

```
k6 Operator
├── Pod 1 (1000 VUs)
├── Pod 2 (1000 VUs)
├── Pod 3 (1000 VUs)
├── Pod 4 (1000 VUs)
└── Pod 5 (1000 VUs)
         │
         ▼  5000 req simultanées
   API ReTiCh (Azure Container Apps)
         │
         ▼
   Prometheus ──► Grafana (dashboard ID 18030)
```

## Fichiers

| Fichier | Rôle |
|---|---|
| `namespace.yaml` | Namespace `k6` |
| `secret.yaml` | Template pour les credentials (ne pas commiter avec vraies valeurs) |
| `configmap.yaml` | Script k6 injecté dans les pods |
| `testrun.yaml` | TestRun CRD — 5 pods × 1000 VUs = 5000 VUs |
| `prometheus-values.yaml` | Helm values Prometheus avec remote write |
| `grafana-dashboard-configmap.yaml` | Auto-provisioning dashboard Grafana |
| `Makefile` | Commandes raccourcies |

## Prérequis

- Cluster Kubernetes (AKS, GKE, EKS, k3s…)
- `kubectl` configuré
- `helm` installé

## Installation

```bash
# 1. Installer k6 Operator
make install-operator

# 2. Installer Prometheus
make install-prometheus

# 3. Créer le namespace et le ConfigMap
make setup

# 4. Créer le secret avec tes credentials
kubectl create secret generic retich-load-test-env \
  --from-literal=EMAIL=ton@email.com \
  --from-literal=PASSWORD=TonMotDePasse \
  --from-literal=AUDIENCE=retich-client \
  -n k6
```

## Lancer un test

```bash
make run       # Lance le test
make watch     # Surveille le statut
make logs      # Affiche les logs en temps réel
make stop      # Arrête le test
```

## Modifier le scénario

Édite `configmap.yaml` puis :
```bash
make update-script
make run
```

## Visualiser les résultats

1. Ouvre Grafana
2. Importe le dashboard ID **18030** (k6 Prometheus)
3. Les métriques arrivent en temps réel pendant le test

## Scénarios disponibles

Modifier `parallelism` dans `testrun.yaml` :

| parallelism | VUs total | Usage |
|---|---|---|
| 1 | 1000 | Dev / smoke test |
| 3 | 3000 | Charge nominale |
| 5 | 5000 | Stress test |
| 10 | 10000 | Spike test extrême |
