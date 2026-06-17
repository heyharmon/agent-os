<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// A project belongs to a client and has many invoices. Models are data only:
// relationships and casts, no business rules (those live in services).
class Project extends Model
{
    protected $fillable = ['client_id', 'name', 'status', 'budget_cents'];

    protected $casts = [
        'budget_cents' => 'integer',
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }
}
