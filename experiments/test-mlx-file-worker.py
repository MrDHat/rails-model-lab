"""Transport and parser boundary checks; no MLX, model, network, or grader."""
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import runpy
import tempfile
import unittest
import uuid

worker = runpy.run_path(str(Path(__file__).with_name("mlx-file-worker.py")))


class Tokenizer:
    def apply_chat_template(self, messages, **kwargs):
        self.messages, self.options = messages, kwargs
        return [1, 2, 3]


class WorkerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.request = {
            "id": str(uuid.uuid4()), "model": worker["MODEL"], "relay_protocol": 3,
            "expires_at": (datetime.now(timezone.utc) + timedelta(minutes=1)).isoformat(),
            "messages": [{"role": "assistant", "tool_calls": [{"function": {
                "name": "bash", "arguments": '{"command":"echo OK"}'}}]}],
            "tools": [], "enable_thinking": False, "do_sample": False,
            "prefill_chunk_size": 1024, "input_token_limit": 16384, "max_new_tokens": 2048,
        }

    def response(self, raw="OK<|im_end|>", reason="stop"):
        return worker["response_for"](self.request, raw, 3, 2, reason, 1.0, 2**30)

    def test_template_preserves_request_and_normalizes_tool_arguments(self):
        original = json.dumps(self.request)
        tokenizer = Tokenizer()
        self.assertEqual(worker["prepare"](self.request, tokenizer), [1, 2, 3])
        self.assertEqual(json.dumps(self.request), original)
        self.assertEqual(tokenizer.messages[0]["tool_calls"][0]["function"]["arguments"],
                         {"command": "echo OK"})
        self.assertFalse(tokenizer.options["enable_thinking"])

    def test_refuses_wrong_runtime_and_context_before_generation(self):
        for field, value in [("model", "Qwen/Qwen3.5-4B"), ("do_sample", True),
                             ("enable_thinking", True), ("prefill_chunk_size", 512),
                             ("relay_protocol", 2), ("input_token_limit", 2)]:
            request = self.request | {field: value}
            with self.subTest(field=field), self.assertRaises(ValueError):
                worker["prepare"](request, Tokenizer())

    def test_only_complete_native_calls_are_tools_and_length_stays_length(self):
        raw = '<tool_call>\n<function=bash><parameter=command>echo OK</parameter></function>\n</tool_call>'
        complete = self.response(raw)
        self.assertEqual(complete["choices"][0]["finish_reason"], "tool_calls")
        self.assertEqual(json.loads(complete["choices"][0]["message"]["tool_calls"][0]
                                    ["function"]["arguments"]), {"command": "echo OK"})
        partial = self.response(raw[:-12], "length")
        self.assertEqual(partial["choices"][0]["finish_reason"], "length")
        self.assertEqual(partial["choices"][0]["message"]["tool_calls"], [])
        self.assertNotIn("peak_gpu_GiB", complete)
        self.assertEqual(complete["peak_unified_memory_GiB"], 1.0)

    def test_deadline_or_expiry_marker_quarantines_without_consumable_file(self):
        for marker in (False, True):
            request = self.request | {"id": str(uuid.uuid4())}
            if marker:
                (self.root / f'{request["id"]}.expired.json').write_text('{}')
            else:
                request["expires_at"] = (datetime.now(timezone.utc) - timedelta(seconds=1)).isoformat()
            response = self.response() | {"relay_id": request["id"]}
            self.assertEqual(worker["deliver"](request, response, self.root), "late")
            self.assertFalse((self.root / f'{request["id"]}.response.json').exists())

    def test_delivery_and_duplicate_are_distinct(self):
        response = self.response()
        self.assertEqual(worker["deliver"](self.request, response, self.root), "response")
        path = self.root / f'{self.request["id"]}.response.json'
        self.assertEqual(json.loads(path.read_text()), response)
        with self.assertRaises(ValueError):
            worker["deliver"](self.request, response, self.root)
        self.assertEqual(json.loads(path.read_text()), response)


if __name__ == "__main__":
    unittest.main()
