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
echo "APP_URL: ${APP_URL:-not set}"

# Set APP_URL to HTTPS if not already set
if [ -z "$APP_URL" ] || [[ "$APP_URL" == *"http://"* ]]; then
    echo "=== Setting APP_URL to HTTPS ==="
    export APP_URL="https://orderprocessing.divinecareindustries.com"
    echo "APP_URL set to: $APP_URL"
fi

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

# Wait for database connection
echo "=== Waiting for database connection ==="
for i in {1..30}; do
    if php artisan migrate:status 2>/dev/null; then
        echo "Database connection successful"
        break
    fi
    echo "Waiting for database... ($i/30)"
    sleep 2
done

# Run migrations with better error handling
echo "=== Running database migrations ==="
php artisan migrate --force 2>/dev/null || {
    echo "Some migrations failed, trying to continue with individual migrations..."
    
    # Try to run specific migrations that are most likely to succeed
    php artisan migrate --path=database/migrations/2025_04_25_063609_create_warehouses_table.php --force 2>/dev/null || echo "Warehouses migration failed"
    php artisan migrate --path=database/migrations/2025_04_17_085947_create_shades_table.php --force 2>/dev/null || echo "Shades migration failed"
    php artisan migrate --path=database/migrations/2025_04_17_085957_create_patterns_table.php --force 2>/dev/null || echo "Patterns migration failed"
    php artisan migrate --path=database/migrations/2025_04_17_090007_create_sizes_table.php --force 2>/dev/null || echo "Sizes migration failed"
    php artisan migrate --path=database/migrations/2025_04_17_090014_create_embroidery_options_table.php --force 2>/dev/null || echo "Embroidery options migration failed"
    php artisan migrate --path=database/migrations/2025_04_23_080231_create_products_table.php --force 2>/dev/null || echo "Products migration failed"
    php artisan migrate --path=database/migrations/2025_04_24_094552_create_orders_table.php --force 2>/dev/null || echo "Orders migration failed"
    php artisan migrate --path=database/migrations/2025_05_13_070221_create_cities_table.php --force 2>/dev/null || echo "Cities migration failed"
}

# Check if critical tables exist
echo "=== Checking critical tables ==="
php artisan tinker --execute="
try {
    \App\Models\Warehouse::count();
    echo 'Warehouses table: OK' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Warehouses table: MISSING - ' . \$e->getMessage() . PHP_EOL;
}

try {
    \App\Models\Role::count();
    echo 'Roles table: OK' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Roles table: MISSING - ' . \$e->getMessage() . PHP_EOL;
}

try {
    \App\Models\User::count();
    echo 'Users table: OK' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Users table: MISSING - ' . \$e->getMessage() . PHP_EOL;
}
" 2>/dev/null || echo "Table check failed"

# Run seeders with better error handling
echo "=== Running database seeders ==="
php artisan db:seed --force 2>/dev/null || {
    echo "Seeders failed, trying individual seeders..."
    php artisan db:seed --class=RolesTableSeeder --force 2>/dev/null || echo "Role seeder failed or already run"
    php artisan db:seed --class=WarehouseSeeder --force 2>/dev/null || echo "Warehouse seeder failed or already run"
}

# Cache configuration
echo "=== Caching configuration ==="
php artisan config:cache 2>/dev/null || echo "Config caching failed"

# Create storage link
echo "=== Creating storage link ==="
php artisan storage:link 2>/dev/null || echo "Storage link already exists"

# Set permissions
echo "=== Setting permissions ==="
chmod -R 775 storage bootstrap/cache 2>/dev/null || echo "Permission setting failed"

echo "=== Deployment setup completed! ===" 