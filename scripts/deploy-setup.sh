#!/bin/bash

echo "Starting deployment setup..."

# Debug environment variables
echo "Environment check:"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "DB_HOST: $DB_HOST"
echo "DB_DATABASE: $DB_DATABASE"
echo "APP_ENV: $APP_ENV"

# Clear any cached config first
echo "Clearing cached configuration..."
php artisan config:clear || echo "Config clear failed"
php artisan cache:clear || echo "Cache clear failed"

# Wait for database to be ready (in case of connection issues)
echo "Testing database connection..."
php artisan tinker --execute="
try {
    \$pdo = DB::connection()->getPdo();
    echo 'Database connection successful: ' . DB::connection()->getDatabaseName() . PHP_EOL;
    echo 'Connection type: ' . DB::connection()->getDriverName() . PHP_EOL;
} catch (Exception \$e) {
    echo 'Database connection failed: ' . \$e->getMessage() . PHP_EOL;
    exit(1);
}
" || {
    echo "Database connection failed. Retrying in 5 seconds..."
    sleep 5
    php artisan tinker --execute="
    try {
        \$pdo = DB::connection()->getPdo();
        echo 'Database connection successful on retry' . PHP_EOL;
    } catch (Exception \$e) {
        echo 'Database connection still failing: ' . \$e->getMessage() . PHP_EOL;
        exit(1);
    }
    " || {
        echo "Database connection failed after retry. Exiting..."
        exit 1
    }
}

# Run migrations
echo "Running database migrations..."
php artisan migrate --force

# Run seeders (for roles and other essential data)
echo "Running database seeders..."
php artisan db:seed --class=RolesTableSeeder --force || echo "Seeder failed or already run"

# Clear and cache config
echo "Clearing and caching configuration..."
php artisan config:clear
php artisan config:cache

# Clear and cache routes (if not already done)
echo "Clearing and caching routes..."
php artisan route:clear
php artisan route:cache

# Clear and cache views
echo "Clearing and caching views..."
php artisan view:clear
php artisan view:cache

# Create storage link if it doesn't exist
echo "Creating storage link..."
php artisan storage:link || echo "Storage link already exists or failed to create"

echo "Deployment setup completed!" 