# ReTiCh Infrastructure Makefile

.PHONY: help up down restart logs ps migrate-auth migrate-user migrate-messaging migrate-all rollback-auth rollback-user rollback-messaging

# Default target
help:
	@echo "ReTiCh Infrastructure Commands"
	@echo ""
	@echo "Docker Compose:"
	@echo "  make up              - Start all services"
	@echo "  make up-dev          - Start all services in dev mode (hot-reload)"
	@echo "  make down            - Stop all services"
	@echo "  make restart         - Restart all services"
	@echo "  make logs            - View logs (all services)"
	@echo "  make logs-f          - Follow logs (all services)"
	@echo "  make ps              - List running containers"
	@echo ""
	@echo "Database Migrations:"
	@echo "  make migrate-all     - Run all migrations"
	@echo "  make migrate-auth    - Run Auth service migrations"
	@echo "  make migrate-user    - Run User service migrations"
	@echo "  make migrate-messaging - Run Messaging service migrations"
	@echo "  make rollback-auth   - Rollback Auth migrations (1 step)"
	@echo "  make rollback-user   - Rollback User migrations (1 step)"
	@echo "  make rollback-messaging - Rollback Messaging migrations (1 step)"
	@echo ""
	@echo "Utilities:"
	@echo "  make db-shell        - Open PostgreSQL shell"
	@echo "  make redis-cli       - Open Redis CLI"
	@echo "  make clean           - Remove all volumes and data"

# Docker Compose Commands
up:
	docker compose up -d

up-dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs

logs-f:
	docker compose logs -f

ps:
	docker compose ps

# Database variables
DB_HOST ?= localhost
DB_PORT ?= 5433
DB_USER ?= retich
DB_PASSWORD ?= retich_secret

AUTH_DB_URL = postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/retich_auth?sslmode=disable
USER_DB_URL = postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/retich_users?sslmode=disable
MESSAGING_DB_URL = postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/retich_messaging?sslmode=disable

# Migration Commands (requires golang-migrate CLI)
migrate-auth:
	migrate -path ../ReTiCh-Auth/migrations -database "$(AUTH_DB_URL)" up

migrate-user:
	migrate -path ../ReTiCh-User/migrations -database "$(USER_DB_URL)" up

migrate-messaging:
	migrate -path ../ReTiCh-Messaging/migrations -database "$(MESSAGING_DB_URL)" up

migrate-all: migrate-auth migrate-user migrate-messaging
	@echo "All migrations completed!"

rollback-auth:
	migrate -path ../ReTiCh-Auth/migrations -database "$(AUTH_DB_URL)" down 1

rollback-user:
	migrate -path ../ReTiCh-User/migrations -database "$(USER_DB_URL)" down 1

rollback-messaging:
	migrate -path ../ReTiCh-Messaging/migrations -database "$(MESSAGING_DB_URL)" down 1

# Migration status
migrate-status-auth:
	migrate -path ../ReTiCh-Auth/migrations -database "$(AUTH_DB_URL)" version

migrate-status-user:
	migrate -path ../ReTiCh-User/migrations -database "$(USER_DB_URL)" version

migrate-status-messaging:
	migrate -path ../ReTiCh-Messaging/migrations -database "$(MESSAGING_DB_URL)" version

# Utility Commands
db-shell:
	docker exec -it retich-postgres psql -U $(DB_USER)

redis-cli:
	docker exec -it retich-redis redis-cli

# Cleanup (DANGEROUS - removes all data)
clean:
	@echo "WARNING: This will remove all Docker volumes and data!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose down -v
	@echo "Cleanup complete."
