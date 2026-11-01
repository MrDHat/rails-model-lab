"""Loopback proxy in front of vLLM: applies the frozen sampling settings to
every chat completion and keeps each request/response pair as evidence.

    python3 baseline/settings-proxy.py EVIDENCE_DIR [LISTEN_PORT] [VLLM_PORT|modal]

With "modal", completions go to the deployed baseline/modal_qwen.py app instead.
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import sys
import time
import urllib.error
import urllib.request
import uuid

# Same values as runs/staged-baseline-preparation-20261030/prepared.json.
SETTINGS = {"temperature": 0.6, "top_p": 0.95, "top_k": 20, "seed": 42,
            "presence_penalty": 0, "repetition_penalty": 1.0,
            "chat_template_kwargs": {"enable_thinking": True}, "max_tokens": 32768}
MODEL = "Qwen/Qwen3.5-4B"
TIMEOUT = 1560


def modal_forwarder():
    import modal
    qwen = modal.Cls.from_name("rails-qwen", "Qwen")()

    def forward(path, payload):
        if not path.endswith("/chat/completions"):
            return 404, json.dumps({"error": {"message": f"{path} is not served"}}).encode()
        answer = qwen.complete.remote(payload)
        return answer["status"], answer["body"].encode()
    return forward


def http_forwarder(upstream):
    def forward(path, payload):
        request = urllib.request.Request(upstream + path, json.dumps(payload).encode(),
                                         {"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
                return response.status, response.read()
        except urllib.error.HTTPError as error:
            return error.code, error.read()
    return forward


def main(evidence, port=8001, upstream_port="8000"):
    evidence = Path(evidence)
    evidence.mkdir(parents=True, exist_ok=True)
    upstream = f"http://127.0.0.1:{upstream_port}"
    forward = modal_forwarder() if upstream_port == "modal" else http_forwarder(upstream)

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_):
            pass

        def reply(self, status, body):
            data = body if isinstance(body, bytes) else json.dumps(body).encode()
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_GET(self):
            if upstream_port == "modal":
                return self.reply(200, {"object": "list", "data": [{"id": MODEL, "object": "model"}]})
            try:
                with urllib.request.urlopen(upstream + self.path, timeout=30) as response:
                    self.reply(response.status, response.read())
            except urllib.error.HTTPError as error:
                self.reply(error.code, error.read())
            except OSError as error:
                self.reply(502, {"error": {"message": str(error)}})

        def do_POST(self):
            identity = f"{time.strftime('%Y%m%dT%H%M%S')}-{uuid.uuid4().hex[:8]}"
            try:
                payload = json.loads(self.rfile.read(int(self.headers.get("Content-Length", "0"))))
                if self.path.endswith("/chat/completions"):
                    payload.update(SETTINGS, model=MODEL)
                (evidence / f"{identity}.request.json").write_text(json.dumps(payload))
                started = time.time()
                status, body = forward(self.path, payload)
            except Exception as error:  # Network/timeout errors reach the agent as a 502.
                status, body = 502, json.dumps({"error": {"message": str(error)}}).encode()
                started = time.time()
            (evidence / f"{identity}.response.json").write_text(json.dumps(
                {"status": status, "elapsed_seconds": round(time.time() - started, 3),
                 "body": body.decode(errors="replace")}))
            self.reply(status, body)

    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()


if __name__ == "__main__":
    main(sys.argv[1], *(int(a) if a.isdigit() and i == 0 else a for i, a in enumerate(sys.argv[2:4])))
