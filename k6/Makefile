NAMESPACE   = k6
TEST_NAME   = retich-load-test
EMAIL       ?= salamataomohamed7@gmail.com
PASSWORD    ?= Iman-7814
AUDIENCE    ?= retich-client

# ─── Commandes principales ───────────────────────────────────────────────────

.PHONY: init
init:
	@echo ">>> Installation de k6 Operator..."
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install k6-operator grafana/k6-operator -n k6-operator --create-namespace || true
	@echo ">>> Création du namespace et du ConfigMap..."
	kubectl apply -f namespace.yaml
	kubectl apply -f configmap.yaml
	@echo ">>> Création du secret..."
	kubectl create secret generic retich-load-test-env \
		--from-literal=EMAIL=$(EMAIL) \
		--from-literal=PASSWORD=$(PASSWORD) \
		--from-literal=AUDIENCE=$(AUDIENCE) \
		-n $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@echo ""
	@echo "Setup terminé. Lance le test avec : make start"

.PHONY: start
start:
	kubectl delete testrun $(TEST_NAME) -n $(NAMESPACE) --ignore-not-found
	@sleep 3
	kubectl apply -f testrun.yaml
	@echo "Attente du démarrage des pods..."
	kubectl wait --for=condition=ready pod -l k6_cr=$(TEST_NAME) -n $(NAMESPACE) --timeout=120s
	@echo "Test en cours... logs :"
	kubectl logs -f -l k6_cr=$(TEST_NAME) -n $(NAMESPACE) --max-log-requests 10

# ─── Installation ────────────────────────────────────────────────────────────

.PHONY: install-operator
install-operator:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install k6-operator grafana/k6-operator -n k6-operator --create-namespace

.PHONY: install-prometheus
install-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install prometheus prometheus-community/prometheus \
		-n monitoring --create-namespace \
		-f prometheus-values.yaml

# ─── Setup ───────────────────────────────────────────────────────────────────

.PHONY: setup
setup:
	kubectl apply -f namespace.yaml
	kubectl apply -f configmap.yaml
	@echo ""
	@echo "⚠️  Crée maintenant le secret avec tes credentials :"
	@echo "   kubectl create secret generic retich-load-test-env \\"
	@echo "     --from-literal=EMAIL=ton@email.com \\"
	@echo "     --from-literal=PASSWORD=TonMotDePasse \\"
	@echo "     --from-literal=AUDIENCE=retich-client \\"
	@echo "     -n $(NAMESPACE)"

# ─── Test ────────────────────────────────────────────────────────────────────

.PHONY: run
run:
	kubectl apply -f testrun.yaml
	@echo "Test lancé. Suivre les logs :"
	@echo "   make logs"

.PHONY: logs
logs:
	kubectl logs -f -l k6_cr=$(TEST_NAME) -n $(NAMESPACE) --max-log-requests 10

.PHONY: status
status:
	kubectl get testrun $(TEST_NAME) -n $(NAMESPACE) -o wide

.PHONY: watch
watch:
	kubectl get testrun $(TEST_NAME) -n $(NAMESPACE) -w

# ─── Nettoyage ───────────────────────────────────────────────────────────────

.PHONY: stop
stop:
	kubectl delete testrun $(TEST_NAME) -n $(NAMESPACE) --ignore-not-found

.PHONY: clean
clean: stop
	kubectl delete configmap retich-load-test -n $(NAMESPACE) --ignore-not-found
	kubectl delete secret retich-load-test-env -n $(NAMESPACE) --ignore-not-found

# ─── Mise à jour du script ───────────────────────────────────────────────────

.PHONY: update-script
update-script:
	kubectl delete configmap retich-load-test -n $(NAMESPACE) --ignore-not-found
	kubectl apply -f configmap.yaml
	@echo "Script mis à jour. Relance avec : make run"
