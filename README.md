<p align="center">
  <strong style="font-size: 2em;">InkHoard</strong>
</p>

<p align="center"><strong>Your books deserve a home. This is it.</strong></p>

<p align="center">
InkHoard is a self-hosted app that brings your entire book collection under one roof.<br/>
Organize, read, annotate, sync across devices, and share — all without relying on third-party services.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-AGPL_v3-blue.svg?style=flat-square" alt="License" /></a>
</p>

---

## About

InkHoard is a fork of [BookLore](https://github.com/booklore-app/booklore), rewritten from the ground up using a new technology stack:

| Layer          | Technology           |
| :------------- | :------------------- |
| **Backend**    | Elixir / Phoenix     |
| **Frontend**   | SvelteKit / Svelte 5 |
| **Database**   | PostgreSQL           |
| **Deployment** | Docker / Podman      |

---

## Features

|     | Feature                     | Description                                                                                                                |
| :-: | :-------------------------- | :------------------------------------------------------------------------------------------------------------------------- |
| 📚  | **Smart Shelves**           | Custom and dynamic shelves with rule-based Magic Shelves, filters, and full-text search                                    |
| 🔍  | **Automatic Metadata**      | Covers, descriptions, reviews, and ratings pulled from Google Books, Open Library, and Amazon — all editable               |
| 📖  | **Built-in Readers**        | Open EPUBs, PDFs, comics (CBZ/CBR), and audiobooks right in the browser with annotations, highlights, and reading progress |
| 🔄  | **Device Sync**             | Kobo, KOReader, and OPDS-compatible apps. Your library follows you everywhere                                              |
| 👥  | **Multi-User**              | Individual shelves, progress, and preferences per user with local or OIDC authentication                                   |
| 📥  | **BookDrop**                | Drop files into a watched folder — InkHoard detects, enriches, and queues them for import automatically                    |
| 📧  | **Email & Kindle Delivery** | Send any book to a Kindle, email address, or friend                                                                        |
| 🎨  | **Themes & i18n**           | Full theme system with dark/light modes and internationalization via Paraglide-js                                          |
| 📊  | **Statistics**              | Reading sessions, progress tracking, and analytics dashboard                                                               |
| 🔐  | **Parental Controls**       | Content restriction system for shared family libraries                                                                     |
| 📓  | **Notebook**                | Unified view of annotations, bookmarks, and notes across all your books                                                    |
| 🔔  | **Real-Time Notifications** | Live updates via Phoenix Channels for background jobs, metadata fetches, and more                                          |

---

## Quick Start

> **Prerequisites**: [Docker](https://docs.docker.com/get-docker/), [Elixir 1.17+](https://elixir-lang.org/install.html), [Node.js 22+](https://nodejs.org/), [pnpm](https://pnpm.io/), and `make`

```bash
git clone https://github.com/neoplatonist/inkhoard.git && cd inkhoard
make setup   # starts PostgreSQL, installs deps, creates & migrates DB
```

Then in separate terminals:

```bash
make start.api   # Phoenix backend  → http://localhost:4000
make start.web   # SvelteKit frontend → http://localhost:5173
```

### Available Make Targets

| Command         | Description                             |
| :-------------- | :-------------------------------------- |
| `make setup`    | Full first-time setup (db + deps)       |
| `make start`    | Start backend and frontend              |
| `make test`     | Run all tests (backend + frontend)      |
| `make lint`     | Format check, Credo, Svelte check       |
| `make db`       | Start PostgreSQL container              |
| `make db.reset` | Drop and recreate the database          |
| `make clean`    | Stop containers, remove build artifacts |

---

## Architecture

InkHoard is designed as a self-hosted-first application with a SaaS-ready architecture:

- **Elixir/Phoenix** backend with Oban for background job processing
- **SvelteKit** frontend with SSR, PWA support, and offline capabilities
- **PostgreSQL** with full-text search (`tsvector` + `pg_trgm`), no external search service needed
- **NimblePool** process pools for CLI tools (mutool, unrar, 7z, ffprobe, kepubify)
- **Prometheus/PromEx** monitoring with optional Grafana dashboards

For full technical details, see the [design documents](.specs/booklore-rewrite/).

---

## Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change before submitting a pull request.

---

## Acknowledgments

InkHoard is a fork of [BookLore](https://github.com/booklore-app/booklore) by [Aditya Chandel](https://github.com/adityachandelgit) and contributors. We are grateful for their work in building the original application.

---

## License

**GNU Affero General Public License v3.0**

InkHoard is a derivative work of [BookLore](https://github.com/booklore-app/booklore), which is licensed under the AGPL-3.0. As required by the license, InkHoard is also distributed under the same terms.

Copyright 2024-2026 BookLore contributors
Copyright 2026 InkHoard contributors

See [LICENSE](LICENSE) for the full license text.

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/agpl-3.0.html)
