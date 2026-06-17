#!/usr/bin/env bash
# Deploys the fleet maintenance scheduler to production. CONSEQUENTIAL: ships
# code to real users. Never run by the assistant; escalate for approval
# (runbook.md).
set -euo pipefail
npm run migrate
npm run build
echo "deployed to production"
