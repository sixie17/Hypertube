.PHONY: help dev prod down down-prod logs clean create-migration run-migration revert-migration reload

help:
	@echo "  make dev              - Start development environment with hot-reloading"
	@echo "  make prod             - Build and run production stack locally"
	@echo "  make down             - Stop development containers"
	@echo "  make down-prod        - Stop production containers"
	@echo "  make logs             - View logs from development containers"
	@echo "  make clean            - Stop containers and wipe volumes (removes DB data)"
	@echo "  make create-migration - Generate a new migration based on entity changes"
	@echo "                          (Usage: make create-migration NAME=AddUsersTable)"
	@echo "  make run-migration    - Manually execute all pending migrations"
	@echo "  make revert-migration - Roll back the single last executed migration"
	@echo "  make sync-deps        - Syncs dependencies in dev environment"
	@echo "  make reload <name>    - Rebuild and force-recreate a single container"
	@echo "                          (Usage: make reload backend-dev)"

dev:
	docker compose -f compose.yml up -d --build

prod:
	docker compose -f compose.prod.yaml up -d --build

down:
	docker compose down

down-prod:
	docker compose -f compose.prod.yaml down

logs:
	docker compose logs -f

clean:
	docker compose down -v
	docker compose -f compose.prod.yaml down -v


create-migration:
	@ifndef NAME
		$(error NAME variable is required. Example: make create-migration NAME=AddUserTable)
	@endif
	docker compose exec backend-dev pnpm typeorm migration:generate src/migrations/$(NAME) -d dist/data-source.js

run-migration:
	docker compose exec backend-dev pnpm typeorm migration:run -d dist/data-source.js

revert-migration:
	docker compose exec backend-dev pnpm typeorm migration:revert -d dist/data-source.js

# run this if you get dependency not found
sync-deps:
	docker compose exec backend-dev pnpm install
	docker compose exec frontend-dev pnpm install
	@echo "Dependencies synced inside the running container!"

# Usage: make reload backend-dev
reload:
	@name="$(filter-out $@,$(MAKECMDGOALS))"; \
	if [ -z "$$name" ]; then \
		echo "Usage: make reload <container-name>"; \
		exit 1; \
	fi; \
	docker compose up -d --build --force-recreate -V $$name

%:
	@:
