---
name: workflow-audit
description: "Audit recent Claude Code sessions to find repeated workflows, recurring patterns, and opportunities for automation. Use when users want to identify what they've been doing repeatedly, find workflow patterns, or discover candidates for new skills or scheduled tasks."
user-invocable: true
argument-hint: "workflow-audit, audit my sessions, what have I been doing"
allowed-tools: Bash, Read, Glob, Grep, Write, Agent
---

# Workflow Audit

Analyze the user's recent Claude Code sessions to identify repeated workflows, recurring instruction patterns, and automation opportunities.

## Execution Steps

### Step 1: Detect transcript access mode

Try both methods and use whichever works:

**Primary (MCP tools)**: Check if `mcp__session_info__list_sessions` and `mcp__session_info__read_transcript` are available. If so, use them.

**Fallback (JSONL files)**: Read transcripts directly from the filesystem. This is the default in regular Claude Code sessions.

### Step 2: Collect sessions from the last 30 days

**JSONL fallback method:**

Session metadata lives in `~/.claude/sessions/*.json`. Each file contains:
```json
{"pid": 12345, "sessionId": "uuid", "cwd": "/path/to/project", "startedAt": 1775670226694}
```

Transcripts live in `~/.claude/projects/<project-dir>/<sessionId>.jsonl`. Each line is a JSON event.

To collect sessions from the last 30 days:

1. Read all `~/.claude/sessions/*.json` files
2. Filter to those where `startedAt` is within the last 30 days (timestamp is epoch milliseconds)
3. For each session, derive the project directory from `cwd` by converting the path: replace `/` with `-` and strip the leading `-` to get the directory name under `~/.claude/projects/`
4. Match `sessionId` to the corresponding `.jsonl` file in that project directory

Use a bash script to efficiently collect and filter this data rather than reading files one by one.

### Step 3: Parse transcripts

For each session's JSONL file, extract the meaningful events:

- **User messages**: Lines where `"type": "user"` - look at `message.content` for what the user asked
- **Tool calls**: Lines where `"type": "assistant"` and message content includes `tool_use` blocks - these show what actions were taken
- **Timestamps**: The `timestamp` field on each event
- **Session context**: The `cwd` from the session metadata tells you which project this was in

Focus on extracting a summary of each session: what the user asked for and what tools/actions were used to accomplish it. You don't need every line - focus on user messages and the general shape of the work.

**Important**: Transcripts can be large. Use efficient parsing:
```bash
# Extract user messages from a JSONL file
grep '"type":"user"' file.jsonl | python3 -c "
import sys, json
for line in sys.stdin:
    try:
        evt = json.loads(line)
        msg = evt.get('message', {}).get('content', '')
        if isinstance(msg, str) and msg.strip():
            print(msg[:500])
    except: pass
"
```

Use the Agent tool to parallelize reading across multiple sessions when there are many.

### Step 4: Analyze for patterns

Look across all sessions for:

1. **Repeated tasks**: Same type of work done in multiple sessions (e.g., "rip a YouTube song", "create a LinkedIn post", "debug deployment")
2. **Repeated instruction patterns**: Similar directions given across sessions (e.g., always telling Claude to use a specific format, always correcting the same behavior)
3. **Repeated tool sequences**: Similar chains of tool usage across sessions (e.g., always SSH then run a command, always read a file then edit it in the same way)
4. **Project-specific patterns**: Work that clusters around specific projects/directories
5. **Time patterns**: Work that happens at similar times or on similar schedules

### Step 5: Generate recommendations

For each identified pattern, classify the recommendation:

- **Skill candidate**: A multi-step workflow that could be triggered with a slash command. Include what the skill would do and suggest running `/skill-creator` to build it.
- **Scheduled task candidate**: Work that happens on a regular cadence and could be automated with a cron job or similar.
- **CLAUDE.md addition**: Instructions or preferences that get repeated and should be codified in project or user CLAUDE.md.
- **Memory candidate**: Context that keeps getting re-explained and should be saved to Claude's memory system.
- **Hook candidate**: A pre/post action that should happen automatically around certain tool calls.

### Step 6: Output the report

Format the output as a structured report:

```markdown
# Workflow Audit Report
**Period**: [date range]
**Sessions reviewed**: [count]
**Projects covered**: [list]

## Top Patterns (sorted by frequency and estimated time-cost)

### 1. [Pattern Name]
- **What**: [description of the repeated work]
- **Frequency**: [X times in Y days]
- **Sessions**: [list of session dates/projects where this occurred]
- **Time cost**: [estimated time spent on this pattern]
- **Recommendation**: [Skill / Scheduled Task / CLAUDE.md / Memory / Hook]
- **Next action**: [concrete step, e.g., "Run /skill-creator to build a /deploy-check skill"]

### 2. [Pattern Name]
...

## Repeated Instructions
[List of instructions/corrections given multiple times that should be codified]

## Proposed Improvements
[High-level suggestions for workflow optimization]
```

Sort patterns by a severity score combining frequency and estimated time-cost, so the highest-value automations surface first.

## Important Notes

- Be thorough but efficient - don't read every line of every transcript. Sample user messages to understand the shape of each session.
- When sessions are very large, focus on the first few user messages to understand the intent and the last few to understand the outcome.
- Group similar-but-not-identical tasks together (e.g., "rip Song A" and "rip Song B" are the same pattern).
- Include the project directory context so the user knows where each pattern lives.
- If MCP tools are available, prefer them over JSONL parsing as they provide cleaner data.
