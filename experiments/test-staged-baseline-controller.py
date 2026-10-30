"""Exercise the admission/ledger lifecycle with fake compute and fake harness."""
from contextlib import nullcontext
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import time
from types import SimpleNamespace as NS
import unittest
from unittest.mock import patch


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(path))
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


controller = module("controller", "run-staged-baseline.py")
budget = module("budget", "staged-baseline-budget.py")
fixtures = module("fixtures", "test-staged-baseline-budget.py")


class ControllerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        f = fixtures.BudgetTest()
        f.setUp()
        self.spec = {"plan": f.plan, "profiles": f.profiles, "private_image_id": "fake-image",
                     "sources": {"staged_qwen_provider.py": "provider", "qwen_cuda_environment.py": "helper"},
                     "model_hashes": {"model": "frozen"}, "settings": {}, "benchmark_path": "fake-benchmark"}
        (self.root / "prepared.json").write_text(json.dumps(self.spec))
        (self.root / "ledger.json").write_text("[]")
        self.approval = self.root / "approval.json"
        self.auth = {"user_explicitly_approved_scored_launch": True,
                     "prepared_sha256": hashlib.sha256((self.root / "prepared.json").read_bytes()).hexdigest(),
                     "callback_thread": "fake-thread", "billing": {"observed_at": time.time(),
                     "spend_limit_usd": 0, "usage_ceiling_usd": 25, "net_spend_usd": 0,
                     "free_credits_usd": 30, "usage_usd": 0, "cycle_ends_at": time.time() + 86400}}
        self.approval.write_text(json.dumps(self.auth))

    def test_no_approval_cannot_import_compute(self):
        self.auth["user_explicitly_approved_scored_launch"] = False
        self.approval.write_text(json.dumps(self.auth))
        with patch.object(controller, "load_module", side_effect=AssertionError("Compute import forbidden")):
            with self.assertRaises(ValueError):
                controller.run(self.root, self.approval)

    def test_stale_or_paid_billing_cannot_import_compute(self):
        for change in ({"observed_at": time.time() - 600}, {"net_spend_usd": 1}, {"spend_limit_usd": 1}):
            billing = dict(self.auth["billing"], **change)
            self.approval.write_text(json.dumps(dict(self.auth, billing=billing)))
            with patch.object(controller, "load_module", side_effect=AssertionError("Compute import forbidden")):
                with self.assertRaises(ValueError):
                    controller.run(self.root, self.approval)

    def fake_run(self, missing_result=False):
        metadata = {"hashes": self.spec["model_hashes"], "source_sha256": "provider",
                    "toolchain": {"source_sha256": "helper"}}
        provider = NS(app=NS(run=nullcontext, app_id="fake-app"),
                      packaging_check=NS(spawn=lambda: NS(get=lambda **_: {"source_sha256": "provider", "gpu_requested": False})),
                      Qwen=lambda: NS(metadata=NS(spawn=lambda: NS(get=lambda **_: metadata))))
        server = NS(server_port=1234, shutdown=lambda: None, server_close=lambda: None)
        modules = {"staged_budget": budget, "staged_qwen_provider": provider,
                   "staged_bridge": NS(bridge=lambda *_, **__: server)}

        def command(args, **kwargs):
            if args[0] == "bundle" and not missing_result:
                root = Path(args[args.index("--runs_dir") + 1])
                (root / "result.json").write_text(json.dumps({"outcome": {"scored": False}}))
            return NS(returncode=0, stdout="", stderr="")

        with patch.object(controller, "verify"), patch.object(controller, "load_module", side_effect=lambda name, _: modules[name]), \
             patch.dict(sys.modules, {"modal": NS(enable_output=nullcontext)}), \
             patch.object(controller.subprocess, "run", side_effect=command), patch.dict(controller.os.environ):
            controller.run(self.root, self.approval)
        return json.loads((self.root / "ledger.json").read_text())

    def test_unscored_attempts_preserved_and_independent_work_continues(self):
        ledger = self.fake_run()
        self.assertEqual(len(ledger), 135)
        self.assertEqual(len({(x["task"], x["attempt"]) for x in ledger}), 135)
        self.assertTrue(all(x["status"] == "finished" for x in ledger))
        # Running the same prepared ledger again must never execute a trial.
        with patch.object(controller, "verify"), patch.object(controller, "load_module", return_value=budget), \
             patch.object(controller.subprocess, "run", side_effect=AssertionError("No retry")):
            with self.assertRaisesRegex(ValueError, "No complete wave"):
                controller.run(self.root, self.approval)

    def test_missing_harness_results_stop_later_admission(self):
        ledger = self.fake_run(missing_result=True)
        self.assertEqual(len(ledger), 4)
        event = json.loads(next(self.root.glob("batch-*/event.json")).read_text())
        self.assertEqual(event["status"], "environment_failure")


if __name__ == "__main__":
    unittest.main()
