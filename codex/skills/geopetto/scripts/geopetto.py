#!/usr/bin/env python3
"""Private Geopetto agent client. Python 3.11+; standard library only."""
from __future__ import annotations

import argparse
import base64
from contextlib import contextmanager
import fcntl
import hashlib
import json
import os
from pathlib import Path
import socket
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener
import uuid

DEFAULT_URL = 'https://geopetto.162.243.239.97.sslip.io'


class AgentError(Exception):
    def __init__(self, message: str, code: str = 'error', readback: object = None):
        super().__init__(message)
        self.code = code
        self.readback = readback


def emit(value: object) -> None:
    print(json.dumps(value, ensure_ascii=False, indent=2))


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, request, fp, code, msg, headers, newurl):
        return None


class Client:
    def __init__(self) -> None:
        origin = os.getenv('GEOPETTO_URL', DEFAULT_URL).rstrip('/')
        parts = urlsplit(origin)
        if parts.scheme not in ('http', 'https') or not parts.netloc or parts.username or parts.password or parts.path or parts.query or parts.fragment:
            raise AgentError('GEOPETTO_URL must be an HTTP(S) origin without credentials or a path', 'config')
        self.url = origin + '/api/v1'
        user = os.getenv('GEOPETTO_BASIC_AUTH_USER')
        password = os.getenv('GEOPETTO_BASIC_AUTH_PASSWORD')
        if (user is None) != (password is None):
            raise AgentError('Both Geopetto Basic Auth environment variables are required', 'auth_config')
        if user is not None and parts.scheme == 'http' and parts.hostname not in ('localhost', '127.0.0.1', '::1'):
            raise AgentError('Geopetto credentials require HTTPS outside localhost', 'auth_config')
        self.authorization = 'Basic ' + base64.b64encode(f'{user}:{password}'.encode()).decode() if user is not None else None
        try:
            self.timeout = float(os.getenv('GEOPETTO_AGENT_TIMEOUT', '20'))
            if not 0 < self.timeout <= 300:
                raise ValueError
        except ValueError as exc:
            raise AgentError('GEOPETTO_AGENT_TIMEOUT must be between 0 and 300 seconds', 'config') from exc
        self.opener = build_opener(NoRedirect())

    def _readback(self, method: str, path: str) -> object:
        if method == 'GET' or (method == 'POST' and path == '/tasks'):
            return None
        read_path = '/projects' if path == '/projects' or path.endswith('/project') else path
        try:
            return self.call('GET', read_path)
        except AgentError:
            return None

    def call(self, method: str, path: str, body: object = None, key: str = None, params: dict = None) -> object:
        url = self.url + path
        if params:
            url += '?' + urlencode(params)
        headers = {'Accept': 'application/json'}
        if self.authorization:
            headers['Authorization'] = self.authorization
        if key:
            headers['Idempotency-Key'] = key
        payload = None
        if body is not None:
            headers['Content-Type'] = 'application/json'
            payload = json.dumps(body, separators=(',', ':')).encode()
        request = Request(url, data=payload, headers=headers, method=method)
        try:
            with self.opener.open(request, timeout=self.timeout) as response:
                raw = response.read()
                status = response.status
        except HTTPError as exc:
            raw = exc.read()
            status = exc.code
        except (TimeoutError, socket.timeout) as exc:
            raise AgentError('Geopetto timed out; inspect readback before repeating this write', 'timeout', self._readback(method, path)) from exc
        except URLError as exc:
            if isinstance(exc.reason, (TimeoutError, socket.timeout)):
                raise AgentError('Geopetto timed out; inspect readback before repeating this write', 'timeout', self._readback(method, path)) from exc
            raise AgentError('Geopetto connection failed; Mack tasks have no GeoStar fallback', 'connection', self._readback(method, path)) from exc
        except OSError as exc:
            raise AgentError('Geopetto connection failed; Mack tasks have no GeoStar fallback', 'connection', self._readback(method, path)) from exc
        if status == 401:
            raise AgentError('Geopetto authentication failed', 'authentication')
        try:
            data = json.loads(raw)
        except (ValueError, UnicodeDecodeError) as exc:
            raise AgentError(f'Geopetto returned HTTP {status} without JSON', 'bad_response') from exc
        if status >= 400:
            if not isinstance(data, dict):
                raise AgentError(f'Geopetto returned HTTP {status}', 'http_error')
            raise AgentError(data.get('error', f'HTTP {status}'), data.get('code', 'http_error'))
        return data

    def revision(self, kind: str, ref: str = None) -> int:
        if kind == 'task':
            return self.call('GET', '/tasks/' + quote(ref, safe=''))['revision']
        return self.call('GET', '/projects')['revision']


