# Qwen Colab inference smoke test

On 19 October 2026, the unchanged Qwen3.5-4B checkpoint loaded and generated
text successfully in the existing Colab scratchpad. This is a hardware and
inference check, not a coding evaluation, benchmark score, or training run.

## Recorded runtime and generation

| Setting | Observed value |
| --- | --- |
| Model | Qwen/Qwen3.5-4B |
| Revision | 851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a |
| GPU | Tesla T4, 15360 MiB |
| Python | 3.13.15 |
| torch | 2.11.0+cu130 |
| transformers | 5.20.1 |
| accelerate | 1.15.0 |
| huggingface_hub | 1.33.0 |
| Precision | torch.float16 |
| Attention implementation | eager |
| Device map | Entire model on GPU 0 |
| Sampling / thinking | Both disabled |
| Output tokens / limit | 192 / 192 |
| Generation time | 15.24 seconds |
| Peak allocated GPU memory during generation | 8.53 GiB |

The prompt was independently written and contained no evaluation-task material:

> In Rails, how do includes and joins differ when loading associated records?
> Give a concise explanation and one short example of each.

The response reached the token limit and ended mid-heading. It described
`includes` as eager loading and `joins` as a SQL join without loading associated
objects. It also made a questionable claim that `.load` or `.pluck` is required
to access data after a join. We have not scored response quality, and this
truncated answer is not evidence of coding-task success.

Transformers reported reference PyTorch fallbacks for causal convolution and
gated delta-rule operations because `causal_conv1d` and
`flash-linear-attention` were absent. The smoke test succeeded without installing
these optional kernels. No optimized-kernel speed claim is made.

## Preservation and next step

The browser displayed completed output directly. The model-load output iframe
did not render readable details, so load duration is not recorded. The scratchpad
displayed “Cannot save changes”; a notebook download attempt returned no file.
The runnable equivalent is preserved in `experiments/qwen-colab-smoke.py`.
That script additionally writes a JSON evidence file and records load time;
those additions have not yet been executed on Colab. Set its `REVISION` to the
hash above when reproducing this run. Its default resolves the current revision
and records it for a new run.

Next: connect this unchanged checkpoint to miniswen and run one expense-claim
development attempt, with agent settings and limits recorded. The model receives
only the starter app and instruction; hidden grader, reference patch, and design
remain outside its workspace. This smoke test does not establish that the agent
integration or its tool calling works.
