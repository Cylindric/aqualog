# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

This root repo is an **orchestration/infra repo**, not an application itself. The actual applications live in two **git submodules**, each an independent GitHub repo with its own history and remote:

- `backend/` → `git@github.com:Cylindric/aqualog-backend.git` — FastAPI Python API
- `frontend/` → `git@github.com:Cylindric/aqualog-frontend.git` — React/Vite/TypeScript SPA

Everything else at the root is deployment/infra config, not app code:

- `docker-compose.yml`, `Caddyfile`, `proxy/` — local/prod compose stack (Authentik, Postgres, backend, frontend, reverse proxy)
- `authentik/` — Authentik (identity provider) compose + Terraform for OAuth2/OIDC provider/application setup
- `cloudflare/`, `digital_ocean/` — Terraform, Ansible, and Kubernetes manifests for cloud deployment
- `Taskfile.yml` (root) — thin wrapper that fans out into `backend`/`frontend` Taskfiles (`build-all`, `publish-all`), plus `up` (docker-compose) and `gource` (repo visualization)

**Because `backend/` and `frontend/` are separate git repos**, commits/branches inside them must be made and pushed from within that submodule directory, independently of the root repo (which only tracks a pinned submodule commit).

Both `backend/` and `frontend/` use an **OpenSpec spec-driven workflow** (`openspec/specs`, `openspec/changes`, `openspec/config.yaml`), driven by `opsx-*` slash commands defined in both `.github/prompts/*.prompt.md` and mirrored `.github/skills/openspec-*` skill packages. Workflow boundaries: `explore` (investigation only), `propose` (creates proposal/design/tasks artifacts), `apply` (implements tasks, checks off tasks.md), `sync` (merges delta specs into main specs), `archive` (archives a completed change dir). When editing this workflow, keep the paired prompt and skill files behaviorally in sync.

## Commands

### Backend (`backend/`, Python/Poetry via Taskfile)

```bash
cd backend
task setup            # one-time env setup (./tools/setup.sh)
task server           # poetry sync + alembic upgrade + run uvicorn (port 8001, --reload)
task test             # pytest -q --cov=src --cov-report=term-missing --html=artifacts/tests/index.html
task coverage         # same as test, plus HTML/XML coverage reports in artifacts/coverage
task db-migrate       # alembic upgrade head
task db-migration-new NAME="..."   # alembic revision --autogenerate -m NAME
task up / task down   # docker-compose up/down for the backend's own compose stack
task token            # get a dev Authentik token via ./tools/get_token-dev.sh
task auth-check       # validate Authentik token issuance end-to-end (./tools/spa)
```

Run a single test directly with poetry/pytest, e.g.:
```bash
poetry run pytest tests/test_aquariums.py -k create_aquarium -q
```
Tests set `AQUALOG_APP_ENV=test`, which makes `src/db.py` use an in-memory SQLite DB created via `Base.metadata.create_all` (not via Alembic) and reset per-test by the autouse `reset_db_state` fixture in `tests/conftest.py`.

There is no configured linter/formatter (no ruff/black/mypy in `pyproject.toml`) — don't invent lint commands.

### Frontend (`frontend/`, npm/Vite via Taskfile or npm directly)

```bash
cd frontend
npm run dev       # vite dev server, port 9002
npm run build     # tsc -b && vite build
npm run test      # vitest run
npm run test:watch
npm run preview   # preview production build
```
Single test file: `npx vitest run src/test/pages/AquariumsPage.test.tsx`.

`task backend` / `task frontend` in `frontend/Taskfile.yml` run the built static app behind the tiny FastAPI shim (`frontend/backend/main.py`) or the Vite dev server, respectively. No ESLint config is present — don't invent lint commands.

## Backend architecture (`backend/src/`)

