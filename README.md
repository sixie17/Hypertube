# Hypertube

Full-stack app with a NestJS backend, a Next.js frontend, and a Postgres database, orchestrated with Docker Compose.

## Stack

- **backend/** — NestJS (TypeScript), TypeORM, Postgres
- **frontend/** — Next.js (TypeScript, Tailwind)
- **nginx/** — reverse proxy config used in production
- Everything runs in Docker; the `Makefile` wraps `docker compose` so you don't have to remember the flags.

## Package manager: pnpm only

This project uses **pnpm** exclusively, in both `backend/` and `frontend/`. Both Dockerfiles install dependencies with `pnpm install --frozen-lockfile`, so a correct, up-to-date `pnpm-lock.yaml` is required for every build (dev, prod, and CI) to succeed.

Rules to keep builds from breaking:

- **Never run `npm install` or `yarn` anywhere in this repo.** Mixing package managers produces a `package-lock.json` or `yarn.lock` that drifts from `pnpm-lock.yaml`, and Docker will silently keep using the (now stale) `pnpm-lock.yaml` while your local `node_modules` disagrees with it.
- Always install/add dependencies with `pnpm install` / `pnpm add` / `pnpm remove`, either locally (with `pnpm` installed via Corepack) or inside the running container via `make sync-deps`.
- Both `backend/package.json` and `frontend/package.json` pin `"packageManager": "pnpm@10.32.1"`. Run `corepack enable` once on your machine so Corepack enforces that version automatically.
- Whenever you add/remove/update a dependency, commit the updated `pnpm-lock.yaml`. `--frozen-lockfile` in the Dockerfiles means the build **fails on purpose** if the lockfile doesn't match `package.json`, instead of silently installing something different.
- If you ever see a `package-lock.json` or `yarn.lock` show up (e.g. from an editor auto-run or a stray `npm install`), delete it — it isn't used by the build and its presence is a sign the lockfile may be out of sync.

## Prerequisites

- Docker and Docker Compose
- Node.js + [pnpm](https://pnpm.io) via Corepack, only needed if you want to run tooling (lint, tests, editor TS server) outside of Docker:
  ```bash
  corepack enable
  ```

## Environment variables

Copy the example env file and adjust as needed:

```bash
cp .env.example .env
```

This provides the Postgres credentials (`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `POSTGRES_HOST`, `POSTGRES_PORT`) and `DATABASE_URL` used by both the `db` and `backend` containers.

## Running the project

All commands are run from the repository root.

```bash
make dev    # start the dev stack (frontend, backend, db) with hot-reloading
make logs   # tail logs from the dev containers
make down   # stop the dev containers
```

Dev URLs:

- Frontend: http://localhost:3000
- Backend: http://localhost:3001
- Postgres: localhost:5432

Dev containers mount your local `frontend/` and `backend/` directories into the container, so code changes are picked up automatically (hot reload / `nest start --watch`).

```bash
make prod       # build and run the production stack locally (nginx + built frontend/backend)
make down-prod  # stop the production containers
make clean      # stop dev + prod containers and wipe DB volumes (deletes local DB data)
```

## Writing code

- Edit files under `backend/` or `frontend/` as usual — the dev containers pick up changes live via the mounted volumes.
- If a dependency was added/changed in `package.json`, or `node_modules` inside a container gets out of sync with the lockfile, run:
  ```bash
  make sync-deps
  ```
  This runs `pnpm install` inside the running `backend-dev` and `frontend-dev` containers.
- To rebuild and force-recreate a single container after a Dockerfile change:
  ```bash
  make reload backend-dev
  make reload frontend-dev
  ```

### Database migrations (backend, TypeORM)

```bash
make create-migration NAME=AddUsersTable   # generate a migration from entity changes
make run-migration                          # apply all pending migrations
make revert-migration                       # roll back the last applied migration
```

These run inside the `backend-dev` container via `pnpm typeorm`.

### Linting / tests

Run these either inside the containers (`docker compose exec backend-dev pnpm lint`, etc.) or locally with pnpm if you have dependencies installed locally:

```bash
cd backend && pnpm lint && pnpm test
cd frontend && pnpm lint
```

## Makefile reference

Run `make help` at any time to see this list:

| Command | Description |
| --- | --- |
| `make dev` | Start development environment with hot-reloading |
| `make prod` | Build and run production stack locally |
| `make down` | Stop development containers |
| `make down-prod` | Stop production containers |
| `make logs` | View logs from development containers |
| `make clean` | Stop containers and wipe volumes (removes DB data) |
| `make create-migration NAME=...` | Generate a new migration from entity changes |
| `make run-migration` | Manually execute all pending migrations |
| `make revert-migration` | Roll back the last executed migration |
| `make sync-deps` | Sync pnpm dependencies inside the running dev containers |
| `make reload <container>` | Rebuild and force-recreate a single container, e.g. `make reload backend-dev` |
