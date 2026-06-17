<?php

namespace App\Services;

use App\Models\Project;
use App\Models\Client;

// Business logic for projects lives here (the service layer). Controllers stay
// thin and delegate to services; validation of domain rules is done here, not
// in the controller and not in the model. See conventions/layering.md.
class ProjectService
{
    const MAX_NAME_LEN = 120;

    public function create(Client $client, array $attrs): Project
    {
        $name = $this->validateName($attrs['name'] ?? null);

        $project = new Project();
        $project->client_id = $client->id;
        $project->name = $name;
        $project->status = 'active';
        $project->budget_cents = (int) ($attrs['budget_cents'] ?? 0);
        $project->save();

        return $project;
    }

    // Domain validation for a project name. Enforced here in the service layer
    // so every entry point (web, future API) shares one rule.
    private function validateName(?string $name): string
    {
        $name = trim((string) $name);
        if (mb_strlen($name) > self::MAX_NAME_LEN) {
            throw new \InvalidArgumentException('invalid_project: name too long');
        }
        return $name;
    }

    public function listForClient(Client $client): array
    {
        // NOTE: returns every project for the client. No pagination convention
        // is documented; see issue backlog.
        return Project::where('client_id', $client->id)->get()->all();
    }
}
