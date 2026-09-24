#!/usr/bin/env python3
# @raycast.schemaVersion 1
# @raycast.title Capture Geopetto Task
# @raycast.mode compact
# @raycast.packageName Geopetto
# @raycast.argument1 {"type": "text", "placeholder": "Task title"}
# @raycast.description Capture a Mack task in Inbox, then triage it in Geopetto.
"""Reuse the installed agent client's auth, durable retry keys and HTTP transport."""
import importlib.util
import os
from pathlib import Path
import sys


def capture(title):
    title = title.strip()
    if not title or len(title) > 255:
        raise ValueError('Enter a task title of 1–255 characters')
    cli = Path(os.environ.get('GEOPETTO_AGENT_CLI', str(Path.home() / '.codex/skills/geopetto/scripts/geopetto.py')))
    if not cli.is_file():
        raise ValueError('Install the Geopetto agent CLI, or set GEOPETTO_AGENT_CLI')
    spec = importlib.util.spec_from_file_location('geopetto_agent', cli)
    agent = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(agent)
    body = {'title': title, 'metadata': {'capture_source': 'raycast'}}
    result = agent.safe_create(agent.Client(), '/tasks', body, body)
    return result['task']


if __name__ == '__main__':
    try:
        if len(sys.argv) != 2:
            raise ValueError('Usage: capture-geopetto.py "Task title"')
        task = capture(sys.argv[1])
        print(f"Saved to Inbox: {task['title']}")
    except Exception as error:
        print(f'Capture failed: {error}. Retry the same title after fixing the error.')
        sys.exit(1)
