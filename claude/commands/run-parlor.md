Start the Parlor voice assistant (server + voice client).

Run these steps in sequence:

1. Check if the Parlor server is already running on port 8000:
   - Run `lsof -i :8000 -t` to check
   - If a process is found, check if it's the parlor server with `ps -p <pid> -o command=`
   - If it's already the parlor server, skip to step 3

2. Start the Parlor server in the background:
   - Run `cd ~/code/parlor/src && uv run server.py` as a background task
   - Wait for the server to become available by polling `curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/` every 10 seconds (up to 2 minutes — model loading takes time on first run)
   - If the server doesn't come up, check the background task output for errors and report to the user

3. Check if the voice client is already running:
   - Run `pgrep -f voice_client.py` to check
   - If already running, tell the user Parlor is ready and exit

4. Start the voice client:
   - Run `cd ~/code/parlor/src && uv run voice_client.py` as a background task
   - Wait a few seconds for it to initialize
   - Confirm to the user that Parlor is running and remind them the hotkey is **Cmd+Ctrl+Shift+V**

## Stopping

If the user says "stop parlor" or "kill parlor", kill both processes:
- `pkill -f voice_client.py`
- `kill $(lsof -i :8000 -t)` (only if it's the parlor server)

## Notes

- The server takes 30-60 seconds to start on subsequent runs (model loading)
- The voice client requires macOS Accessibility permission for the global hotkey
- Both processes run from `~/code/parlor/src`
