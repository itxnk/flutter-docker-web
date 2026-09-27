# Khan Footwear — Flutter + Docker E-commerce

A learning-focused full-stack shoe store built with Flutter Web, Nginx, Node.js/Express and PostgreSQL.

## Features

- Responsive shoe-store UI
- Chelsea boots, sneakers, formal shoes, casual boots, loafers and running shoes
- Prices and percentage discounts
- Product details and shoe sizes
- Search and category filtering
- Shopping cart UI
- Login/register API foundation
- WhatsApp contact placeholder
- Node.js REST API
- PostgreSQL users/products/orders database
- bcrypt password hashing and JWT authentication API
- Order API
- JazzCash/Easypaisa/Cash-on-Delivery payment-method API placeholder
- Docker Compose with frontend, backend and PostgreSQL
- Nginx serves Flutter and proxies `/api/` to the backend

## Run locally

```bash
git pull
docker compose down
docker compose up -d --build
docker compose ps
```

Open:

`http://localhost:8080`

Backend health check:

`http://localhost:8080/api/health`

## Services

| Service | Container | Purpose |
|---|---|---|
| Flutter/Nginx | footwear-web | Website + API reverse proxy |
| Node.js | footwear-api | REST API, auth and orders |
| PostgreSQL | footwear-db | Persistent application data |

## Architecture

```text
Browser
   |
   v
Flutter Web + Nginx :8080
   |
   +---- /api/* ----> Node.js/Express :3000
                           |
                           v
                      PostgreSQL :5432
```

## Important before production

1. Change development passwords and `JWT_SECRET`.
2. Store secrets in a secret manager or environment, not Git.
3. Add HTTPS/TLS.
4. Add server-side cart, inventory and price validation.
5. Connect real JazzCash and Easypaisa merchant sandbox credentials.
6. Verify payment callbacks/webhooks before marking orders paid.
7. Replace the placeholder WhatsApp number `923000000000` in `lib/main.dart` with the store's real business number.
8. Add an admin dashboard for products, stock, discounts and orders.

## Project structure

```text
flutter-docker-web/
├── lib/main.dart
├── web/
├── backend/
│   ├── server.js
│   ├── package.json
│   ├── Dockerfile
│   └── init.sql
├── Dockerfile
├── nginx.conf
├── docker-compose.yml
├── pubspec.yaml
└── README.md
```
