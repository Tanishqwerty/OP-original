#!/bin/bash

echo "=== Starting deployment setup ==="

# Debug environment variables
echo "=== Environment check ==="
echo "DB_CONNECTION: $DB_CONNECTION"
echo "DB_HOST: $DB_HOST"
echo "DB_DATABASE: $DB_DATABASE"
echo "APP_ENV: $APP_ENV"
echo "APP_DEBUG: $APP_DEBUG"

# Clear any cached config first
echo "=== Clearing cached configuration ==="
php artisan config:clear || echo "Config clear failed (this is normal on first run)"
php artisan cache:clear || echo "Cache clear failed (this is normal on first run)"

# Test database connection with timeout
echo "=== Testing database connection ==="
timeout 30 php artisan tinker --execute="
try {
    \$pdo = DB::connection()->getPdo();
    echo 'Database connection successful: ' . DB::connection()->getDatabaseName() . PHP_EOL;
    echo 'Connection type: ' . DB::connection()->getDriverName() . PHP_EOL;
    echo 'Host: ' . config('database.connections.' . config('database.default') . '.host') . PHP_EOL;
} catch (Exception \$e) {
    echo 'Database connection failed: ' . \$e->getMessage() . PHP_EOL;
    exit(1);
}
" || {
    echo "Database connection test failed or timed out"
    echo "Attempting to continue with basic setup..."
}

# Run migrations with error handling
echo "=== Running database migrations ==="
if php artisan migrate --force; then
    echo "Migrations completed successfully"
else
    echo "Migration failed, but continuing..."
fi

# Run seeders with error handling
echo "=== Running database seeders ==="
if php artisan db:seed --class=RolesTableSeeder --force; then
    echo "Seeders completed successfully"
else
    echo "Seeder failed or already run, continuing..."
fi

# Clear and cache config
echo "=== Caching configuration ==="
php artisan config:cache || echo "Config cache failed"

# Clear and cache routes
echo "=== Caching routes ==="
php artisan route:clear || echo "Route clear failed"
php artisan route:cache || echo "Route cache failed"

# Clear and cache views
echo "=== Caching views ==="
php artisan view:clear || echo "View clear failed"
php artisan view:cache || echo "View cache failed"

# Create storage link
echo "=== Creating storage link ==="
php artisan storage:link || echo "Storage link already exists or failed to create"

echo "=== Deployment setup completed successfully! ==="
echo "=== Starting Laravel server ===" 