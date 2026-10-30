"""Bounded synthetic graph/context comparison, with no benchmark inputs."""
import hashlib
import json
import os
from pathlib import Path
import signal
import sysconfig
import time
import modal

MODEL = "Qwen/Qwen3.5-4B"
REVISION = "851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a"
source_path = "/root/qwen_graph_context_probe.py"
base_id = os.environ["QWEN_PREFLIGHT_IMAGE_ID"]
image = (modal.Image.from_id(base_id)
         .env({"PYTHONPATH": "/root", "QWEN_PREFLIGHT_IMAGE_ID": base_id})
         .add_local_file(__file__, source_path)
         .add_local_file(str(Path(__file__).with_name("check-qwen-cuda-toolchain.py")),
                         "/root/check-qwen-cuda-toolchain.py"))
app = modal.App("qwen-graph-context-synthetic", include_source=False)
CASES = [(8192, 1, 4), (8192, 4, 4), (32768, 1, 4),
         (32768, 4, 4), (65536, 1, 2), (65536, 2, 2)]


def configure_cuda():
    import subprocess
    root = Path(sysconfig.get_paths()["purelib"]) / "nvidia/cu13"
    nvcc = root / "bin/nvcc"
    if not nvcc.is_file():
        raise RuntimeError("Expected wheel-provided CUDA compiler missing")
    os.environ["CUDA_HOME"] = str(root)
    os.environ["PATH"] = str(root / "bin") + os.pathsep + os.environ["PATH"]
    os.environ["MAX_JOBS"] = "2"
    return {"nvcc_version": subprocess.check_output([str(nvcc), "--version"], text=True),
            "source_sha256": hashlib.sha256(Path(source_path).read_bytes()).hexdigest()}


@app.function(image=image, cpu=(2, 2), memory=(8192, 8192), max_containers=1,
              timeout=240, startup_timeout=60, retries=0, scaledown_window=2)
def compiler_gate():
    import subprocess
    result = configure_cuda()
    path = Path("/tmp/synthetic-compiler-check.cu")
    path.write_text("__global__ void synthetic_check(float* x) { x[0] = 1.0f; }\n")
    subprocess.run(["nvcc", "-arch=sm_86", "-cubin", str(path), "-o", "/tmp/synthetic-check.cubin"],
                   check=True, capture_output=True, text=True, timeout=45)
    result.update(cuda_compile_passed=True, gpu_requested=False)
    compatibility = subprocess.run(["python", "/root/check-qwen-cuda-toolchain.py"],
                                   capture_output=True, text=True, timeout=50)
    result["compatibility"] = {"returncode": compatibility.returncode,
                               "stdout": compatibility.stdout, "stderr": compatibility.stderr}
    if compatibility.returncode:
        return result
    os.environ["FLASHINFER_CUDA_ARCH_LIST"] = "8.6"
    sampling = subprocess.run(["python", "-c",
        "from flashinfer.sampling import get_sampling_module; get_sampling_module(); print('sampling module loaded')"],
        capture_output=True, text=True, timeout=170)
    result["sampling"] = {"returncode": sampling.returncode,
                          "stdout": sampling.stdout, "stderr": sampling.stderr}
    result["flashinfer_sampling_passed"] = sampling.returncode == 0
    return result


@app.function(image=image, gpu="A10", cpu=(2, 2), memory=(16384, 16384),
              max_containers=1, scaledown_window=2, timeout=1200, startup_timeout=90, retries=0)
