#!/bin/bash

echo "Starting deployment setup..."

# Wait for database to be ready (in case of connection issues)
echo "Waiting for database connection..."
php artisan tinker --execute="DB::connection()->getPdo();" || {
    echo "Database connection failed. Retrying in 5 seconds..."
    sleep 5
    php artisan tinker --execute="DB::connection()->getPdo();" || {
        echo "Database still not ready. Continuing anyway..."
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