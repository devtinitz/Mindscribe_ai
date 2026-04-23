<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Meeting extends Model
{
    protected $fillable = [
        'user_id', 'title', 'audio_path',
        'transcription', 'summary', 'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function decisions()
    {
        return $this->hasMany(Decision::class);
    }

    public function tasks()
    {
        return $this->hasMany(Task::class);
    }
}