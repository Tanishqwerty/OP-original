<?php

namespace App\Http\Controllers\authentications;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminLogin extends Controller
{
  public function index()
  {
    return view('content.authentications.auth-admin-login');
  }

  public function login(Request $request)
    {
        // Debug logging
        \Log::info('AdminLogin::login called', [
            'email' => $request->email,
            'url' => $request->url(),
            'session_id' => session()->getId(),
            'authenticated_before' => Auth::check()
        ]);
        
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user_exist = User::where('email', $request->email)->first();

        if(!$user_exist){
            \Log::info('AdminLogin: User not found', ['email' => $request->email]);
            return redirect()->back()->with('error', 'The provided credentials do not match our records.');
        }

        if(!$user_exist->is_active){
            \Log::info('AdminLogin: User inactive', ['email' => $request->email]);
            return redirect()->back()->with('error', 'User is deactivated');
        }

        // Check role BEFORE attempting authentication to avoid logout issues
        $role = $user_exist->role->name ?? null;
        
        \Log::info('AdminLogin: User role check', [
            'email' => $request->email,
            'role' => $role,
            'role_id' => $user_exist->role_id
        ]);
        
        if ($role !== 'admin') {
            \Log::info('AdminLogin: Non-admin user attempted login', ['email' => $request->email, 'role' => $role]);
            return redirect()->back()->with('error', 'Unauthorized role. Admin access required.');
        }

        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
             $request->session()->regenerate();
             
             \Log::info('AdminLogin: Authentication successful', [
                 'email' => $request->email,
                 'session_id' => session()->getId()
             ]);

             $user = Auth::user(); 
             
             // Double-check role after authentication (security measure)
             if ($user->role->name === 'admin') {
                 \Log::info('AdminLogin: Redirecting to dashboard', ['email' => $request->email]);
                 return redirect()->intended('dashboard');
             } else {
                 // Properly logout with session invalidation
                 \Log::warning('AdminLogin: Role mismatch after auth, logging out', [
                     'email' => $request->email,
                     'role' => $user->role->name
                 ]);
                 
                 Auth::logout();
                 $request->session()->invalidate();
                 $request->session()->regenerateToken();
                 
                 return redirect()->route('adminlogin')->with('error', 'Unauthorized role');
             }
        }
        
        \Log::info('AdminLogin: Authentication failed', ['email' => $request->email]);
        return redirect()->back()->with('error', 'Invalid credentials. Please check your email and password.');
    }

    public function show(Request  $request){
        $user = Auth::user();

        if (!$user) {
            return redirect()->route('adminlogin')->with('error', 'Please log in first.');
        }
        
        // Check if user has admin role
        if ($user->role->name !== 'admin') {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();
            return redirect()->route('adminlogin')->with('error', 'Admin access required.');
        }
    
        return view('dashboard', compact('user'));
    }
}
