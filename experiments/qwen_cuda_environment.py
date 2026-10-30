"""CUDA wheel discovery used by the validated synthetic inference environment."""
import hashlib
import os
from pathlib import Path
import sysconfig

def configure_cuda(require_driver=False, source_path=__file__):
    import subprocess
    root = Path(sysconfig.get_paths()["purelib"]) / "nvidia/cu13"
    nvcc = root / "bin/nvcc"
    if not nvcc.is_file():
        raise RuntimeError("Expected wheel-provided CUDA compiler missing")
    os.environ["CUDA_HOME"] = str(root)
    os.environ["PATH"] = str(root / "bin") + os.pathsep + os.environ["PATH"]
    os.environ["MAX_JOBS"] = "2"
    # CUDA wheels use lib/, while FlashInfer searches CUDA_HOME/lib64/.
    # Supply linker names from real installed libraries, never a fake driver.
    runtime = root / "lib/libcudart.so.13"
    if not runtime.is_file():
        raise RuntimeError("Installed CUDA runtime library missing")
    link_dir = root / "lib64"
    link_dir.mkdir(exist_ok=True)
    runtime_link = link_dir / "libcudart.so"
    if not runtime_link.exists():
        runtime_link.symlink_to(runtime)
    driver = next((path for directory in ["/usr/lib/x86_64-linux-gnu", "/usr/local/nvidia/lib64", "/usr/lib64", "/usr/local/nvidia/lib"]
                   for path in [Path(directory) / "libcuda.so.1"] if path.is_file()), None)
    if require_driver and driver is None:
        raise RuntimeError("Real GPU driver library missing; engine not started")
    if driver is not None and not (link_dir / "libcuda.so").exists():
        (link_dir / "libcuda.so").symlink_to(driver.resolve())
    for variable in ["LIBRARY_PATH", "LD_LIBRARY_PATH"]:
        os.environ[variable] = str(link_dir) + os.pathsep + str(runtime.parent) + os.pathsep + os.environ.get(variable, "")
    return {"nvcc_version": subprocess.check_output([str(nvcc), "--version"], text=True),
            "runtime_library_found": True, "real_driver_found": driver is not None,
            "source_sha256": hashlib.sha256(Path(source_path).read_bytes()).hexdigest()}
