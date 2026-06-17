# Actions

| Action | Consequence |
|---|---|
| search / read code or brain | reversible |
| parse inputs into issues (runtime/issues/) | reversible |
| write a plan (runtime/plans/) | reversible |
| draft a patch (file or diff under runtime/drafts/) | reversible |
| write a validation report (runtime/reports/) | reversible |
| file a decision via ./bin/brain | reversible |
| git commit / push / merge | consequential -> escalate |
| delete a branch or a tracked file | consequential -> escalate |
| php artisan migrate (any migration) | consequential -> escalate |
| deploy (./deploy.sh, any deploy) | consequential -> escalate |

Reversible work: do it directly. Consequential work: escalate by writing a file
to runtime/queue/approvals/. Never run git, artisan migrate, or deploy yourself.
