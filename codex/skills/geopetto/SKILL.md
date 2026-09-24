---
name: geopetto
description: Manage Mack's Geostar work tasks and Geopetto projects from Aigency, including project context, membership, task creation, updates, completion, and history. Use for Mack task or Geopetto project work; other assignees remain in GeoStar.
---

# Geopetto

Use the colocated `scripts/geopetto.py` with Python 3.11 or newer. It uses only the standard library and returns JSON. In Codex, run it at `~/.codex/skills/geopetto/scripts/geopetto.py`; in Claude, use `~/.claude/skills/geopetto/scripts/geopetto.py`. Run `--help`, `tasks --help`, or `projects --help` when you need command syntax.

Geopetto SQLite owns all `@mack` tasks and Geopetto local projects. GeoStar clients are separate numeric `client_id` buckets. Other assignees still use Aigency's `./geo-cli tasks`. Never read or write stale Mack copies in GeoStar or fall back to them if Geopetto is unavailable.

For project work, start with `projects get ID`: it returns the Markdown context and every member task, including completed and cancelled tasks. Use stable project and task IDs in automation. Create tasks with `tasks create TITLE --client-id N --project ID` for atomic creation and membership. Use `tasks move ID --project ID` or `--project none` to change membership. Use `projects update ID --context-file FILE` to replace context with established durable objectives, background, constraints, decisions, and links; keep task instructions, progress, next actions, and blockers in tasks. Repository files hold supporting research and deliverables, not a second task tracker.

The script reads revisions before writes. On a `conflict`, read the latest task or project and reconcile before changing it again. It persists task and project creation idempotency keys under `~/.local/state/geopetto-agent/`; rerun the same create command after an uncertain response. For other uncertain writes, inspect the returned `readback` or fetch the resource before deciding whether to repeat the operation. Do not blindly retry a mutation. Never print credentials or bulk task exports into logs.

The script defaults to the hosted Geopetto URL. It reads `GEOPETTO_URL`, `GEOPETTO_BASIC_AUTH_USER`, and `GEOPETTO_BASIC_AUTH_PASSWORD` from the environment, falling back to those keys in the private `~/code/aigency/.env` file. `GEOPETTO_ENV_FILE` can select another local file. Keep credentials outside this synced skill and dotfiles. If authentication is unavailable, report the missing configuration; do not embed credentials in commands or fall back to another task store.

Examples:

```bash
~/.codex/skills/geopetto/scripts/geopetto.py clients --all
~/.codex/skills/geopetto/scripts/geopetto.py projects list
~/.codex/skills/geopetto/scripts/geopetto.py projects get local-project-ID
~/.codex/skills/geopetto/scripts/geopetto.py tasks list --status open --project local-project-ID
~/.codex/skills/geopetto/scripts/geopetto.py tasks list --status completed --limit 50 --offset 50
~/.codex/skills/geopetto/scripts/geopetto.py tasks complete tsk_ID
```
