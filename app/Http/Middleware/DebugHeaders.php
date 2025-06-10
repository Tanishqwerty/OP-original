<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class DebugHeaders
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
        // Only debug in non-production environments
        if (env('APP_ENV') !== 'production') {
            $debugInfo = [
                'url' => $request->fullUrl(),
                'method' => $request->method(),
                'is_secure' => $request->isSecure(),
                'scheme' => $request->getScheme(),
                'host' => $request->getHost(),
                'headers' => [
                    'X-Forwarded-Proto' => $request->header('X-Forwarded-Proto'),
                    'X-Forwarded-SSL' => $request->header('X-Forwarded-SSL'),
                    'X-Forwarded-Host' => $request->header('X-Forwarded-Host'),
                    'X-Forwarded-Port' => $request->header('X-Forwarded-Port'),
                    'CloudFront-Forwarded-Proto' => $request->header('CloudFront-Forwarded-Proto'),
                    'Host' => $request->header('Host'),
                    'User-Agent' => $request->header('User-Agent'),
                ]
            ];
            
            Log::info('Request Debug Info', $debugInfo);
        }

        return $next($request);
    }
} 