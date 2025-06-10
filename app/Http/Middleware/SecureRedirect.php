<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;

class SecureRedirect
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
        // Only enforce HTTPS in production
        if (env('APP_ENV') !== 'production') {
            return $next($request);
        }

        // Force HTTPS scheme for URL generation
        URL::forceScheme('https');

        // Check if request is already secure through various methods
        $isSecure = $this->isRequestSecure($request);

        // Only redirect if we're definitely not secure and not in a redirect loop
        if (!$isSecure && !$this->isRedirectLoop($request)) {
            return redirect()->secure($request->getRequestUri(), 301);
        }

        return $next($request);
    }

    /**
     * Determine if the request is secure
     */
    private function isRequestSecure(Request $request): bool
    {
        // Check Laravel's built-in secure detection
        if ($request->isSecure()) {
            return true;
        }

        // Check common proxy headers
        $forwardedProto = $request->header('X-Forwarded-Proto');
        if ($forwardedProto === 'https') {
            return true;
        }

        // Check for SSL headers
        if ($request->header('X-Forwarded-SSL') === 'on') {
            return true;
        }

        // Check CloudFront
        if ($request->header('CloudFront-Forwarded-Proto') === 'https') {
            return true;
        }

        // Check if we're on standard HTTPS port
        if ($request->getPort() == 443) {
            return true;
        }

        return false;
    }

    /**
     * Check if we might be in a redirect loop
     */
    private function isRedirectLoop(Request $request): bool
    {
        // If we have X-Forwarded-Proto header, we're likely behind a proxy
        // and should trust it rather than redirect
        if ($request->hasHeader('X-Forwarded-Proto')) {
            return true;
        }

        // Check for common load balancer headers
        if ($request->hasHeader('X-Forwarded-For') || 
            $request->hasHeader('X-Real-IP') ||
            $request->hasHeader('CF-Ray')) {
            return true;
        }

        return false;
    }
} 