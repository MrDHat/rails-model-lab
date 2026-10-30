# Qwen compiler repair and host transport validation

The CPU-only compatibility check reproduced the exact FlashInfer header failure from the previous graph-startup attempt. The original image combines CUDA 13.4 compiler/runtime-compiler headers with CUDA 13.0 runtime headers. FlashInfer's bundled compatibility header compares compiler major/minor against the runtime header version and rejects that mismatch. This narrows the cause beyond the earlier missing-compiler-path issue.

A separate derived image pins the compiler, compiler runtime headers and NVVM components to 13.0.88, using SHA-256 wheel hashes from NVIDIA's PyPI distributions. The existing runtime remains 13.0.96. The same CPU compatibility check then passed, and the packaged source and requirement hashes matched. The original image and failed outcomes remain unchanged. One preceding CPU inspection also failed during import because of a local-path assumption; that failure is retained separately and was followed by a disclosed corrected CPU attempt. None of these checks requested a GPU.

The first aligned-image probe stopped at its CPU gate without requesting a GPU. The trivial CUDA kernel and compatibility header passed, and all three actual FlashInfer sampling source objects compiled. Linking then failed because the wheel places its runtime under `lib/`, while FlashInfer searched `lib64/`, and the CPU container has no NVIDIA driver. This is a retained setup failure, with no graph/eager measurements and no model-file hash recomputation because the model stage was never reached. Frozen source hashes and the exact app's stopped/zero-task state were verified.

A disclosed separate corrected attempt now compiles the trivial kernel, compatibility header and exactly three sampling objects on CPU; it defers driver linking/loading to the actual GPU environment. It supplies linker names for the installed runtime library and requires the real GPU driver library before engine startup. It does not synthesize a driver or disable compatibility checks. Compilation on CPU does not prove linking, loading or graph startup works. Results of this new attempt are pending; all previous outcomes stay separate.

Source/model checks, one-GPU maximum, independent remote/local shutdown bounds, partial outcome retention and direct completion delivery remain in place. No scored benchmark tasks or training are part of these probes, and benchmark limits and generation settings remain unchanged.

## Host adapter check

A separate synthetic integration passed using the unmodified upstream host-side Miniswen adapter with a fake loopback provider and an ephemeral Docker sandbox. It completed two tool calls, replayed the command observation, verified the sandbox marker and provider authentication, and found no provider environment variables in task commands or published ports. Docker cleanup was verified afterward. This validates the host agent/tool/loopback path without a GPU; it does not establish real Qwen inference through that path or its behavior on benchmark tasks.

The fake provider reports 200 input and 20 output tokens. The upstream local-provider accounting classifies those synthetic calls at zero token cost; that is not an estimate of hosted GPU cost. No benchmark scores or leaderboard position follow from these transport checks.

## Reproducing the CPU/compiler check

Use the existing private inference image as a base and derive another image with the hash-pinned compiler requirements. Install with `python -m pip install --no-deps --require-hashes -r experiments/qwen-cuda-compiler-requirements.txt` inside that derived image; do not modify the original. Run `python experiments/check-qwen-cuda-toolchain.py` there before any GPU work. The script targets the CUDA/FlashInfer installation layout in this project; it is not a general CUDA installer.

For the host transport fixture, supply a suitable cached Docker image through `SYNTHETIC_IMAGE` and run `BUNDLE_GEMFILE=experiments/leaderboard.Gemfile bundle exec ruby experiments/test-host-modal-transport.rb`.

Official wheel metadata: [compiler](https://pypi.org/project/nvidia-cuda-nvcc/13.0.88/), [compiler runtime headers](https://pypi.org/project/nvidia-cuda-crt/13.0.88/), [NVVM](https://pypi.org/project/nvidia-nvvm/13.0.88/). Private image/app identifiers, raw diagnostics and detailed operational evidence remain local. Free credits only, the existing workspace usage ceiling and zero paid spending remain required.
