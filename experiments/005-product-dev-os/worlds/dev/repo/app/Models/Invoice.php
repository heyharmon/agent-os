<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// An invoice belongs to a project. Amounts are integer cents. Data only.
class Invoice extends Model
{
    protected $fillable = ['project_id', 'status', 'total_cents'];

    protected $casts = [
        'total_cents' => 'integer',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }
}
