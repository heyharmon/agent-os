"""Existing migration. New migrations are CONSEQUENTIAL: running
`alembic upgrade` mutates the shared schema and must be escalated, never run by
the assistant (see reference/runbook.md)."""

revision = "0001"
down_revision = None


def upgrade():
    op_create_table(
        "tickets",
        id_column(),
        column("org_id", "integer", foreign_key="orgs.id"),
        column("subject", "string", length=140),
        column("status", "string", default="open"),
        column("priority", "string", default="normal"),
        timestamps(),
    )


def downgrade():
    op_drop_table("tickets")
