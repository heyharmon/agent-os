<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProjectController;

// Routes for the client-project tracker. Auth is handled by the framework's
// session middleware (see conventions/auth.md). Every route is owner-scoped:
// a user only sees clients/projects they own.
Route::middleware(['auth'])->group(function () {
    Route::get('/clients/{clientId}/projects', [ProjectController::class, 'index']);
    Route::post('/clients/{clientId}/projects', [ProjectController::class, 'store']);
});
