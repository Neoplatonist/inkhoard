.PHONY: setup setup.api setup.web start start.api start.web test test.api test.web lint db db.reset clean

## First-time setup — run this after cloning
setup: db setup.api setup.web

setup.api:
	cd apps/api && mix setup

setup.web:
	cd apps/web && pnpm install

## Start services
start: db start.api start.web

start.api:
	cd apps/api && mix phx.server

start.web:
	cd apps/web && pnpm dev

## Database
db:
	docker compose -f docker-compose.dev.yml up -d

db.reset:
	cd apps/api && mix ecto.reset

## Tests
test: test.api test.web

test.api:
	cd apps/api && mix test

test.web:
	cd apps/web && pnpm test

## Lint / quality
lint: lint.api lint.web

lint.api:
	cd apps/api && mix format --check-formatted && mix credo --strict

lint.web:
	cd apps/web && pnpm check

## Cleanup
clean:
	docker compose -f docker-compose.dev.yml down
	rm -rf apps/api/_build apps/api/deps
	rm -rf apps/web/node_modules apps/web/build
