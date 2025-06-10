#!/bin/bash

echo "🔧 Fixing Authentication Redirect Loop..."

# Clear all caches
echo "📦 Clearing caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Clear sessions
echo "🗑️ Clearing sessions..."
php artisan session:flush 2>/dev/null || echo "Session flush not available"

# Optimize for production
echo "⚡ Optimizing..."
php artisan config:cache
php artisan route:cache

echo "✅ Authentication fixes applied!"
echo ""
echo "🧪 Test URLs:"
echo "- Admin Login: https://orderprocessing.divinecareindustries.com/adminlogin"
echo "- Test Auth: https://orderprocessing.divinecareindustries.com/test-auth"
echo "- Test Logout: https://orderprocessing.divinecareindustries.com/test-logout"
echo ""
echo "📋 Testing Steps:"
echo "1. Visit /test-logout to ensure clean state"
echo "2. Visit /adminlogin and try logging in"
echo "3. Check /test-auth to verify authentication state"
echo "4. Check logs: tail -f storage/logs/laravel.log" 