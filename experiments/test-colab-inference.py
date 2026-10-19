"""Local protocol checks; no GPU, model download, or evaluation task needed."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("colab_inference", Path(__file__).with_name("colab-agent-inference.py"))
inference = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inference)
inference.MODEL_ID = "fixture-model"
inference.REVISION = inference.EXPECTED_REVISION


class RelayTests(unittest.TestCase):
    def test_multiline_commands_and_extra_parameters(self):
        command = "cat <<'EOF' > file.rb\nputs 'hello'\nEOF"
        raw = f"<tool_call><function=bash><parameter=command>\n{command}\n</parameter></function></tool_call>"
        calls = inference.parse_calls(raw)
        self.assertEqual(json.loads(calls[0]["function"]["arguments"]), {"command": command})
        malformed = raw.replace("</parameter>", "</parameter><parameter=extra>bad</parameter>")
        self.assertEqual(inference.parse_calls(malformed), [])
        self.assertEqual(inference.parse_calls(raw[:-12]), [])
        self.assertEqual(inference.parse_calls("Please run echo hello"), [])

    def test_runtime_error_is_not_a_model_answer(self):
        output = io.StringIO()
        with patch.object(inference, "_colab_complete", side_effect=RuntimeError("CUDA fixture")):
            with contextlib.redirect_stdout(output):
                inference.colab_complete(json.dumps({"id": "fixture-request"}))
        response = json.loads(output.getvalue())
        self.assertEqual(response["relay_id"], "fixture-request")
        self.assertEqual(response["revision"], inference.EXPECTED_REVISION)
        self.assertEqual(response["error"], {"type": "RuntimeError", "message": "CUDA fixture"})
        self.assertNotIn("choices", response)
        self.assertNotIn("usage", response)

    def test_success_is_preserved(self):
        response = {"relay_id": "fixture-request", "choices": [{"message": {"content": "fixture"}}]}
        output = io.StringIO()
        with patch.object(inference, "_colab_complete", return_value=response):
            with contextlib.redirect_stdout(output):
                inference.colab_complete('{"id":"fixture-request"}')
        self.assertEqual(json.loads(output.getvalue()), response)


if __name__ == "__main__":
    unittest.main()
