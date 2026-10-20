"""Delivery fixtures never call a live agent."""
import json
from pathlib import Path
import runpy
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

module = SimpleNamespace(**runpy.run_path(
    str(Path(__file__).resolve().parents[1] / "bin/notify-local-evaluation")))


class NotifyTests(unittest.TestCase):
    def test_success_is_sent_only_once(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(module.subprocess, "run") as run:
            directory = Path(temporary)
            run.return_value = SimpleNamespace(returncode=0, stdout="Queued message", stderr="")
            module.notify(directory, "example-thread", "/example/codex")
            module.notify(directory, "example-thread", "/example/codex")
            self.assertEqual(run.call_count, 1)
            self.assertEqual(run.call_args.args[0][:4],
                             ["/example/codex", "queue", "--thread", "example-thread"])
            self.assertEqual(json.loads((directory / "delivery.json").read_text())["status"], "queued")

    def test_ambiguous_delivery_does_not_resend(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(module.subprocess, "run") as run:
            directory = Path(temporary)
            run.side_effect = TimeoutError("unknown delivery")
            module.notify(directory, "example-thread", "/example/codex")
            module.notify(directory, "example-thread", "/example/codex")
            self.assertEqual(run.call_count, 1)
            self.assertEqual(json.loads((directory / "delivery.json").read_text())["status"], "uncertain")

    def test_acknowledged_event_is_not_sent(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(module.subprocess, "run") as run:
            directory = Path(temporary)
            (directory / "ack.json").write_text("{}")
            module.notify(directory, "example-thread", "/example/codex")
            run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
