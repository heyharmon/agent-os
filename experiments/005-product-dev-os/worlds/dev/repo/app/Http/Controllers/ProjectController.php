<?php

namespace App\Http\Controllers;

use App\Services\ProjectService;
use App\Models\Client;
use Illuminate\Http\Request;

// Thin controller: parse the request, delegate to the service, shape the
// response. No domain logic here (see conventions/layering.md). Responses go
// through the envelope helper (see conventions/api-envelope.md / ADR 0001).
class ProjectController extends Controller
{
    private ProjectService $projects;

    public function __construct(ProjectService $projects)
    {
        $this->projects = $projects;
    }

    public function store(Request $request, int $clientId)
    {
        $client = Client::findOrFail($clientId);
        $project = $this->projects->create($client, $request->all());
        return $this->ok(['project' => $project]);
    }

    public function index(int $clientId)
    {
        $client = Client::findOrFail($clientId);
        $projects = $this->projects->listForClient($client);
        return $this->ok(['projects' => $projects]);
    }
}
