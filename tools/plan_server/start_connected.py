"""Start the authenticated planner + HTTPS demo tunnel and update the app env.

Run from any directory with the existing server virtualenv. Keep this process
running while using the app; Ctrl+C stops only children created by this script.
"""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
URL = re.compile(r'https://[a-z0-9-]+\.trycloudflare\.com')


def update_app_env(path, url):
    if not URL.fullmatch(url):
        raise ValueError('Unexpected tunnel URL')
    text = path.read_text(encoding='utf-8') if path.exists() else ''
    text, count = re.subn(r'^PLAN_API_URL=.*$', 'PLAN_API_URL=' + url, text, flags=re.M)
    if not count:
        text = text.rstrip() + '\nPLAN_API_URL=' + url + '\n'
    path.write_text(text, encoding='utf-8')


def auth_probe(base):
    request = urllib.request.Request(base + '/v1/itinerary', data=b'{}',
        headers={'Content-Type': 'application/json'}, method='POST')
    try:
        with urllib.request.urlopen(request, timeout=5):
            return False
    except urllib.error.HTTPError as error:
        # A reachable server MUST still require the Firebase login token.
        return error.code == 401
    except OSError:
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--backend', choices=['gemini', 'codex', 'openrouter'], default='gemini')
    args = parser.parse_args()
    python = HERE / '.venv' / ('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
    tunnel_binary = shutil.which('cloudflared')
    if not python.exists() or not tunnel_binary:
        raise SystemExit('Install the server virtualenv and cloudflared as described in README.md.')
    children = []
    tunnel_url = []
    try:
        planner = subprocess.Popen([str(python), str(HERE / 'server.py'), '--backend', args.backend,
            '--host', '127.0.0.1', '--port', '8787'], cwd=ROOT)
        children.append(planner)
        for _ in range(30):
            if planner.poll() is not None:
                raise RuntimeError('Planner exited; check credentials or whether port 8787 is already in use.')
            if auth_probe('http://127.0.0.1:8787'):
                break
            time.sleep(0.5)
        else:
            raise RuntimeError('Authenticated planner did not become ready.')
        tunnel = subprocess.Popen([tunnel_binary, 'tunnel', '--url', 'http://127.0.0.1:8787',
            '--no-autoupdate'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        children.append(tunnel)
        def consume():
            for line in tunnel.stdout:
                matches = URL.findall(line)
                if matches:
                    tunnel_url[:] = [matches[-1]]
        threading.Thread(target=consume, daemon=True).start()
        for _ in range(90):
            if tunnel.poll() is not None:
                raise RuntimeError('HTTPS tunnel exited before becoming ready.')
            if tunnel_url and auth_probe(tunnel_url[0]):
                break
            time.sleep(1)
        else:
            raise RuntimeError('The tunnel could not be verified. App configuration was not changed.')
        update_app_env(ROOT / 'terra_nt' / '.env', tunnel_url[0])
        print('Authenticated planner is reachable over HTTPS. App .env updated.', flush=True)
        print('Rebuild from terra_nt: flutter run --dart-define-from-file=.env', flush=True)
        print('Keep this window open. The temporary URL changes when restarted.', flush=True)
        while all(child.poll() is None for child in children):
            time.sleep(1)
        raise RuntimeError('Planner or tunnel stopped; restart this command and rebuild the app.')
    except KeyboardInterrupt:
        print('\nStopping this launcher’s planner and tunnel.')
    finally:
        for child in reversed(children):
            if child.poll() is None:
                child.terminate()
                try:
                    child.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    child.kill()
                    child.wait()


if __name__ == '__main__':
    main()
