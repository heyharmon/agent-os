# Actions

| Action | Consequence |
|---|---|
| search / read code or brain | reversible |
| draft a patch (file or diff under runtime/drafts/) | reversible |
| triage an issue | reversible |
| file a decision via ./bin/brain | reversible |
| git commit | consequential -> escalate |
| git push | consequential -> escalate |
| git merge | consequential -> escalate |
| delete a branch or a tracked file | consequential -> escalate |
| force-push / tag | consequential -> escalate |
| deploy (./deploy.sh, any deploy) | consequential -> escalate |

Reversible work: do it directly. Consequential work: escalate by writing a file
to `runtime/queue/approvals/`. Never run git or a deploy command yourself.
