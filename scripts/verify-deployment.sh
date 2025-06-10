#!/bin/bash

echo "🔍 Laravel Deployment Verification Script"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "artisan" ]; then
    echo "❌ Error: artisan file not found. Please run this script from the Laravel root directory."
    exit 1
fi

echo "✅ Laravel project detected"

# Check environment file
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found"
    exit 1
fi

echo "✅ .env file exists"

# Check key environment variables
echo "🔧 Checking environment variables..."

APP_KEY=$(grep "^APP_KEY=" .env | cut -d '=' -f2)
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
    echo "❌ APP_KEY is not set or invalid"
    echo "   Run: php artisan key:generate"
else
    echo "✅ APP_KEY is set"
fi

APP_ENV=$(grep "^APP_ENV=" .env | cut -d '=' -f2)
echo "📍 APP_ENV: $APP_ENV"

APP_DEBUG=$(grep "^APP_DEBUG=" .env | cut -d '=' -f2)
echo "📍 APP_DEBUG: $APP_DEBUG"

# Check if composer dependencies are installed
if [ ! -d "vendor" ]; then
    echo "❌ Error: vendor directory not found"
    echo "   Run: composer install --no-dev --optimize-autoloader"
    exit 1
fi

echo "✅ Composer dependencies installed"

# Check if storage is writable
if [ ! -w "storage" ]; then
    echo "❌ Error: storage directory is not writable"
    echo "   Run: chmod -R 775 storage bootstrap/cache"
else
    echo "✅ Storage directory is writable"
fi

# Check if bootstrap/cache is writable
if [ ! -w "bootstrap/cache" ]; then
    echo "❌ Error: bootstrap/cache directory is not writable"
    echo "   Run: chmod -R 775 bootstrap/cache"
else
    echo "✅ Bootstrap cache directory is writable"
fi

echo ""
echo "🚀 Deployment verification complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Clear caches: php artisan config:clear && php artisan cache:clear"
echo "   2. Optimize for production: php artisan config:cache && php artisan route:cache"
echo "   3. Test the application: curl -I http://your-domain.com/health"
echo "" 