def measure(expected_hashes):
    import concurrent.futures
    import subprocess
    import threading
    import requests
    from transformers import AutoTokenizer

    started = time.monotonic()
    deadline = started + 1140
    report = {"synthetic_only": True, "model": MODEL, "revision": REVISION,
              "dtype": "bfloat16", "vllm": "0.32.0", "context_limit": 262144,
              "max_sequences": 4, "cases": [], "errors": [], "startup": [],
              "toolchain": configure_cuda(), "watchdog_seconds": 1140,
              "source_sha256": hashlib.sha256(Path(source_path).read_bytes()).hexdigest()}
    holder = {}
    expired = threading.Event()

    def stop_engine():
        process = holder.get("process")
        if process is not None and process.poll() is None:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    def expire():
        expired.set()
        stop_engine()

    timer = threading.Timer(1140, expire)
    timer.daemon = True
    timer.start()
    try:
        model_path = Path("/model-path").read_text()
        manifest = json.loads(Path("/model-manifest.json").read_text())
        assert manifest == expected_hashes, "Original model manifest mismatch"
        for name, expected in manifest.items():
            with (Path(model_path) / name).open("rb") as stream:
                assert hashlib.file_digest(stream, "sha256").hexdigest() == expected, name
        report["model_hashes"] = manifest
        report["hardware"] = subprocess.check_output(["nvidia-smi", "--query-gpu=name,memory.total", "--format=csv,noheader"], text=True).strip()
        tokenizer = AutoTokenizer.from_pretrained(model_path)
        invented = "\n".join(f"def synthetic_method_{i}(value): return value + {i}" for i in range(30000))
        tokens = tokenizer.encode(invented)
        assert len(tokens) >= 65536
        contexts = {n: tokenizer.decode(tokens[:n]) for n in (8192, 32768, 65536)}
        settings = {"temperature": 0.6, "top_p": 0.95, "top_k": 20, "seed": 42,
                    "presence_penalty": 0, "repetition_penalty": 1.0,
                    "chat_template_kwargs": {"enable_thinking": True}}
        report["settings"] = settings

        def complete(messages, **kwargs):
            before = time.monotonic()
            response = requests.post("http://127.0.0.1:8000/v1/chat/completions",
                json={"model": MODEL, "messages": messages, **settings, **kwargs},
                timeout=(5, min(180, max(1, deadline-before))))
            response.raise_for_status()
            return response.json(), time.monotonic()-before

        for mode in ("cuda_graphs", "eager"):
            if deadline-time.monotonic() < 240 or expired.is_set():
                report["errors"].append({"mode": mode, "error": "Allowance insufficient; mode not started"})
                break
            args = ["vllm", "serve", model_path, "--served-model-name", MODEL,
                    "--host", "127.0.0.1", "--port", "8000", "--dtype", "bfloat16",
                    "--max-model-len", "262144", "--max-num-seqs", "4",
                    "--gpu-memory-utilization", "0.85", "--language-model-only",
                    "--enable-auto-tool-choice", "--tool-call-parser", "qwen3_coder",
                    "--reasoning-parser", "qwen3", "--enable-prefix-caching",
                    "--generation-config", "vllm", "--no-enable-log-requests"]
            if mode == "eager":
                args.append("--enforce-eager")
            path = Path(f"/tmp/{mode}.log")
            boot = time.monotonic()
            with path.open("w") as log:
                process = subprocess.Popen(args, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            holder["process"] = process
            try:
                ready = False
                while time.monotonic() < min(boot+360, deadline) and process.poll() is None:
                    try:
                        if requests.get("http://127.0.0.1:8000/health", timeout=2).ok:
                            ready = True
                            break
                    except requests.RequestException:
                        pass
                    time.sleep(1)
                if not ready:
                    raise RuntimeError("Engine readiness failed")
                ready_seconds = time.monotonic()-boot
                tools = [{"type": "function", "function": {"name": "bash", "description": "Execute shell",
                    "parameters": {"type": "object", "properties": {"command": {"type": "string"}}, "required": ["command"]}}}]
                value, latency = complete([{"role": "user", "content": "Use bash to execute exactly: printf 'graph-context-check\\n'"}], tools=tools, max_tokens=2048)
                calls = value["choices"][0]["message"].get("tool_calls") or []
                assert len(calls) == 1 and calls[0]["function"]["name"] == "bash"
                assert json.loads(calls[0]["function"]["arguments"])["command"] == "printf 'graph-context-check\\n'"
                report["startup"].append({"mode": mode, "ready_seconds": ready_seconds,
                                          "tool_gate_seconds": latency, "tool_gate": True})
                for context, concurrency, count in CASES:
                    if deadline-time.monotonic() < 120 or expired.is_set():
                        raise TimeoutError("Remaining allowance insufficient; later cases not started")

                    def one(index):
                        prompt = f"Unique synthetic {mode}/{context}/{concurrency}/{index}.\n{contexts[context]}\nExplain these invented functions."
                        value, latency = complete([{"role": "user", "content": prompt}],
                            max_tokens=128, min_tokens=128, ignore_eos=True)
                        assert value["usage"]["completion_tokens"] == 128
                        return {"index": index, "seconds": latency, "usage": value["usage"],
                                "finish_reason": value["choices"][0]["finish_reason"]}

                    before = time.monotonic()
                    rows = []
                    failures = []
                    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
                        futures = {pool.submit(one, index): index for index in range(count)}
                        for future in concurrent.futures.as_completed(futures):
                            try:
                                rows.append(future.result())
                            except Exception as error:
                                failures.append({"index": futures[future], "error": str(error)})
                    wall = time.monotonic()-before
                    try:
                        metrics = requests.get("http://127.0.0.1:8000/metrics", timeout=5).text
                    except requests.RequestException:
                        metrics = None
                    report["cases"].append({"mode": mode, "synthetic_context_tokens": context,
                        "concurrency": concurrency, "requests": rows, "wall_seconds": wall,
                        "planned_requests": count, "failures": failures,
                        "output_tokens_per_second": len(rows)*128/wall, "metrics_after": metrics})
                    if failures:
                        raise RuntimeError("Synthetic requests failed; partial case retained")
            except Exception as error:
                report["errors"].append({"mode": mode, "error": str(error), "log_tail": path.read_text()[-16000:]})
            finally:
                stop_engine()
                process.wait(timeout=10)
                report.setdefault("engine_logs", {})[mode] = path.read_text()
        report["status"] = "complete" if len(report["cases"]) == 12 and not report["errors"] else "partial_or_failed"
    except Exception as error:
        report["errors"].append({"error": str(error)})
        report["status"] = "failed"
    finally:
        stop_engine()
        timer.cancel()
        report["remote_elapsed_seconds"] = time.monotonic()-started
        report["rate_based_compute_usd"] = report["remote_elapsed_seconds"]*1.323792/3600
    return report
