import tempfile
import unittest
from pathlib import Path
from unittest import mock
import urllib.error
import start_connected


class ConnectedStartTest(unittest.TestCase):
    def test_env_update_preserves_other_values_and_replaces_stale_url(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / '.env'
            path.write_text('# app settings\nPLAN_API_URL=https://expired.example\nOTHER=value\n')
            start_connected.update_app_env(path, 'https://test-new-tunnel.trycloudflare.com')
            text = path.read_text()
            self.assertIn('OTHER=value', text)
            self.assertNotIn('expired.example', text)
            self.assertEqual(text.count('PLAN_API_URL='), 1)
            with self.assertRaises(ValueError):
                start_connected.update_app_env(path, 'http://untrusted.example')
            self.assertEqual(path.read_text(), text)

    def test_probe_requires_401_not_an_open_or_broken_server(self):
        for status, expected in [(401, True), (403, False), (502, False)]:
            error = urllib.error.HTTPError('https://example.com', status, '', {}, None)
            with mock.patch('urllib.request.urlopen', side_effect=error):
                self.assertEqual(start_connected.auth_probe('https://example.com'), expected)
