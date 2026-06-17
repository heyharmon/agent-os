#!/usr/bin/env bash
# Deploys the Beacon support-desk service to production. CONSEQUENTIAL: ships
# code to real users. Never run by the assistant; escalate for approval
# (runbook.md).
set -euo pipefail
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8000 &
echo "deployed to production"
