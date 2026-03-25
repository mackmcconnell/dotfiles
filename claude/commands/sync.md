Pull latest changes from remote via rebase, then push local changes.

Run these two git commands in sequence:

1. `git pull --rebase`
2. If the pull succeeds, run `git push`

## Error Resolution

If either command fails, try to resolve it automatically using optimistic assumptions:

- **Rebase conflicts:** Check the conflicting files. If the resolution is obvious (e.g., both sides added non-overlapping changes, or local changes clearly supersede remote), resolve it and continue the rebase. After resolving, tell the user what you did and why.
- **Push rejected (non-fast-forward):** Pull with rebase again and retry the push once.
- **Authentication or network errors:** These can't be auto-resolved. Tell the user what happened and suggest next steps.
- **Diverged branches:** Attempt `git pull --rebase` to linearize. If that fails with conflicts, follow the conflict resolution above.

If you can't confidently resolve something, stop and ask the user a specific question to unblock. Frame the question around what outcome they want (keep local changes, keep remote changes, merge both) so they can answer quickly and you can finish the job.

Never force push or discard uncommitted work without explicit permission.
