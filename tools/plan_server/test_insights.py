import copy
import json
import unittest
from datetime import datetime, timezone
from pathlib import Path
import insights

DEMO = Path(__file__).resolve().parents[2] / 'terra_nt/assets/data/travel_insights_demo.json'


class InsightsTest(unittest.TestCase):
    def setUp(self):
        self.rows = insights.load(DEMO)
        self.now = datetime(2026, 10, 17, 12, tzinfo=timezone.utc)

    def test_demo_never_enters_prompt(self):
        self.assertEqual(insights.context_block(self.rows, ['Darwin'], self.now), ('', []))

    def test_only_current_exact_matches(self):
        rows = copy.deepcopy(self.rows)
        for row in rows:
            row['data_mode'] = 'real'
        self.assertEqual(len(insights.retrieve(rows, [' darwin '], self.now)), 4)
        self.assertEqual(insights.retrieve(rows, ['Darwin Waterfront'], self.now), [])
        self.assertEqual(insights.retrieve(rows, ['Darwin'], datetime(2027, 1, 1, tzinfo=timezone.utc)), [])
        block, ids = insights.context_block(rows, ['Darwin'], self.now)
        self.assertEqual(len(ids), 4)
        self.assertIn('untrusted data', block)
        self.assertIn('https://example.com', block)
        self.assertEqual(insights.context_block(rows, ['Darwin'], self.now, cap=10), ('', []))

    def test_invalid_records(self):
        for mutate in (
            lambda r: r.append(r[0]),
            lambda r: r[0]['data'].update(price_cents_per_litre=-1),
            lambda r: r[0].update(source_url='http://example.com'),
            lambda r: r[0].update(observed_at='2026-10-17'),
            lambda r: r[2]['data'].update(rating=6),
        ):
            rows = copy.deepcopy(self.rows)
            mutate(rows)
            with self.assertRaises(ValueError):
                insights.parse_dataset(json.dumps({'schema_version': '1.0', 'records': rows}))

    def test_planner_optional_import_is_source_linked_and_demo_free(self):
        import os
        import tempfile
        from unittest import mock
        import server
        rows = copy.deepcopy(self.rows)
        rows[0]['data_mode'] = 'real'
        rows[0]['observed_at'] = '2000-01-01T00:00:00Z'
        rows[0]['expires_at'] = '2099-01-01T00:00:00Z'
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'insights.json'
            path.write_text(json.dumps({'schema_version': '1.0', 'records': rows}))
            with mock.patch.dict(os.environ, {'TRAVEL_INSIGHTS_FILE': str(path)}):
                planner = server.Planner('fixture', None, None, [], None)
            # Template filling has its existing tests; isolate evidence assembly.
            with mock.patch.object(server, 'fill', return_value='template'):
                prompt = planner.build_prompt({'region': 'top_end', 'startLocation': 'Darwin', 'endLocation': 'Katherine'})
            self.assertIn('demo-fuel', prompt.context)
            self.assertNotIn('demo-coverage', prompt.context)
            self.assertIn('https://example.com/terra-nt-demo', prompt.context)
