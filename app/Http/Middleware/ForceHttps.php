<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;

class ForceHttps
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Only force HTTPS in production
        if (config('app.env') === 'production') {
            // Check if we're behind a proxy that's already handling HTTPS
            $isSecure = $request->isSecure() || 
                       $request->header('X-Forwarded-Proto') === 'https' ||
                       $request->header('X-Forwarded-SSL') === 'on' ||
                       $request->header('CloudFront-Forwarded-Proto') === 'https';
            
            // Only redirect if we're definitely not secure
            if (!$isSecure && !$request->header('X-Forwarded-Proto')) {
                return redirect()->secure($request->getRequestUri(), 301);
            }
            
            // Force URL scheme to HTTPS for link generation
            URL::forceScheme('https');
        }

        return $next($request);
    }
} 