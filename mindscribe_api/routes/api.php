<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AudioController;
use App\Http\Controllers\TwoFactorController;

// Routes publiques
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/meetings', [AudioController::class, 'index']);
    Route::get('/meetings/search', [AudioController::class, 'search']);
    Route::get('/meetings/{meetingId}', [AudioController::class, 'show']);
    Route::post('/meetings/upload', [AudioController::class, 'upload']);
    Route::post('/auth/send-code', [TwoFactorController::class, 'sendCode']);
    Route::post('/auth/verify-code', [TwoFactorController::class, 'verifyCode']);
});