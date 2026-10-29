"""Private loopback bridge for a future concurrent run; never launches Modal.

Each request has separate local evidence. Admission is bounded and immediate:
overload fails rather than silently extending an agent's clock in a queue.
"""
import hmac
import json
import threading
import time
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


def bridge(model, token, evidence, settings, deadline, max_inflight=4):
    if not token or max_inflight < 1:
        raise ValueError("Token and positive concurrency required")
    evidence = Path(evidence)
    evidence.mkdir(parents=True, exist_ok=True)
    slots = threading.BoundedSemaphore(max_inflight)

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def reply(self, status, value):
            body = json.dumps(value).encode()
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_POST(self):
            if not hmac.compare_digest(self.headers.get("Authorization", ""), "Bearer " + token):
                return self.reply(401, {"error": {"message": "Unauthorized"}})
            if self.path != "/v1/chat/completions":
                return self.reply(404, {"error": {"message": "Unknown route"}})
            if time.monotonic() >= deadline:
                return self.reply(503, {"error": {"message": "Runtime allowance exhausted"}})
            if not slots.acquire(blocking=False):
                return self.reply(503, {"error": {"message": "Inference concurrency exhausted; no retry"}})
            identity = uuid.uuid4().hex
            self.connection.settimeout(max(0.1, min(30, deadline - time.monotonic())))
            try:
                length = int(self.headers.get("Content-Length", "0"))
                if not 0 < length <= 16 * 1024 * 1024:
                    return self.reply(413, {"error": {"message": "Invalid payload size"}})
                payload = json.loads(self.rfile.read(length))
                if not isinstance(payload, dict) or payload.get("stream"):
                    raise ValueError("Expected non-streaming completion object")
                if time.monotonic() >= deadline:
                    return self.reply(503, {"error": {"message": "Runtime allowance exhausted"}})
                payload.update(settings)
                (evidence / (identity + ".request.json")).write_text(json.dumps(payload))
                result = model.complete.remote(payload)
                (evidence / (identity + ".response.json")).write_text(json.dumps(result))
                self.reply(200, result["response"])
            except Exception as error:
                (evidence / (identity + ".error.json")).write_text(json.dumps({"error": str(error)}))
                self.reply(502, {"error": {"message": str(error)}})
            finally:
                slots.release()

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server
