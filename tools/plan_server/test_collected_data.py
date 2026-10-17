"""Regression checks for collection joins, exclusions and historical isolation."""
import copy
from datetime import datetime, timezone
import json
import unittest
import import_collected_data as collected
import insights

class CollectedDataTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.payload, cls.report = collected.build(collected.DEFAULT_PACKAGE)

    def test_real_package_counts_and_contract(self):
        records = insights.parse_dataset(json.dumps(self.payload))
        self.assertEqual(len(records), 470)
        self.assertEqual(self.report['app_kinds'], {'fuel': 313, 'accommodation': 157})
        self.assertTrue(all(r['data_mode'] == 'real' and r['data']['historical'] for r in records))
        self.assertTrue(all('comparison_price_cents_per_litre' not in r['data'] for r in records))
        self.assertTrue(all('rating' not in r['data'] for r in records))
        self.assertEqual(self.report['excluded']['synthetic_fuel'], 2)
        self.assertEqual(self.report['loader_errors'], [])
        self.assertEqual(self.report['verified_records'], 0)
        self.assertEqual(self.report['counts']['coverage'], 629)

    def test_historical_never_enters_live_prompt_even_with_extended_expiry(self):
        rows = copy.deepcopy(self.payload['records'])
        for row in rows:
            row['expires_at'] = '2099-01-01T00:00:00Z'
        names = [n for r in rows for n in r['place_names']]
        self.assertEqual(insights.context_block(rows, names, datetime(2026, 10, 17, tzinfo=timezone.utc)), ('', []))

    def test_pending_or_incomplete_source_not_publishable(self):
        row = {'source_ids': ['a']}
        for source in ({'access_status':'pending','allowed_uses':['display','storage']},
                       {'access_status':'confirmed','allowed_uses':['display']},
                       {'access_status':'confirmed','allowed_uses':[]}):
            self.assertFalse(collected.supported_source(row, {'a':source}))
        self.assertFalse(collected.supported_source({'source_ids':[]}, {}))

    def test_duplicate_identity_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            collected.keyed([{'entity_id':'a'}, {'entity_id':'a'}], 'entity_id')

    def test_context_cap_reports_whole_nt_omissions(self):
        self.assertEqual(self.report['regional_contexts']['top_end']['omitted'], [])
        self.assertTrue(self.report['regional_contexts']['full_nt']['omitted'])
        self.assertLessEqual(self.report['regional_contexts']['full_nt']['characters'], 12000)

    def test_snapshot_requires_valid_interval(self):
        with self.assertRaises(ValueError):
            collected.envelope({'record_id':'a'}, {}, {}, 'fuel', {}, '')

if __name__ == '__main__':
    unittest.main()
