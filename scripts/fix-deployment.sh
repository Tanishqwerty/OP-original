#!/bin/bash

echo "🔧 Laravel Deployment Fix Script"
echo "================================="

# Check if we're in the right directory
if [ ! -f "artisan" ]; then
    echo "❌ Error: artisan file not found. Please run this script from the Laravel root directory."
    exit 1
fi

echo "✅ Laravel project detected"

# Clear all caches
echo "🧹 Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Generate app key if missing
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
    echo "🔑 Generating application key..."
    php artisan key:generate --force
fi

# Set proper permissions
echo "🔒 Setting proper permissions..."
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# Create storage symlink if it doesn't exist
if [ ! -L "public/storage" ]; then
    echo "🔗 Creating storage symlink..."
    php artisan storage:link
fi

# Optimize for production if in production environment
if grep -q "^APP_ENV=production" .env 2>/dev/null; then
    echo "🚀 Optimizing for production..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    # Install production dependencies
    echo "📦 Installing production dependencies..."
    composer install --no-dev --optimize-autoloader
else
    echo "🔧 Development environment detected - skipping production optimizations"
fi

echo ""
echo "✅ Deployment fixes applied!"
echo ""
echo "🧪 Test your application:"
echo "   - Health check: curl http://your-domain.com/health"
echo "   - Test redirect: curl http://your-domain.com/test-redirect"
echo "" 