<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// A client has many projects. Data only.
class Client extends Model
{
    protected $fillable = ['name', 'email'];

    public function projects()
    {
        return $this->hasMany(Project::class);
    }
}
