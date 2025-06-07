#!/bin/bash

echo "=== Laravel Application Health Check ==="

# Check if we're in the right directory
echo "Current directory: $(pwd)"
echo "App directory contents:"
ls -la /app/ | head -10

# Check PHP version
echo "PHP version: $(php --version | head -1)"

# Check if Laravel is working
echo "=== Laravel Status ==="
if php artisan --version 2>/dev/null; then
    echo "Laravel is accessible"
else
    echo "Laravel is NOT accessible"
fi

# Check environment
echo "=== Environment Variables ==="
echo "APP_ENV: ${APP_ENV:-not set}"
echo "APP_KEY: ${APP_KEY:+set}"
echo "DB_CONNECTION: ${DB_CONNECTION:-not set}"
echo "DB_HOST: ${DB_HOST:-not set}"
echo "DB_DATABASE: ${DB_DATABASE:-not set}"

# Check database connection
echo "=== Database Connection ==="
if php artisan migrate:status 2>/dev/null; then
    echo "Database connection: OK"
else
    echo "Database connection: FAILED"
fi

# Check file permissions
echo "=== File Permissions ==="
echo "Storage directory:"
ls -la storage/ | head -5
echo "Bootstrap cache:"
ls -la bootstrap/cache/ | head -5

echo "=== Health Check Complete ===" 