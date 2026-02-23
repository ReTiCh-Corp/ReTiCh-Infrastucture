# ReTiCh Infrastructure

Infrastructure Docker pour la plateforme de messagerie temps réel ReTiCh.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Compose                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │API-Gateway│ │   Auth   │ │Messaging │ │   User   │           │
│  │  :8080   │ │  :8081   │ │  :8082   │ │  :8083   │           │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│  │PostgreSQL│ │  Redis   │ │   NATS   │                        │
│  │  :5433   │ │  :6379   │ │  :4222   │                        │
│  └──────────┘ └──────────┘ └──────────┘                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│  │Prometheus│ │ Grafana  │ │  Client  │                        │
│  │  :9090   │ │  :3000   │ │  :5173   │                        │
│  └──────────┘ └──────────┘ └──────────┘                        │
└─────────────────────────────────────────────────────────────────┘
```

## Prérequis

- Docker & Docker Compose
- Go 1.22+ (pour les migrations)
- [golang-migrate](https://github.com/golang-migrate/migrate) CLI

```bash
# Installer golang-migrate
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

## Démarrage rapide

### 1. Cloner tous les repos

```bash
git clone git@github.com:ReTiCh-Corp/ReTiCh-Infrastucture.git
git clone git@github.com:ReTiCh-Corp/ReTiCh-API-Gateway.git
git clone git@github.com:ReTiCh-Corp/ReTiCh-Auth.git
git clone git@github.com:ReTiCh-Corp/ReTiCh-Messaging.git
git clone git@github.com:ReTiCh-Corp/ReTiCh-User.git
git clone git@github.com:ReTiCh-Corp/ReTiCh-Client.git
```

### 2. Configuration

```bash
cd ReTiCh-Infrastucture
cp .env.example .env
# Modifier .env selon vos besoins
```

### 3. Lancer les services

```bash
# Production
make up

# Développement (avec hot-reload)
make up-dev
```

### 4. Exécuter les migrations

```bash
make migrate-all
```

### 5. Vérifier que tout fonctionne

```bash
make ps

# Tester les endpoints
curl http://localhost:8080/health  # API Gateway
curl http://localhost:8081/health  # Auth
curl http://localhost:8082/health  # Messaging
curl http://localhost:8083/health  # User
```

## Commandes disponibles

```bash
make help  # Afficher toutes les commandes
```

### Docker Compose

| Commande | Description |
|----------|-------------|
| `make up` | Démarrer tous les services |
| `make up-dev` | Démarrer en mode développement (hot-reload) |
| `make down` | Arrêter tous les services |
| `make restart` | Redémarrer tous les services |
| `make logs` | Voir les logs |
| `make logs-f` | Suivre les logs en temps réel |
| `make ps` | Lister les conteneurs |

### Migrations

| Commande | Description |
|----------|-------------|
| `make migrate-all` | Exécuter toutes les migrations |
| `make migrate-auth` | Migrations Auth uniquement |
| `make migrate-user` | Migrations User uniquement |
| `make migrate-messaging` | Migrations Messaging uniquement |
| `make rollback-auth` | Rollback Auth (1 step) |
| `make rollback-user` | Rollback User (1 step) |
| `make rollback-messaging` | Rollback Messaging (1 step) |

### Utilitaires

| Commande | Description |
|----------|-------------|
| `make db-shell` | Ouvrir un shell PostgreSQL |
| `make redis-cli` | Ouvrir Redis CLI |
| `make clean` | Supprimer tous les volumes (DANGER) |

## Services

| Service | Port | Description |
|---------|------|-------------|
| API Gateway | 8080 | Point d'entrée principal, routing |
| Auth | 8081 | Authentification, JWT, sessions |
| Messaging | 8082 | Messages temps réel, WebSocket |
| User | 8083 | Profils, contacts, settings |
| Client | 5173 | Frontend React |
| PostgreSQL | 5433 | Base de données |
| Redis | 6379 | Cache, sessions |
| NATS | 4222 | Message broker |
| Prometheus | 9090 | Métriques |
| Grafana | 3000 | Dashboards (admin/admin) |

## Structure des fichiers

```
ReTiCh-Infrastucture/
├── docker-compose.yml        # Configuration principale
├── docker-compose.dev.yml    # Override développement
├── docker-compose.prod.yml   # Override production
├── Makefile                  # Commandes utilitaires
├── .env.example              # Template variables d'environnement
└── configs/
    ├── prometheus/
    │   └── prometheus.yml
    ├── grafana/
    │   ├── datasources.yml
    │   └── dashboards/
    ├── nats/
    │   └── nats.conf
    ├── postgres/
    │   └── init.sql
    └── nginx/
        └── nginx.conf
```

## Monitoring

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

## Troubleshooting

### Port déjà utilisé

```bash
# Vérifier quel process utilise le port
sudo lsof -i :5432

# Modifier le port dans docker-compose.yml si nécessaire
```

### Réinitialiser les données

```bash
make clean  # Supprime tous les volumes
make up
make migrate-all
```

### Voir les logs d'un service spécifique

```bash
docker compose logs -f api-gateway
docker compose logs -f postgres
```

## Licence

MIT
