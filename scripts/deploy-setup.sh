#!/bin/bash

echo "=== Starting deployment setup ==="

# Set working directory
cd /app

# Debug environment variables
echo "=== Environment check ==="
echo "DB_CONNECTION: ${DB_CONNECTION:-not set}"
echo "DB_HOST: ${DB_HOST:-not set}"
echo "DB_DATABASE: ${DB_DATABASE:-not set}"
echo "APP_ENV: ${APP_ENV:-not set}"
echo "APP_KEY: ${APP_KEY:+set}"

# Generate app key if not set
if [ -z "$APP_KEY" ]; then
    echo "=== Generating application key ==="
    php artisan key:generate --force 2>/dev/null || echo "Key generation failed"
fi

# Clear any cached config first
echo "=== Clearing cached configuration ==="
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan route:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

# Wait for database to be ready (if using external database)
if [ "$DB_CONNECTION" = "mysql" ] && [ -n "$DB_HOST" ]; then
    echo "=== Waiting for database connection ==="
    for i in {1..30}; do
        if php artisan migrate:status 2>/dev/null; then
            echo "Database connection successful"
            break
        fi
        echo "Waiting for database... attempt $i/30"
        sleep 2
    done
fi

# Run migrations
echo "=== Running database migrations ==="
if php artisan migrate --force 2>/dev/null; then
    echo "Migrations completed successfully"
else
    echo "Migrations failed or already up to date"
fi

# Run seeders
echo "=== Running database seeders ==="
if php artisan db:seed --class=RolesTableSeeder --force 2>/dev/null; then
    echo "Seeders completed successfully"
else
    echo "Seeders failed or already run"
fi

# Cache configuration
echo "=== Caching configuration ==="
php artisan config:cache 2>/dev/null || echo "Config cache failed"

# Create storage link
echo "=== Creating storage link ==="
php artisan storage:link 2>/dev/null || echo "Storage link already exists"

# Set proper permissions
echo "=== Setting permissions ==="
chmod -R 755 storage bootstrap/cache 2>/dev/null || true
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true

echo "=== Deployment setup completed! ===" 