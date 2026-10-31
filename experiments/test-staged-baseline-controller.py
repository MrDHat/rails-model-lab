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

    def test_low_disk_cannot_import_compute_or_consume_identity(self):
        with patch.object(controller, "verify"), \
             patch.object(controller.shutil, "disk_usage", return_value=NS(free=2 * 1024**3)), \
             patch.object(controller, "load_module", side_effect=AssertionError("Compute import forbidden")):
            with self.assertRaisesRegex(ValueError, "12 GiB"):
                controller.run(self.root, self.approval)
        self.assertEqual(json.loads((self.root / "ledger.json").read_text()), [])

    def test_incomplete_infrastructure_validation_cannot_start_compute(self):
        self.spec["status"] = "not_launch_ready_infrastructure_validation_required"
        (self.root / "prepared.json").write_text(json.dumps(self.spec))
        self.auth["prepared_sha256"] = controller.digest(self.root / "prepared.json")
        self.approval.write_text(json.dumps(self.auth))
        with patch.object(controller, "verify"), \
             patch.object(controller.shutil, "disk_usage", return_value=NS(free=100 * 1024**3)), \
             patch.object(controller, "load_module", side_effect=AssertionError("Compute import forbidden")):
            with self.assertRaisesRegex(ValueError, "not launch ready"):
                controller.run(self.root, self.approval)

    def fake_run(self, missing_result=False, environment_error=False, provider_error=False, stop_fails=False):
        self.app_run_options = None
        self.commands = []

        def app_run(**options):
            self.app_run_options = options
            return nullcontext()

        metadata = {"hashes": self.spec["model_hashes"], "source_sha256": "provider",
                    "toolchain": {"source_sha256": "helper"}}
        def ready(payload):
            self.assertIsNone(payload, "Readiness must not perform inference")
            return NS(get=lambda **_: metadata)

        provider = NS(app=NS(run=app_run, app_id="fake-app"),
                      packaging_check=NS(spawn=lambda: NS(get=lambda **_: {"source_sha256": "provider", "gpu_requested": False})),
                      Qwen=lambda: NS(complete=NS(spawn=ready)))
        server = NS(server_port=1234, shutdown=lambda: None, server_close=lambda: None)
        modules = {"staged_budget": budget, "staged_qwen_provider": provider,
                   "staged_bridge": NS(bridge=lambda *_, **__: server)}

        def command(args, **kwargs):
            self.commands.append(args)
            if "stop" in args and stop_fails:
                return NS(returncode=1, stdout="", stderr="synthetic stop failure")
            if args[0] == "bundle" and not missing_result:
                root = Path(args[args.index("--runs_dir") + 1])
                (root / "result.json").write_text(json.dumps({"outcome": {"scored": False,
                    "name": "environment_error" if environment_error else "agent_error"}}))
                if provider_error:
                    rpc = root.parent / "rpc"
                    rpc.mkdir(exist_ok=True)
                    (rpc / "shared.error.json").write_text('{"error":"shared provider unavailable"}')
            return NS(returncode=0, stdout="", stderr="")

        with patch.object(controller, "verify"), patch.object(controller, "load_module", side_effect=lambda name, _: modules[name]), \
             patch.dict(sys.modules, {"modal": NS(enable_output=nullcontext)}), \
             patch.object(controller.shutil, "disk_usage", return_value=NS(free=100 * 1024**3)), \
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
             patch.object(controller.shutil, "disk_usage", return_value=NS(free=100 * 1024**3)), \
             patch.object(controller.subprocess, "run", side_effect=AssertionError("No retry")):
            with self.assertRaisesRegex(ValueError, "No complete wave"):
                controller.run(self.root, self.approval)

    def test_missing_harness_results_stop_later_admission(self):
        ledger = self.fake_run(missing_result=True)
        self.assertEqual(len(ledger), 4)
        event = json.loads(next(self.root.glob("batch-*/event.json")).read_text())
        self.assertEqual(event["status"], "environment_failure")

    def test_environment_failure_with_result_stops_later_admission(self):
        self.assertEqual(len(self.fake_run(environment_error=True)), 4)

    def test_shared_provider_failure_with_unscored_results_stops_later_admission(self):
        self.assertEqual(len(self.fake_run(provider_error=True)), 4)
        event = json.loads(next(self.root.glob("batch-*/event.json")).read_text())
        self.assertEqual(event["status"], "shared_provider_failure")

    def test_modal_lifecycle_detaches_and_explicitly_stops_after_wave(self):
        self.fake_run(provider_error=True)
        self.assertEqual(self.app_run_options, {"detach": True})
        stops = [args for args in self.commands if "stop" in args]
        self.assertEqual(stops, [[sys.executable, "-m", "modal", "app", "stop", "--yes", "fake-app"]])

    def test_failed_explicit_stop_is_reported_for_manual_verification(self):
        self.fake_run(provider_error=True, stop_fails=True)
        batch = next(self.root.glob("batch-*"))
        self.assertIn("shutdown_error", json.loads((batch / "event.json").read_text()))
        self.assertEqual(json.loads((batch / "app-stop.json").read_text())["returncode"], 1)


class ReplacementLineageTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        def frozen(name, value):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(json.dumps(value))
            return {"path": str(path), "sha256": controller.digest(path)}
        self.evidence = frozen("result.json", {"task": "a", "outcome": {"scored": True}, "credit": 0})
        self.unscored = frozen("b/result.json", {"task": "b", "outcome": {"scored": False}})
        self.parent = {"plan": {"attempts": [{"task": "a", "attempt": 1}, {"task": "b", "attempt": 1}]},
                       "settings": {"temperature": 0.6}, "profiles": [], "model_hashes": {"weights": "fixed"},
                       "benchmark_revision": "fixed", "benchmark_files": {"task": "fixed"}}
        self.review = {"identities": [
            {"task": "a", "attempt": 1, "disposition": "retain_scored_no_retry",
             "evidence": self.evidence["path"], "evidence_sha256": self.evidence["sha256"]},
            {"task": "b", "attempt": 1, "disposition": "infrastructure_replacement_candidate",
             "evidence": self.unscored["path"], "evidence_sha256": self.unscored["sha256"],
             "reason": "Synthetic infrastructure failure"}]}
        self.spec = dict(self.parent, parent_prepared=frozen("parent.json", self.parent),
                         replacement_review=frozen("review.json", self.review),
                         replacement_authorization=frozen("authorization.json", {"user_authorized": True}))
        self.ledger = [{"task": "a", "attempt": 1, "status": "finished", "results": [self.evidence["path"]]}]

    def test_retained_scored_identity_required_even_when_credit_is_zero(self):
        origins = controller.verify_replacements(self.spec, self.ledger)
        self.assertEqual(set(origins), {("b", 1)})
        self.assertEqual(origins[("b", 1)]["evidence_sha256"], self.unscored["sha256"])
        with self.assertRaisesRegex(ValueError, "Scored original"):
            controller.verify_replacements(self.spec, [])

    def test_original_evidence_mutation_rejected(self):
        Path(self.evidence["path"]).write_text("changed")
        with self.assertRaisesRegex(ValueError, "evidence changed"):
            controller.verify_replacements(self.spec, self.ledger)

    def test_model_or_task_limit_changes_rejected(self):
        for key in ("settings", "profiles", "model_hashes", "plan"):
            with self.subTest(key=key), self.assertRaisesRegex(ValueError, "Frozen replacement"):
                controller.verify_replacements(dict(self.spec, **{key: {"changed": True}}), self.ledger)

    def test_scored_original_cannot_be_misclassified_for_replacement(self):
        item = self.review["identities"][0]
        item.update(disposition="infrastructure_replacement_candidate", reason="Incorrect classification")
        path = Path(self.spec["replacement_review"]["path"])
        path.write_text(json.dumps(self.review))
        self.spec["replacement_review"]["sha256"] = controller.digest(path)
        with self.assertRaisesRegex(ValueError, "Scored original cannot"):
            controller.verify_replacements(self.spec, self.ledger)


if __name__ == "__main__":
    unittest.main()
