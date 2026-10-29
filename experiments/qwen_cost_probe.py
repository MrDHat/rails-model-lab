"""Bounded synthetic engine probe. No benchmark, grader, training or endpoint.

Uses the existing private preflight image; only this source file is added.
Run with the existing Modal client environment. Local results go to a new run.
"""
import hashlib
import json
import os
from pathlib import Path
import signal
import time
import modal

MODEL = 'Qwen/Qwen3.5-4B'
REVISION = '851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a'
ROOT = Path(__file__).resolve().parents[1] / 'runs/qwen-cost-probe-20261029'
image = modal.Image.from_id('im-gB2tqSC2KhUzGQ7X4dp6q4').add_local_file(__file__, '/root/qwen_cost_probe.py')
app = modal.App('rails-qwen-cost-probe', include_source=False)


@app.function(image=image, gpu='A10', cpu=(2, 2), memory=(16384, 16384),
              max_containers=1, scaledown_window=2, timeout=900,
              startup_timeout=90, retries=0)
def probe(expected_hashes):
    import concurrent.futures
    import subprocess
    import threading
    import requests
    from transformers import AutoTokenizer

    started = time.monotonic()
    deadline = started + 840
    report = {'model': MODEL, 'revision': REVISION, 'gpu': 'A10',
              'vllm': '0.32.0', 'dtype': 'bfloat16', 'context': 262144,
              'synthetic_only': True, 'engine_only_not_harness_concurrency': True,
              'max_sequences': 4, 'cases': [], 'errors': [], 'timeout_seconds': 840,
              'source_sha256': hashlib.sha256(Path('/root/qwen_cost_probe.py').read_bytes()).hexdigest()}
    holder = {}
    expired = threading.Event()

    def stop_engine():
        proc = holder.get('process')
        if proc and proc.poll() is None:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    def hard_stop():
        expired.set()
        stop_engine()

    timer = threading.Timer(840, hard_stop)
    timer.daemon = True
    timer.start()
    model_path = Path('/model-path').read_text()
    report['model_hashes'] = json.loads(Path('/model-manifest.json').read_text())
    if report['model_hashes'] != expected_hashes:
        raise RuntimeError('Original model manifest mismatch before inference')
    for name, expected in expected_hashes.items():
        with (Path(model_path)/name).open('rb') as stream:
            if hashlib.file_digest(stream, 'sha256').hexdigest() != expected:
                raise RuntimeError('Model file hash mismatch: ' + name)
    report['hardware'] = subprocess.check_output(['nvidia-smi', '--query-gpu=name,memory.total', '--format=csv,noheader'], text=True).strip()
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    source = '\n'.join(f'def synthetic_method_{i}(value): return value + {i}' for i in range(5000))
    context = tokenizer.decode(tokenizer.encode(source)[:8192])
    settings = {'temperature': 0.6, 'top_p': 0.95, 'top_k': 20,
                'presence_penalty': 0, 'repetition_penalty': 1.0,
                'chat_template_kwargs': {'enable_thinking': True}, 'seed': 42}

    def complete(messages, **kwargs):
        before = time.monotonic()
        response = requests.post('http://127.0.0.1:8000/v1/chat/completions',
            json={'model': MODEL, 'messages': messages, **settings, **kwargs},
            timeout=(5, min(120, max(1, deadline-time.monotonic()))))
        response.raise_for_status()
        value = response.json()
        return value, time.monotonic()-before

    try:
        for mode in ['eager', 'cuda_graphs']:
            if deadline-time.monotonic() < 180:
                report['errors'].append({'mode': mode, 'error': 'Insufficient remaining probe allowance; not started'})
                break
            args = ['vllm', 'serve', model_path, '--served-model-name', MODEL,
                    '--host', '127.0.0.1', '--port', '8000', '--dtype', 'bfloat16',
                    '--max-model-len', '262144', '--max-num-seqs', '4',
                    '--gpu-memory-utilization', '0.85', '--language-model-only',
                    '--enable-auto-tool-choice', '--tool-call-parser', 'qwen3_coder',
                    '--reasoning-parser', 'qwen3', '--enable-prefix-caching',
                    '--generation-config', 'vllm', '--no-enable-log-requests']
            if mode == 'eager':
                args.append('--enforce-eager')
            log_path = Path('/tmp') / (mode + '-engine.log')
            boot = time.monotonic()
            with log_path.open('w') as log:
                proc = subprocess.Popen(args, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            holder['process'] = proc
            try:
                ready = False
                while time.monotonic() < min(deadline, boot+240) and proc.poll() is None:
                    try:
                        if requests.get('http://127.0.0.1:8000/health', timeout=2).ok:
                            ready = True
                            break
                    except requests.RequestException:
                        pass
                    time.sleep(1)
                if not ready:
                    raise RuntimeError('Engine readiness failed')
                print(json.dumps({'event': 'ready', 'mode': mode, 'startup_seconds': time.monotonic()-boot}), flush=True)
                tools = [{'type': 'function', 'function': {'name': 'bash', 'description': 'Execute shell',
                          'parameters': {'type': 'object', 'properties': {'command': {'type': 'string'}}, 'required': ['command']}}}]
                value, latency = complete([{'role': 'user', 'content': "Use bash to execute exactly: printf 'cost-probe-check\\n'"}], tools=tools, max_tokens=2048)
                calls = value['choices'][0]['message'].get('tool_calls') or []
                tool_ok = (len(calls) == 1 and calls[0]['function']['name'] == 'bash'
                           and json.loads(calls[0]['function']['arguments']).get('command') == "printf 'cost-probe-check\\n'")
                if not tool_ok:
                    raise RuntimeError('Synthetic tool parsing gate failed')
                report.setdefault('startup', []).append({'mode': mode, 'seconds': time.monotonic()-boot, 'tool_gate_seconds': latency, 'tool_gate': True})
                for concurrency in [1, 2, 4]:
                    if deadline-time.monotonic() < 90 or expired.is_set():
                        raise TimeoutError('Remaining independent allowance exhausted')
                    def one(index):
                        messages = [{'role': 'user', 'content': f'Unique synthetic probe {mode}/{concurrency}/{index}.\n{context}\nWrite a detailed explanation of these synthetic functions.'}]
                        # Force a fixed diagnostic workload, not a new benchmark output budget.
                        value, latency = complete(messages, max_tokens=512, min_tokens=512, ignore_eos=True)
                        usage = value['usage']
                        if usage['completion_tokens'] != 512:
                            raise RuntimeError('Fixed diagnostic length not produced')
                        return {'index': index, 'seconds': latency, 'usage': usage, 'finish_reason': value['choices'][0]['finish_reason']}
                    before = time.monotonic()
                    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
                        rows = list(pool.map(one, range(4)))
                    wall = time.monotonic()-before
                    case = {'mode': mode, 'concurrency': concurrency, 'requests': rows,
                            'wall_seconds': wall, 'output_tokens_per_second': 2048/wall,
                            'compute_usd_at_resource_rate': wall*1.323792/3600}
                    report['cases'].append(case)
                    print(json.dumps({'event': 'case', 'mode': mode, 'concurrency': concurrency, 'output_tokens_per_second': 2048/wall, 'wall_seconds': wall}), flush=True)
            except Exception as error:
                report['errors'].append({'mode': mode, 'error': str(error), 'engine_log_tail': log_path.read_text()[-12000:]})
            finally:
                stop_engine()
                proc.wait(timeout=10)
            if expired.is_set():
                break
        report['status'] = 'complete' if len(report['cases']) == 6 else 'partial_or_failed'
        return report
    finally:
        stop_engine()
        timer.cancel()
        report['remote_elapsed_seconds'] = time.monotonic()-started
        report['compute_usd_at_resource_rate'] = report['remote_elapsed_seconds']*1.323792/3600


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    if (ROOT/'app.json').exists():
        raise RuntimeError('Existing probe app record: never silently rerun')
    def expire(*_):
        raise TimeoutError('Independent local 1200-second deadline')
    signal.signal(signal.SIGALRM, expire)
    signal.alarm(1200)
    event = {'status': 'failed', 'synthetic_only': True}
    try:
        with app.run():
            (ROOT/'app.json').write_text(json.dumps({'app_id': app.app_id, 'started_at': time.time(), 'local_deadline_seconds': 1200}, indent=2)+'\n')
            expected = json.loads((ROOT.parent/'full-baseline-20261026/remote-metadata.json').read_text())['hashes']
            result = probe.remote(expected)
            if result['model_hashes'] != expected:
                raise RuntimeError('Original model manifest mismatch')
            (ROOT/'result.json').write_text(json.dumps(result, indent=2)+'\n')
            event.update(status=result['status'], model_hashes_verified=True)
    except Exception as error:
        event['error'] = str(error)
        raise
    finally:
        signal.alarm(0)
        event['finished_at'] = time.time()
        (ROOT/'event.json').write_text(json.dumps(event, indent=2)+'\n')
        # One direct completion callback; no scheduled or in-context polling.
        import subprocess
        message = f'The user-authorized synthetic Qwen cost probe finished. Read {ROOT}/event.json and result.json if present, verify its exact Modal app stopped, and report measured batching/CUDA graph throughput and limitations. No scored benchmark tasks may launch automatically. Preserve $0 paid spending and existing budget controls.'
        delivery = subprocess.run(['/Users/mrdhat/.local/bin/codex', 'queue', '--thread', '01a1554b-223c-7101-8c1f-3cc3339322c9', '--message', message], capture_output=True, text=True, timeout=30)
        (ROOT/'delivery.json').write_text(json.dumps({'returncode': delivery.returncode, 'stdout': delivery.stdout, 'stderr': delivery.stderr}, indent=2)+'\n')


if __name__ == '__main__':
    main()
