"""Compile FlashInfer's actual sampling objects on CPU, without driver linking.

The GPU stage must still link/load them against its real NVIDIA driver. This
check deliberately does not claim that a CPU container has a GPU driver.
"""
import json
import re
import subprocess
from flashinfer.jit.sampling import gen_sampling_module

spec = gen_sampling_module()
spec.write_ninja()
targets = re.findall(r"^build (.+?\.o):", spec.ninja_path.read_text(), re.MULTILINE)
if len(targets) != 3:
    raise RuntimeError("Expected exactly three FlashInfer sampling object targets")
subprocess.run(["ninja", "-v", "-C", str(spec.build_dir), "-f", str(spec.ninja_path),
                "-j", "2", *targets], check=True, timeout=165)
print(json.dumps({"gpu_requested": False, "sampling_source_objects_compiled": len(targets),
                  "driver_linking_tested": False, "module_loading_tested": False}))
