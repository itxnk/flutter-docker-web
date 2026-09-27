# Flutter Docker Web

A simple Flutter web application packaged and served with Docker and Nginx.

## Architecture

Flutter source → `flutter build web` → Docker multi-stage build → Nginx → `localhost:8080`

## Run with Flutter

```bash
flutter pub get
flutter run -d chrome
```

## Run with Docker

Build and start the container:

```bash
docker compose up -d --build
```

Open:

```text
http://localhost:8080
```

Check the container:

```bash
docker compose ps
docker compose logs
```

Stop it:

```bash
docker compose down
```

## Manual Docker commands

```bash
docker build -t flutter-docker-web .
docker run -d --name flutter-web -p 8080:80 flutter-docker-web
```

Test the HTTP response:

```bash
curl http://localhost:8080
```

Remove the container:

```bash
docker rm -f flutter-web
```

## Project structure

```text
flutter-docker-web/
├── lib/
│   └── main.dart
├── web/
│   └── index.html
├── Dockerfile
├── docker-compose.yml
├── pubspec.yaml
├── .gitignore
└── README.md
```

## Learning goals

- Flutter Web basics
- Dart application structure
- Docker images and containers
- Multi-stage Docker builds
- Nginx static web serving
- Docker Compose
- Local container testing
