# Docker Setup Documentation

This project includes Docker Compose configuration for both development and production environments using Docker Compose profiles.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM available for Docker

## Quick Start

### Development Environment

1. **Copy environment file:**
   ```bash
   cp .env.docker.example .env
   ```

2. **Generate application key:**
   ```bash
   docker compose --profile dev run --rm app-dev php artisan key:generate
   ```

3. **Start development services:**
   ```bash
   docker compose --profile dev up -d
   ```

4. **Run migrations:**
   ```bash
   docker compose --profile dev exec app-dev php artisan migrate
   ```

5. **Access the application:**
   - Laravel App: http://localhost:8000
   - Umami Analytics: http://localhost:3000
   - PostgreSQL (direct): localhost:5432
   - PgBouncer: localhost:6432
   - Redis: localhost:6379

### Production Environment

1. **Copy environment file:**
   ```bash
   cp .env.docker.example .env
   ```

2. **Update production environment variables:**
   - Set `APP_ENV=production`
   - Set `APP_DEBUG=false`
   - Generate strong passwords for databases
   - Set `APP_KEY` (generate with `php artisan key:generate`)

3. **Build production images:**
   ```bash
   docker compose --profile prod build
   ```

4. **Start production services:**
   ```bash
   docker compose --profile prod up -d
   ```

5. **Run migrations:**
   ```bash
   docker compose --profile prod exec app php artisan migrate --force
   ```

## Services Overview

### Core Application Services

- **app** / **app-dev**: Laravel application with Octane + FrankenPHP
- **queue** / **queue-dev**: Laravel queue worker
- **scheduler**: Laravel task scheduler (production only)

### Database Services

- **postgres**: PostgreSQL 16 database
- **pgbouncer**: PgBouncer connection pooler (transaction pooling mode)

### Cache/Session Services

- **redis**: Redis cache and session store

### Analytics Services

- **umami**: Umami analytics application
- **umami-db**: PostgreSQL database for Umami

## Environment Variables

### Application Variables

```env
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000
```

### Database Variables

```env
# Application uses PgBouncer (port 6432)
DB_CONNECTION=pgsql
DB_HOST=pgbouncer
DB_PORT=6432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel

# Direct PostgreSQL connection for migrations
DB_DIRECT_HOST=postgres
DB_DIRECT_PORT=5432
```

### Redis Variables

```env
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_DB=0
```

### Umami Variables

```env
UMAMI_DB_NAME=umami
UMAMI_DB_USER=umami
UMAMI_DB_PASSWORD=umami
UMAMI_HASH_SALT=change-me-in-production
```

## Common Commands

### Development

```bash
# Start all services
docker compose --profile dev up -d

# View logs
docker compose --profile dev logs -f app-dev

# Run Artisan commands
docker compose --profile dev exec app-dev php artisan migrate
docker compose --profile dev exec app-dev php artisan tinker

# Run tests
docker compose --profile dev exec app-dev php artisan test

# Install dependencies
docker compose --profile dev exec app-dev composer install
docker compose --profile dev exec app-dev bun install

# Build assets (if running Vite separately)
docker compose --profile dev exec app-dev bun run build

# Stop services
docker compose --profile dev down

# Stop and remove volumes
docker compose --profile dev down -v
```

### Production

```bash
# Build images
docker compose --profile prod build

# Start services
docker compose --profile prod up -d

# View logs
docker compose --profile prod logs -f app

# Run Artisan commands
docker compose --profile prod exec app php artisan migrate --force
docker compose --profile prod exec app php artisan config:cache
docker compose --profile prod exec app php artisan route:cache
docker compose --profile prod exec app php artisan view:cache

# Reload Octane workers
docker compose --profile prod exec app php artisan octane:reload

# Stop services
docker compose --profile prod down
```

## Database Connection

### Using PgBouncer (Recommended)

The application is configured to use PgBouncer for all database connections. This provides connection pooling and better performance.

**Connection String:**
```
Host: pgbouncer
Port: 6432
Database: laravel
Username: laravel
Password: laravel
```

### Direct PostgreSQL Connection

For migrations and administrative tasks, use direct PostgreSQL connection:

**Connection String:**
```
Host: postgres
Port: 5432
Database: laravel
Username: laravel
Password: laravel
```

