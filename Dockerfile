# Multi-stage Dockerfile for Laravel Octane with FrankenPHP

# Stage 1: Base image with PHP extensions
FROM dunglas/frankenphp:latest AS base

# Install system dependencies and PHP extensions
RUN install-php-extensions \
    pcntl \
    pdo_pgsql \
    redis \
    zip \
    gd \
    intl \
    opcache

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    cp /root/.bun/bin/bun /usr/local/bin/bun

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Stage 2: Dependencies installation
FROM base AS dependencies

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader

# Copy package files
COPY package.json ./
COPY bun.lock* ./

# Install JavaScript dependencies
RUN if [ -f bun.lockb ]; then bun install --frozen-lockfile --production; else bun install --production; fi

# Stage 3: Build assets
FROM dependencies AS build

# Copy application source
COPY . .

# Build assets
RUN bun run build

# Stage 4: Production image
FROM base AS production

# Copy installed dependencies from dependencies stage
COPY --from=dependencies /app/vendor /app/vendor
COPY --from=dependencies /app/node_modules /app/node_modules

# Copy built assets from build stage
COPY --from=build /app/public/build /app/public/build
COPY --from=build /app/bootstrap/ssr /app/bootstrap/ssr

# Copy application files
COPY . /app

# Set permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache && \
    chmod -R 775 /app/storage /app/bootstrap/cache

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD php artisan octane:status || exit 1

# Start Octane with FrankenPHP
ENTRYPOINT ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8000"]

