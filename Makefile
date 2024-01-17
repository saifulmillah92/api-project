# Makefile

# Variables
DOCKER_COMPOSE_FILE = docker-compose.yml
DOCKER_COMPOSE = docker-compose -f $(DOCKER_COMPOSE_FILE)

# Docker commands
.PHONY: build
build:
	$(DOCKER_COMPOSE) build

.PHONY: db-prepare
db-prepare:
	$(DOCKER_COMPOSE) run web rake db:prepare db:migrate

.PHONY: run
run:
	$(DOCKER_COMPOSE) up -d

.PHONY: down
down:
	$(DOCKER_COMPOSE) down

.PHONY: db-migrate
db-migrate:
	$(DOCKER_COMPOSE) run web rake db:migrate

.PHONY: db-rollback
db-rollback:
	$(DOCKER_COMPOSE) run web rake db:rollback STEP=$(if $(STEP),$(STEP),1)

.PHONY: rspec
rspec:
	$(DOCKER_COMPOSE) run web rspec $(FILE)

.PHONY: console
console:
	$(DOCKER_COMPOSE) run web bin/rails console

.PHONY: linter
linter:
	@echo "Checking for changed and new files..."
	@CHANGED_FILES=$$(git diff --name-only); \
		NEW_FILES=$$(git ls-files --others --exclude-standard); \
		RUBY_FILES=$$(echo "$$CHANGED_FILES $$NEW_FILES" | grep '\.rb$$'); \
		if [ -n "$$RUBY_FILES" ]; then \
			echo "Running RuboCop on changed and new Ruby files:"; \
			$(DOCKER_COMPOSE) run web bundle exec rubocop $$RUBY_FILES; \
		else \
			echo "No changed or new Ruby files found."; \
		fi
