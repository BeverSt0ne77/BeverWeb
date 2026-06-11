# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

BeverWeb is the official website for Changsha Bever Information Technology Co., Ltd. (长沙贝弗信息科技有限公司, bever.cn). It is a **zero-build static site** — a single HTML file with inline CSS, no JavaScript, no bundler, no package.json. The repo also contains the nginx reverse proxy config and a GitHub Actions CI/CD pipeline.

## Repository Structure

```
BeverWeb/
  index/
    index.html      # Single-page static website (all content + inline CSS)
    gongan.png      # Chinese PSB备案 badge image
  nginx/
    nginx.conf      # Nginx reverse proxy config (port 80, caching, upload limits)
  .github/workflows/
    main.yaml       # CI/CD: SCP push to VPS on main branch push
  README.md
```

## Architecture

```
User Browser --> Nginx (port 80)
                  |
                  +---> / (this repo)             -- static index/index.html
                  |
                  +---> /bconvert/ (separate)     -- Vue SPA at /var/www/bever/bconvert/dist/
                  |
                  +---> /bconvert/api/ (separate) -- Java backend at localhost:8080
```

- The **root `/`** is served from this repo's `index/` directory.
- The **`/bconvert/`** product is a separate Vue SPA + Java Spring Boot backend, deployed independently on the same VPS. This repo only handles the nginx routing to it.
- **No JavaScript** on the main site — everything is HTML + CSS (including animations via `@keyframes`).

## Key Nginx Config Details

| Setting | Value | Reason |
|---|---|---|
| `client_max_body_size` | 200M | Video file uploads |
| `proxy_request_buffering` | off | Large upload streaming |
| `proxy_read_timeout` / `proxy_send_timeout` | 300s | Long video transcoding |
| `/bconvert/` cache | `expires 1y; public, immutable` | Vue SPA assets (content-hashed) |
| Gzip | text/css, text/html, application/json, etc. | |

## Deployment

**The only deployment command is `git push origin main`.** The GitHub Actions workflow at `.github/workflows/main.yaml`:

1. Checkout source
2. SCP `index/` and `nginx/` directories to `/var/www/bever` on the VPS
3. SSH in and run `nginx -s reload`

No build, test, or lint step exists. Secrets required: `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_PORT`.

## Development Workflow

- Edit `index/index.html` and verify locally by opening it in a browser (it's fully static).
- Edit `nginx/nginx.conf` when proxy behavior needs changing.
- There are **no tests**, **no linter**, **no formatter**, and **no package manager** configured.
- There is **no development server** — just open the HTML file or use any static file server.
