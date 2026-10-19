"""Local protocol checks; no GPU, model download, or evaluation task needed."""
import contextlib
import importlib.util
import io
import json
import types
from pathlib import Path
import unittest
from unittest.mock import MagicMock, patch

spec = importlib.util.spec_from_file_location("colab_inference", Path(__file__).with_name("colab-agent-inference.py"))
inference = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inference)
inference.MODEL_ID = "fixture-model"
inference.REVISION = inference.EXPECTED_REVISION


class RelayTests(unittest.TestCase):
    def test_budgets_and_boundaries(self):
        self.assertEqual(inference.generation_limits({"max_new_tokens": 1024}, 8192), (8192, 1024))
        request = {"input_token_limit": 12288, "max_new_tokens": 2048}
        self.assertEqual(inference.generation_limits(request, 12288), (12288, 2048))
        with self.assertRaisesRegex(ValueError, '12289 > 12288'):
            inference.generation_limits(request, 12289)
        for key, value in (("input_token_limit", 16385), ("max_new_tokens", 4097),
                           ("max_new_tokens", True), ("input_token_limit", 0)):
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                inference.generation_limits({**request, key: value}, 1)

    def test_request_controls_prefill_instead_of_notebook_default(self):
        class Inputs(dict):
            def to(self, device):
                return self

        processor = MagicMock()
        processor.apply_chat_template.return_value = Inputs(input_ids=types.SimpleNamespace(shape=(1, 2)))
        processor.tokenizer.convert_tokens_to_ids.return_value = 9
        processor.tokenizer.eos_token_id = 9
        processor.decode.return_value = "fixture<|im_end|>"
        model = MagicMock()
        model.generate.return_value = [[0, 0, 9]]
        model.config.text_config._attn_implementation = "eager"
        model.generation_config.prefill_chunk_size = 2048
        torch = types.SimpleNamespace(cuda=MagicMock(), inference_mode=contextlib.nullcontext)
        torch.cuda.max_memory_allocated.return_value = 1
        request = {"id": "fixture", "model": "fixture-model", "messages": [], "tools": [], "max_new_tokens": 1024}
        with patch.dict("sys.modules", {"torch": torch}), patch.object(inference, "model", model, create=True), patch.object(inference, "processor", processor, create=True):
            for size, cap in ((1024, 2048), (None, 1024)):
                request["max_new_tokens"] = cap
                request["input_token_limit"] = 12288
                if size is None:
                    request.pop("prefill_chunk_size", None)
                else:
                    request["prefill_chunk_size"] = size
                response = inference._colab_complete(json.dumps(request))
                self.assertEqual(model.generate.call_args.kwargs["prefill_chunk_size"], size)
                self.assertEqual(response["prefill_chunk_size"], size)
                self.assertEqual(model.generate.call_args.kwargs["max_new_tokens"], cap)
                self.assertEqual(response["max_new_tokens"], cap)
                self.assertEqual(response["input_token_limit"], 12288)

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
