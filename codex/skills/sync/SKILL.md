---
name: sync
category: "Dev Tools & Internal Systems"
role: workflow
description: Sync local work with remote using rebase and push. Use for /sync to sync the current repo or /sync -global to sync a configured list of repos. Auto-commits pending work and resolves evidence-backed conflicts; "sync without committing" (formerly /ship) preserves uncommitted work.
user-invocable: true
disable-model-invocation: true
---

# Sync

Complete routine conflict resolution autonomously under the decision policy below. Optimize for preserving intended work and behavior, then completing the sync. A clean Git status is not success if a resolution silently loses work. Investigate answerable concerns before involving the user; do not infer permission to discard work from a request to sync.

## Scope

- `/sync` runs the workflow below only for the Git repository containing the current working directory.
- `/sync -global` runs the same workflow once for each repository in [assets/global-repos.txt](assets/global-repos.txt). It works from any current directory. Do not discover or add repositories automatically.
- `/sync without committing` and `/sync -global without committing` use the corresponding scope with the **Sync without committing** procedure below.

For global mode, read the list before any mutation. Ignore blank lines and comments, expand `~/` using the current user's home directory, and deduplicate canonical repository roots. Reject an entry if it is missing, is not a Git repository, or resolves to a different repository root. Never treat a parent directory as an instruction to sync every repository below it. If the list is missing or empty, ask the user which repositories to include instead of guessing.

Preflight every listed repository: read its applicable repository instructions and release gates, then inspect its branch, upstream, worktree status, and any Git operation in progress. Tell the user which repositories are in scope and flag any that need attention. Run the normal single-repository workflow sequentially for each valid entry, including its recovery and verification steps. If any repository fails or needs a decision, credentials, or release approval, preserve its state, record the failure, and continue with the remaining independent repositories. Do not push a protected or production branch before its required approval. Do not change the global list as part of a sync run.

If any repository failed or was skipped, lead the final response with **⚠️ SYNC GLOBAL INCOMPLETE**, the number of affected repositories, and their names. For each one, state plainly what failed, what was left unsynced, and the next action. In voice mode, say the failures aloud before summarizing successes. Do not bury failures in a success list or say the global sync succeeded. Then give one per-repository summary: synced and verified, already matched, or needs attention. Claim that all repositories are synced only when every listed repository's local and upstream refs match and no operation remains in progress.

## Decision policy

Use the user's stated preferences as decision criteria, not a claim that you can predict their unstated intent:

1. **Follow explicit intent.** Apply the user's relevant instructions and established repository contracts. A later explicit correction supersedes an earlier instruction only within its stated scope. Commit messages are supporting evidence, not proof that another change is obsolete.
2. **Preserve compatible contributions.** Resolve at the hunk or behavior level, keeping meaningful changes from both sides. Preserve independent work regardless of author or whether it is local or remote. Avoid rewriting, cleanup, or unrelated improvements during sync.
3. **Require evidence for replacement.** Omit a change only when it is demonstrably duplicated, explicitly superseded, intentionally retired, or reproducible transient output covered by a verified replacement. Neither recency, shorter code, passing tests, nor a backup alone justifies dropping it. Do not bulk-select ours/theirs or use a global conflict strategy to make conflicts disappear.
4. **Check preservation, not just validity.** For each conflicting file, identify what each side changed relative to the base and account for each meaningful change in the result. Any omitted behavior or content needs a concrete reason and source. Use focused checks where helpful; tests passing does not prove all intended work survived.
5. **Escalate only the irreducible choice.** If both intents cannot coexist and no authoritative evidence settles precedence, ask one specific question with a recommendation. Do not concatenate contradictory settings or instructions merely to retain every line. Resolve independent conflicts first, preserve recoverable state, and hold the push until the unresolved choice is settled.

For example, two new log entries should both survive; a documented rename should receive compatible edits at its new path; conflicting client preferences need an explicit correction or user decision; a newer generated snapshot needs verified scope and completion, not just a later date.

## Workflow

