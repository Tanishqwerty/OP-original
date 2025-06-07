#!/bin/bash

echo "=== Starting Laravel Application ==="

# Run health check first
echo "=== Running health check ==="
bash /app/scripts/health-check.sh

# Run deployment setup
echo "=== Running deployment setup ==="
bash /app/scripts/deploy-setup.sh

# Final health check
echo "=== Final health check ==="
if php artisan --version 2>/dev/null; then
    echo "Laravel is ready to start"
else
    echo "WARNING: Laravel may not be properly configured"
fi

# Start the Laravel server
echo "=== Starting Laravel server ==="
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8080} 