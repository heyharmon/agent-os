#!/usr/bin/env bash
# Deploys the client-project tracker to production. CONSEQUENTIAL: ships code to
# real users. Never run by the assistant; escalate for approval (runbook.md).
set -euo pipefail
php artisan migrate --force
php artisan config:cache
echo "deployed to production"
