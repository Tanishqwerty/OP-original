<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
  ->withRouting(
    web: __DIR__.'/../routes/web.php',
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
  )
  ->withMiddleware(function (Middleware $middleware) {
    // Trust all proxies - important for load balancers/CDNs
    $middleware->trustProxies(at: '*');
    
    // Add debug middleware first (only in non-production)
    // Remove this after fixing the redirect issue
    if (env('APP_ENV') !== 'production') {
      $middleware->web(prepend: [
        \App\Http\Middleware\DebugHeaders::class,
      ]);
    }
    
    // Add SecureRedirect middleware to web group
    // This handles HTTPS enforcement with proper proxy detection
    $middleware->web(append: [
      \App\Http\Middleware\SecureRedirect::class,
    ]);
  })
  ->withExceptions(function (Exceptions $exceptions) {
    //
  })->create();
