"""Check observer failure boundaries without running a model or Docker."""
import json
from pathlib import Path
import runpy
import tempfile
from types import SimpleNamespace
import unittest

watch = SimpleNamespace(**runpy.run_path(
    str(Path(__file__).resolve().parents[1] / "bin/watch-local-evaluation")))


class WatchTests(unittest.TestCase):
    def test_decisions(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "relay").mkdir()
            self.assertIsNone(watch.inspect_run(root, True, 9 * 2**30, 0))
            self.assertEqual(watch.inspect_run(root, False, 9 * 2**30, 0)["kind"], "process_exited")
            self.assertEqual(watch.inspect_run(root, True, 0, 0)["kind"], "low_disk")
            self.assertEqual(watch.inspect_run(root, True, 9 * 2**30, 10**12)["kind"], "stalled")
            (root / "relay/x.request.json").write_text(json.dumps({"created_at": "2000-01-01T00:00:00Z"}))
            self.assertEqual(watch.inspect_run(root, True, 9 * 2**30, watch.time.time())["kind"], "overdue")

    def test_harness_result_takes_priority_and_unscored_stays_unscored(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "trials").mkdir()
            result = {"trial": "example", "outcome": {"scored": False, "name": "agent_error"}}
            (root / "trials/result.json").write_text(json.dumps(result))
            event = watch.inspect_run(root, False, 0, 0)
            self.assertEqual(event["kind"], "finished")
            self.assertFalse(event["outcome"]["scored"])
            self.assertIsNone(event["reward"])
            result.update(outcome={"scored": True, "name": "completed"}, reward=0)
            (root / "trials/result.json").write_text(json.dumps(result))
            self.assertEqual(watch.inspect_run(root, False, 0, 0)["reward"], 0)


if __name__ == "__main__":
    unittest.main()