def state_path() -> Path:
    base = Path(os.getenv('XDG_STATE_HOME', str(Path.home() / '.local/state')))
    return Path(os.getenv('GEOPETTO_AGENT_STATE', str(base / 'geopetto-agent/pending-creates.json')))


@contextmanager
def locked_state():
    target = state_path()
    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    lock = target.with_name(target.name + '.lock')
    fd = os.open(lock, os.O_CREAT | os.O_RDWR, 0o600)
    with os.fdopen(fd, 'r+') as handle:
        fcntl.flock(handle, fcntl.LOCK_EX)
        try:
            if target.exists():
                data = json.loads(target.read_text())
                if not isinstance(data, dict) or any(not isinstance(k, str) or not isinstance(v, str) for k, v in data.items()):
                    raise AgentError('Pending create state is invalid; preserve it for recovery', 'state_corrupt')
            else:
                data = {}
            yield data
        finally:
            fcntl.flock(handle, fcntl.LOCK_UN)


def save_state(data: dict) -> None:
    target = state_path()
    temp = target.with_name(target.name + '.' + str(uuid.uuid4()) + '.tmp')
    try:
        fd = os.open(temp, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
        with os.fdopen(fd, 'w') as handle:
            json.dump(data, handle)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp, target)
        directory = os.open(target.parent, os.O_RDONLY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
    finally:
        temp.unlink(missing_ok=True)


def safe_create(client: Client, path: str, body: dict, fingerprint_body: dict) -> object:
    fingerprint = hashlib.sha256((client.url + path + json.dumps(fingerprint_body, sort_keys=True)).encode()).hexdigest()
    with locked_state() as state:
        key = state.get(fingerprint)
        if key is None:
            key = str(uuid.uuid4())
            state[fingerprint] = key
            save_state(state)
        result = client.call('POST', path, body, key=key)
        del state[fingerprint]
        save_state(state)
        return result


def supplied(args: argparse.Namespace, names: tuple[str, ...]) -> dict:
    return {name: getattr(args, name) for name in names if getattr(args, name, None) is not None}


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(prog='geopetto', description='Geopetto task and project agent interface; JSON output')
    areas = root.add_subparsers(dest='area', required=True)
    clients = areas.add_parser('clients', help='List GeoStar client buckets')
    clients.add_argument('--all', action='store_true', help='Include clients without Mack tasks')
    tasks = areas.add_parser('tasks', help='Mack tasks, including completed and cancelled history')
    task_actions = tasks.add_subparsers(dest='action', required=True)
    listing = task_actions.add_parser('list')
    listing.add_argument('--status', default='open')
    listing.add_argument('--client-id', type=int)
    listing.add_argument('--project')
    listing.add_argument('--query')
    listing.add_argument('--limit', type=int, default=50)
    listing.add_argument('--offset', type=int, default=0)
    task_actions.add_parser('get').add_argument('id')
    create = task_actions.add_parser('create')
    create.add_argument('title')
    create.add_argument('--client-id', required=True, type=int)
    for option in ('project', 'description', 'due_date', 'priority', 'visibility', 'category', 'status', 'metadata'):
        create.add_argument('--' + option.replace('_', '-'))
    update = task_actions.add_parser('update')
    update.add_argument('id')
    for option in ('title', 'description', 'status', 'priority', 'visibility', 'due_date', 'category', 'assignee_name'):
        update.add_argument('--' + option.replace('_', '-'))
    update.add_argument('--clear-due-date', action='store_true')
    update.add_argument('--clear-category', action='store_true')
    update.add_argument('--metadata-patch', help='JSON object; null removes a key')
    for name in ('complete', 'cancel'):
        task_actions.add_parser(name).add_argument('id')
    move = task_actions.add_parser('move')
    move.add_argument('id')
    move.add_argument('--project', required=True, help='Project ID/name, or none to remove membership')
    projects = areas.add_parser('projects', help='Geopetto projects, distinct from GeoStar clients')
    project_actions = projects.add_subparsers(dest='action', required=True)
    project_actions.add_parser('list').add_argument('--archived', action='store_true')
    get_project = project_actions.add_parser('get')
    get_project.add_argument('ref')
    get_project.add_argument('--no-tasks', action='store_true')
    create_project = project_actions.add_parser('create')
    create_project.add_argument('name')
    create_project.add_argument('--context-file')
    update_project = project_actions.add_parser('update')
    update_project.add_argument('ref')
    update_project.add_argument('--name')
    update_project.add_argument('--context-file')
    for name in ('archive', 'restore'):
        project_actions.add_parser(name).add_argument('ref')
    return root


def main(argv: list[str] = None) -> None:
    args = parser().parse_args(argv)
    client = Client()
    if args.area == 'clients':
        return emit(client.call('GET', '/clients', params={'all': str(args.all).lower()}))
    if args.area == 'tasks':
        if args.action == 'list':
            params = {'status': args.status, 'limit': args.limit, 'offset': args.offset}
            if args.client_id is not None:
                params['client_id'] = args.client_id
            if args.project:
                params['project'] = args.project
            if args.query:
                params['q'] = args.query
            return emit(client.call('GET', '/tasks', params=params))
        if args.action == 'get':
            return emit(client.call('GET', '/tasks/' + quote(args.id, safe='')))
        if args.action == 'create':
            body = {'title': args.title, 'client_id': args.client_id,
                    **supplied(args, ('project', 'description', 'due_date', 'priority', 'visibility', 'category', 'status'))}
            if args.metadata:
                body['metadata'] = json.loads(args.metadata)
            fingerprint_body = dict(body)
            if args.project:
                body['expectedRevision'] = client.revision('project')
            return emit(safe_create(client, '/tasks', body, fingerprint_body))
        if args.action == 'move':
            destination = None if args.project.lower() == 'none' else args.project
            body = {'project': destination, 'expectedRevision': client.revision('project')}
            return emit(client.call('PUT', '/tasks/' + quote(args.id, safe='') + '/project', body))
        patch = supplied(args, ('title', 'description', 'status', 'priority', 'visibility', 'due_date', 'category', 'assignee_name')) if args.action == 'update' else {'status': 'completed' if args.action == 'complete' else 'cancelled'}
        if args.action == 'update':
            if args.clear_due_date:
                patch['due_date'] = None
            if args.clear_category:
                patch['category'] = None
        body = {'patch': patch, 'expectedRevision': client.revision('task', args.id)}
        if args.action == 'update' and args.metadata_patch:
            body['metadataPatch'] = json.loads(args.metadata_patch)
        if not patch and 'metadataPatch' not in body:
            raise AgentError('No task changes requested', 'invalid_request')
        return emit(client.call('PATCH', '/tasks/' + quote(args.id, safe=''), body))
    if args.action == 'list':
        return emit(client.call('GET', '/projects', params={'archived': str(args.archived).lower()}))
    if args.action == 'get':
        return emit(client.call('GET', '/projects/' + quote(args.ref, safe=''), params={'tasks': 'false' if args.no_tasks else 'true'}))
    if args.action == 'create':
        body = {'name': args.name, 'expectedRevision': client.revision('project')}
        if args.context_file:
            body['context'] = Path(args.context_file).read_text()
        return emit(safe_create(client, '/projects', body, {k: v for k, v in body.items() if k != 'expectedRevision'}))
    body = {'expectedRevision': client.revision('project')}
    if args.action == 'update':
        if args.name:
            body['name'] = args.name
        if args.context_file:
            body['context'] = Path(args.context_file).read_text()
        if len(body) == 1:
            raise AgentError('No project changes requested', 'invalid_request')
    else:
        body['archived'] = args.action == 'archive'
    return emit(client.call('PATCH', '/projects/' + quote(args.ref, safe=''), body))


if __name__ == '__main__':
    try:
        main()
    except (AgentError, json.JSONDecodeError, OSError, ValueError) as exc:
        output = {'code': getattr(exc, 'code', 'invalid_input'), 'error': str(exc)}
        if getattr(exc, 'readback', None) is not None:
            output['readback'] = exc.readback
        emit(output)
        sys.exit(1)