**Note:** Some Laravel commands (like migrations) may need direct PostgreSQL connection. You can temporarily change `DB_HOST` to `postgres` and `DB_PORT` to `5432` in your `.env` file.

## PgBouncer Configuration

PgBouncer is configured with:
- **Pool Mode**: Transaction pooling (optimal for Laravel)
- **Max Client Connections**: 1000
- **Default Pool Size**: 25
- **Port**: 6432

Configuration files:
- `docker/pgbouncer/pgbouncer.ini` - Main configuration
- `docker/pgbouncer/userlist.txt` - User authentication

### Updating PgBouncer Userlist

If you change database passwords, you need to update the PgBouncer userlist file:

1. **Generate userlist entry:**
   ```bash
   ./docker/pgbouncer/generate-userlist.sh laravel your-new-password
   ```

2. **Update `docker/pgbouncer/userlist.txt`** with the generated entry

3. **Restart PgBouncer:**
   ```bash
   docker compose --profile dev restart pgbouncer
   ```

The userlist format is: `"username" "md5hash"` where the hash is `md5(password + username)`.

## Volumes

### Development
- Source code is mounted as volumes for live reloading
- Database data persisted in `postgres_data` volume
- Redis data persisted in `redis_data` volume
- Umami database persisted in `umami_db_data` volume

### Production
- Source code is copied into Docker image (no volumes)
- Database data persisted in `postgres_data` volume
- Redis data persisted in `redis_data` volume
- Umami database persisted in `umami_db_data` volume

## Health Checks

All services include health checks:
- **app**: Checks Octane status endpoint
- **postgres**: Uses `pg_isready`
- **pgbouncer**: Checks pool status
- **redis**: Uses `redis-cli ping`
- **umami**: Checks `/api/health` endpoint

## Troubleshooting

### Database Connection Issues

If you encounter database connection errors:

1. **Check if services are running:**
   ```bash
   docker compose --profile dev ps
   ```

2. **Check database health:**
   ```bash
   docker compose --profile dev exec postgres pg_isready -U laravel
   ```

3. **Check PgBouncer:**
   ```bash
   docker compose --profile dev exec pgbouncer psql -h localhost -p 6432 -U pgbouncer -d pgbouncer -c "SHOW POOLS;"
   ```

4. **Use direct PostgreSQL for migrations:**
   Temporarily change `.env`:
   ```env
   DB_HOST=postgres
   DB_PORT=5432
   ```

### Redis Connection Issues

1. **Check Redis:**
   ```bash
   docker compose --profile dev exec redis redis-cli ping
   ```

2. **Check Redis password:**
   Ensure `REDIS_PASSWORD` in `.env` matches the password set in docker-compose.yml

### Umami Setup

1. **Access Umami:**
   - URL: http://localhost:3000
   - Default credentials: `admin` / `umami` (change on first login)

2. **Check Umami database:**
   ```bash
   docker compose --profile dev exec umami-db psql -U umami -d umami
   ```

### Rebuilding Images

If you need to rebuild images:

```bash
# Development
docker compose --profile dev build --no-cache

# Production
docker compose --profile prod build --no-cache
```

### Clearing Volumes

To start fresh (⚠️ **WARNING**: This deletes all data):

```bash
docker compose --profile dev down -v
docker compose --profile prod down -v
```

## Production Deployment Notes

1. **Environment Variables:**
   - Set strong passwords for all services
   - Set `APP_ENV=production`
   - Set `APP_DEBUG=false`
   - Generate and set `APP_KEY`
   - Set `UMAMI_HASH_SALT` to a random string

2. **Security:**
   - Don't expose PostgreSQL port (5432) in production
   - Use strong Redis password
   - Configure proper firewall rules
   - Use HTTPS with proper SSL certificates

3. **Performance:**
   - Run `php artisan config:cache`
   - Run `php artisan route:cache`
   - Run `php artisan view:cache`
   - Optimize Composer autoloader (already done in Dockerfile)

4. **Monitoring:**
   - Set up log aggregation
   - Monitor container health
   - Monitor database connections
   - Monitor Redis memory usage

## Additional Resources

- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [FrankenPHP Documentation](https://frankenphp.dev/docs)
- [PgBouncer Documentation](https://www.pgbouncer.org/config.html)
- [Umami Documentation](https://umami.is/docs)