1. Inspect `git status`, current branch, upstream, and any operation already in progress before staging or pulling. Confirm the intended repository and remote. Resume an existing rebase using the conflict procedure below; do not start another pull or commit conflict markers. If a merge or cherry-pick is already in progress, inspect its purpose and finish it only when clearly part of the authorized work.
2. Preserve recoverability: record the original branch/HEAD and create a local backup ref before rebasing. For an already paused operation, preserve both the current HEAD and the verified original tip from its operation metadata. Do not reset, abort, discard, or skip meaningful changes to get a clean status.
3. In normal mode, inspect pending changes, then auto-commit staged, unstaged, and untracked work with `git add -A` and a short descriptive commit message. Do not ask whether to commit or stash. Inspect filenames and diffs without exposing credentials; never newly stage known secrets or temporary recovery files. After resuming an operation, commit any remaining pending work separately instead of folding it into the replayed commit.
4. Preserve the resulting committed tip in a local backup ref as well, so the backup includes any auto-committed work. Run `git pull --rebase` against the configured upstream. Resolve conflicts below, validate, and continue until the operation completes.
5. Run a normal `git push`. If rejected because the remote advanced, fetch/rebase again, resolve and validate, then retry. Limit this to three retry cycles; repeated concurrent movement, authentication failures, or branch protection require a precise blocker report, not an endless loop. Never force-push or bypass hooks/protection.
6. Verify no operation or unmerged paths remain, inspect working-tree status, fetch the upstream, and compare local/upstream commit IDs. Report the pushed commit, material conflict decisions (including anything omitted and why), recovery ref names when conflicts were resolved, and any remaining local changes or remote movement. Claim fully synced only when the refs match.

## Resolve conflicts by meaning

Read the conflicting hunks, base and both sides, the replayed commit's intent, and relevant nearby docs or producer code. Use `git ls-files -u` and `git show :1:path`, `:2:path`, `:3:path` where those stages exist. During rebase, stage 2 / ours is the upstream plus already replayed commits; stage 3 / theirs is the local commit being replayed. Never choose a whole side by label alone.

Apply the smallest resolution that preserves intended work:

- **Independent edits or append-only logs:** retain both distinct additions, preserve chronology and structure, deduplicate only genuinely identical entries.
- **Code, config, and instructions:** combine compatible changes. When one side supersedes the other, use explicit user direction, commit intent, authoritative docs, and callers to establish which behavior is intended. Run relevant focused checks. A newer timestamp alone does not establish authority.
- **Generated snapshots and caches:** inspect their producer and ownership contract. Prefer a coherent, valid snapshot from a demonstrably later successful run when it supersedes the same scope. Preserve coupled files together; do not union arrays or take maximum timestamps blindly. Regenerate only when the generator is safe and does not send messages, advance workflow state, or perform unrelated external actions.
- **Cursors, checkpoints, and processing state:** distinguish fetched from successfully processed data. Advance only with evidence supporting the corresponding completed work; do not invent progress. A conservative earlier cursor is acceptable only when replay is verified idempotent and cannot repeat external actions.
- **Delete/modify conflicts:** establish whether deletion intentionally retired the file or whether its content moved. Preserve meaningful edits in the active replacement when supported by evidence; do not automatically resurrect or delete.

### Finish each resolution

Validate syntax/schema and relevant invariants, review the resulting diff for lost intent or conflict markers, and stage only resolved paths with `git add -- <paths>`. Preserve unrelated files and already staged changes; never use `git add -A` during an unresolved operation. Continue with `GIT_EDITOR=true git rebase --continue` (or the command matching the existing operation). Repeat for subsequent conflicts. Skip an empty replay only after proving its intended changes are already present.

## Sync without committing

Preserve all uncommitted work and the staged/unstaged distinction. If a clean tree is required, create an identifiable stash including untracked files, record its exact object ID, then rebase/push only existing commits. Restore that stash with `git stash apply --index` and remove only that exact stash after verifying restoration. Resolve any restoration conflicts using the same evidence-based procedure without committing the restored work. If restoration cannot be completed confidently, retain the stash and report its ID and remaining paths. Never overwrite or drop pre-existing stashes. Do not try to stash unmerged paths; resolve the existing operation first while keeping unrelated pending work separate.

## When user input is actually needed

Exhaust local evidence first. Ask for a concrete unresolved decision only when both sides encode incompatible business intent, meaningful content would otherwise be lost, a state transition cannot be verified safely, or the target branch/remote cannot be established. Explain the affected paths, what each option preserves or loses, and your recommendation. Leave recoverable state and identify the exact continuation step. Do not ask the user to decide mechanical Git details or facts available in repository history.
