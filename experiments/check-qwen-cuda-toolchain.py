"""CPU-only compiler/header diagnostic inside the existing inference image.

Run before any future graph probe. This does not request a GPU or repair packages.
Passing this check does not establish engine startup or graph execution.
"""
import json
import os
from pathlib import Path
import subprocess
import sysconfig
import tempfile


def main():
    packages = Path(sysconfig.get_paths()["purelib"])
    cuda = packages / "nvidia/cu13"
    nvcc = cuda / "bin/nvcc"
    headers = packages / "flashinfer/data/cccl/libcudacxx/include"
    if not nvcc.is_file() or not (headers / "cuda/std/__cccl/cuda_toolkit.h").is_file():
        raise RuntimeError("Expected compiler or FlashInfer toolkit compatibility header missing")
    env = dict(os.environ, CUDA_HOME=str(cuda))
    env["PATH"] = str(cuda / "bin") + os.pathsep + env["PATH"]
    with tempfile.TemporaryDirectory(prefix="synthetic-cuda-headers-") as work:
        source = Path(work) / "check.cu"
        source.write_text('#include <cuda/std/__cccl/cuda_toolkit.h>\n'
                          '__global__ void synthetic_check(float* x) { x[0] = 1.0f; }\n')
        result = subprocess.run([str(nvcc), "-arch=sm_86", "-I", str(headers),
                                 "-cubin", str(source), "-o", str(Path(work) / "check.cubin")],
                                env=env, capture_output=True, text=True, timeout=45)
    print(json.dumps({"gpu_requested": False, "compiler_headers_compatible": result.returncode == 0,
                      "returncode": result.returncode, "stdout": result.stdout, "stderr": result.stderr}))
    raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
