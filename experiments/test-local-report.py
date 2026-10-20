"""Local evidence fixtures; never start Docker, Local, or a model."""
import json
import runpy
import tempfile
import unittest
from pathlib import Path

summarize = runpy.run_path(str(Path(__file__).resolve().parents[1] / "bin/report-local-run"))["summarize"]


class ReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "relay").mkdir()

    def write(self, name, data):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data))

    def request(self, identity):
        self.write(f"relay/{identity}.request.json",
                   {"id": identity, "model": "model", "prefill_chunk_size": 1024})

    def response(self, identity, **changes):
        response = {"relay_id": identity, "model": "model", "revision": "pinned",
                    "prefill_chunk_size": 1024, "attention": "eager", "eos_token_id": 248046,
                    "usage": {"prompt_tokens": 20, "completion_tokens": 10},
                    "seconds": 1.5, "peak_unified_memory_GiB": 3.0,
                    "choices": [{"finish_reason": "length"}]}
        response.update(changes)
        self.write(f"relay/{identity}.response.json", response)

    def test_invalid_trial_keeps_usage_without_assigning_reward(self):
        self.request("success")
        self.response("success")
        self.request("error")
        self.write("relay/error.response.json", {"relay_id": "error", "model": "model",
                                               "error": {"type": "AssertionError"}})
        self.write("trials/model/trial/result.json", {
            "trial": "trial", "outcome": {"name": "agent_error", "scored": False},
            "reward": 0, "duration": 12})
        result = summarize(self.root)
        self.assertEqual(result["generated_input_tokens"], 20)
        self.assertEqual(len(result["runtime_errors"]), 1)
        self.assertEqual(result["truncated_responses"], ["success"])
        self.assertNotIn("reward", result["trials"][0])

    def test_pending_and_absent_trial_are_incomplete(self):
        self.request("pending")
        result = summarize(self.root)
        self.assertEqual(result["pending_requests"], ["pending"])
        self.assertEqual(result["trials"], [])
        self.assertIsNone(result["peak_allocated_unified_memory_GiB"])

    def test_unified_memory_and_quantization_are_recorded(self):
        self.request("mlx")
        self.response("mlx", backend="mlx", quantization_bits=4,
                      peak_gpu_GiB=None, peak_unified_memory_GiB=2.81)
        result = summarize(self.root)
        self.assertNotIn("peak_allocated_gpu_GiB", result)
        self.assertEqual(result["peak_allocated_unified_memory_GiB"], 2.81)
        self.assertEqual(result["observed_settings"][0]["backend"], "mlx")
        self.assertEqual(result["observed_settings"][0]["quantization_bits"], 4)

    def test_misrouted_response_and_changed_setting_fail(self):
        self.request("request")
        for changes in ({"relay_id": "wrong"}, {"prefill_chunk_size": None}):
            with self.subTest(changes=changes):
                self.response("request", **changes)
                with self.assertRaises(ValueError):
                    summarize(self.root)

    def test_orphan_response_fails(self):
        self.response("orphan")
        with self.assertRaises(ValueError):
            summarize(self.root)

    def test_scored_step_limit_preserves_reward_without_inventing_submission(self):
        self.write("trials/model/trial/result.json", {
            "trial": "trial", "outcome": {"name": "step_limit_reached", "scored": True},
            "reward": 1.0})
        self.write("trials/model/trial/agent.result.json", {
            "status": "step_limit", "submission": None, "input_tokens": 0, "output_tokens": 0})
        trial = summarize(self.root)["trials"][0]
        self.assertEqual(trial["reward"], 1.0)
        self.assertIsNone(trial["submission"])
        self.assertEqual(trial["agent_status"], "step_limit")

    def test_late_response_is_generated_but_not_consumed(self):
        for identity in ("parsed", "late"):
            self.write(f"relay/{identity}.request.json", {
                "id": identity, "model": "model", "prefill_chunk_size": 1024, "relay_protocol": 3 if identity == "parsed" else 2})
            self.response(identity)
        self.write("relay/parsed.consumed.json", {"relay_id": "parsed", "revision": "pinned"})
        result = summarize(self.root)
        self.assertEqual(result["generated_input_tokens"], 40)
        self.assertEqual(result["consumption_receipts"], {
            "available_for_all_requests": True, "parsed_response_ids": ["parsed"],
            "parsed_input_tokens": 20, "parsed_output_tokens": 10})

    def test_legacy_receipts_are_unknown_and_mismatches_rejected(self):
        self.request("legacy")
        self.response("legacy")
        self.assertFalse(summarize(self.root)["consumption_receipts"]["available_for_all_requests"])
        self.write("relay/legacy.consumed.json", {"relay_id": "wrong", "revision": "pinned"})
        with self.assertRaises(ValueError):
            summarize(self.root)

    def test_quarantined_generation_counts_usage_without_pending_or_consumption(self):
        self.request("expired")
        self.response("expired")
        (self.root / "relay/expired.response.json").rename(self.root / "relay/expired.late.json")
        self.write("relay/expired.expired.json", {"relay_id": "expired"})
        result = summarize(self.root)
        self.assertEqual(result["generated_input_tokens"], 20)
        self.assertEqual(result["pending_requests"], [])
        self.assertEqual(result["expired_requests"], ["expired"])
        self.assertEqual(result["quarantined_late_responses"], ["expired"])
        self.assertEqual(result["consumption_receipts"]["parsed_response_ids"], [])
        self.write("relay/expired.consumed.json", {"relay_id": "expired", "revision": "pinned"})
        with self.assertRaises(ValueError):
            summarize(self.root)


if __name__ == "__main__":
    unittest.main()
