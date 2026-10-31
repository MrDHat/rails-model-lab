#!/usr/bin/env python3
"""Offline namespace compatibility probe; no benchmark or inference is executed.

Use existing image tags or digests. Missing images fail rather than downloading.
This probes the namespace command used by lemans 1.5.1, not its full agent jail.
"""
import argparse
import json
import subprocess
import uuid


def check(image):
    inspect = subprocess.run(
        ["docker", "image", "inspect", image, "--format", "{{.Architecture}}"],
        capture_output=True, text=True, timeout=15)
    if inspect.returncode:
        return {"image": image, "passed": False, "reason": "Existing image required"}
    name = "rails-jail-probe-" + uuid.uuid4().hex
    try:
        result = subprocess.run([
            "docker", "run", "--rm", "--name", name, "--pull", "never", "--network", "none",
            "--cap-add", "SYS_ADMIN", "--cap-add", "NET_ADMIN",
            "--security-opt", "apparmor=unconfined", "--entrypoint", "sh", image,
            "-c", 'unshare --version; unshare --net --mount --pid --fork --kill-child '
            '--mount-proc sh -c "echo jail-ready"'],
            capture_output=True, text=True, timeout=30)
    finally:
        # Only this invocation's disposable synthetic container, including timeout.
        subprocess.run(["docker", "rm", "--force", name], capture_output=True, timeout=15)
    return {"image": image, "architecture": inspect.stdout.strip(),
            "passed": result.returncode == 0 and "jail-ready" in result.stdout.splitlines(),
            "returncode": result.returncode, "stdout": result.stdout, "stderr": result.stderr}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("images", nargs="+")
    args = parser.parse_args()
    results = [check(image) for image in args.images]
    print(json.dumps({"passed": all(r["passed"] for r in results), "checks": results}, indent=2))
    raise SystemExit(0 if all(r["passed"] for r in results) else 1)