- **App factory**: `src/app.py::create_app(settings)` builds the FastAPI app, wires logging (`configure_logging`, JSON file logs + console), CORS, `RequestLoggingMiddleware` (adds `request.state.request_id`), mounts routers under `/api/{settings.api_version}`, and — only in `dev`/`test` env — serves `/tests` and `/coverage` static report dirs from `artifacts/`.
- **Router-per-resource, factory pattern**: each resource module exposes a `build_x_router() -> APIRouter` function (`build_health_router`, `build_calculation_router`, `build_profile_router`, `build_aquarium_router`, `build_aquarium_measurement_router`) that `create_app` includes. New resources should follow this same factory shape rather than a module-level `router` singleton.
- **Repository pattern**: DB access is isolated behind `*Repository` classes (`AquariumRepository`, `AquariumMeasurementRepository`, `UserRepository`) — route handlers never touch SQLAlchemy sessions/queries directly, they call into a repository built from the injected `Session`. Repositories raise domain errors (e.g. `DuplicateAquariumNameError`) that routers translate into `HTTPException`s.
- **Response envelope**: all endpoint responses go through `src/responses.py::success_response`/`error_response`, producing `{"success": bool, "request_id": ..., "data" | "error": ...}`. Global exception handlers in `app.py` (validation, generic `Exception`, `HTTPException`) also funnel into this envelope. Preserve this shape for any new endpoint.
- **Auth**: `src/auth.py` implements OAuth2/OIDC bearer-token auth against Authentik — fetches/caches JWKS via the issuer's `.well-known/openid-configuration` (1hr TTL), validates signature/issuer/audience/expiry, then resolves/creates a local `User` row via `user_service.resolve_or_create_authenticated_user`. Protected routes depend on `get_current_user` (FastAPI `Depends`), giving an `AuthenticatedUser` wrapping the local `User` plus token claims.
- **Settings**: `src/config.py::Settings` (pydantic-settings) reads env vars prefixed `AQUALOG_` (e.g. `AQUALOG_OAUTH_ISSUER_URL`, `AQUALOG_DB_HOST`/`AQUALOG_DB_PORT`/`AQUALOG_DB_USER`/`AQUALOG_DB_PASSWORD`/`AQUALOG_DB_NAME`, `AQUALOG_APP_ENV`). `app_env` (`dev`/`test`/prod-like) gates dev-only behavior (docs mounts, test/coverage static mounts, sqlite-for-tests).
- **DB**: `src/db.py` — SQLAlchemy engine/session are module-level singletons configured lazily via `configure_database`/`init_database`; Postgres in real deployments (migrated with Alembic under `backend/alembic/`), SQLite in-memory for tests. `reset_database()` disposes the engine, used between tests.
- **Domain models** (`src/models.py`): `User` (unique per `oauth_issuer`+`oauth_subject`), `Aquarium` (unique `owner_user_id`+`name`), `AquariumMeasurement` (unique `aquarium_id`+`parameter`+`measured_at`, stores both normalized `value`/`unit` and original `raw_value`/`raw_unit`). All PKs are UUID strings.
- Mail sending (e.g. signup confirmation) goes through `backend/mail_proxy/` (a small Node service, built/deployed as its own Docker image alongside the backend).

## Frontend architecture (`frontend/src/`)

- Stack: Vite + React 19 + TypeScript + Mantine (`@mantine/core`, `@mantine/charts`/`recharts` for charts) + `react-router` + `react-oidc-context`/`oidc-client-ts` for OIDC Authorization Code + PKCE against Authentik.
- **Runtime config, not build-time config**: `src/config.ts::loadRuntimeConfig()` fetches `/api/runtime-config` at startup and populates a module-level `config` object (API base URL, OIDC authority/client/redirect URIs/scope, app version). This endpoint is served by the small FastAPI shim in `frontend/backend/main.py`, which whitelists specific `AQUALOG_*` env vars from its own environment — the same static build is reused across environments by changing env vars on that shim, not by rebuilding. `isConfigured()`/`configErrors()` drive `ConfigErrorPage`.
- **API client** (`src/api/client.ts`): a single `apiRequest<T>` wrapper used by all `api/*.ts` modules — attaches the bearer token via an injected `AccessTokenProvider`, retries once via `RefreshAccessTokenProvider` on a 401, normalizes FastAPI's validation-error envelope into `ApiRequestError`/`ValidationErrorItem[]`, and exposes `toUserMessage()` for user-facing error strings. New API calls should go through `apiGet`/`apiPost`/`apiPatch`/`apiDelete` here rather than calling `fetch` directly.
- Folder structure: `api/` (backend calls), `auth/` (OIDC provider wiring + error messaging), `components/` (shared shell/nav), `features/<feature>/` (feature-specific components + hooks, e.g. `salinity/`), `pages/` (route-level components), `hooks/` (cross-cutting hooks like readiness polling). Tests mirror this under `src/test/**` using Vitest + Testing Library + `jsdom` (`src/test/setup.ts`).
- Vite build manually chunks vendor bundles (`vendor-charts`, `vendor-mantine`, `vendor-auth`, `vendor-react`) in `vite.config.ts` — keep new heavy deps categorized there if bundle-splitting matters.

## Cross-cutting conventions

- Backend and frontend independently version with `commitizen` (conventional commits, `cz_conventional_commits`, `tag_format = v$version`, `version_provider = pep621`) — commit messages in either submodule should follow Conventional Commits so version bumps/changelogs stay automatable.
- All `AQUALOG_*` env vars are the shared contract between backend, frontend-shim, and Authentik/OAuth2 config across `docker-compose.yml`, both `.env.example` files, and Kubernetes manifests under `digital_ocean/kube-configs/` — when adding a new config value, it typically needs updating in more than one of these places.
