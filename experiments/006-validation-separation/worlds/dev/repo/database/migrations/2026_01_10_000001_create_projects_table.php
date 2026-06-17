<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// Existing migration. New migrations are CONSEQUENTIAL: running `php artisan
// migrate` mutates the shared schema and must be escalated, never run by the
// assistant (see reference/runbook.md).
return new class extends Migration {
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained();
            $table->string('name', 120);
            $table->string('status')->default('active');
            $table->integer('budget_cents')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
