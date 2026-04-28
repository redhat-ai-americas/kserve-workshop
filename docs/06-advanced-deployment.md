# 6. vLLM arguments, verification, and monitoring

<p align="center">
<a href="/docs/05-generative-inference-workbench.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/07-troubleshooting-best-practices.md">Next</a>
</p>

### Objectives

- Tune vLLM by editing the `ServingRuntime` YAML you applied in [Topic 4](/docs/04-yaml-and-cli.md), then `oc apply` again.  
- Re-verify readiness and a short inference smoke test after the change.  
- Locate metrics for the deployment in the dashboard and optionally in OpenShift Observe.

### Rationale

- You already deployed the stack from Git-tracked YAML; changing `spec.containers[].args` in the same file keeps reviews, diffs, and repeatability aligned with how you introduced the runtime—no one-off GUI drift.

### Takeaways

- vLLM reads flags from the container `args` list.
- Common flags include `--max-model-len`, `--gpu-memory-utilization`, `--dtype`, and `--max-num-seqs`; oversizing can cause OOM or slow first token. You can find all of the available flags on the vLLM documentation: https://docs.vllm.ai/en/stable/configuration/engine_args
- After `oc apply`, watch the predictor pods until the new revision is healthy before trusting latency numbers.

## Tune vLLM arguments in YAML

Workshop file: [`configs/samples/model-deploy/vllm-servingruntime.yaml`](/configs/samples/model-deploy/vllm-servingruntime.yaml). The `granite-3-1-8b-instruct` `ServingRuntime` sets `spec.containers[0].args` for the vLLM process (alongside `command`: `python -m vllm.entrypoints.openai.api_server`).

1. Copy the file to `scratch/` if you prefer not to edit the repo copy (`mkdir -p scratch` first if that directory does not exist yet):

   ```sh
   mkdir -p scratch
   cp configs/samples/model-deploy/vllm-servingruntime.yaml scratch/vllm-servingruntime.yaml
   ```

2. Edit `args:` under `spec.containers` (same file in-repo or under `scratch/`). The sample already includes a Topic 6 block with example flags. Change the numbers to match your GPU memory and latency goals, or remove lines you do not want.


| Example args (two YAML entries per flag) | Role | Conservative / safe | Typical | Aggressive |
|------------------------------------------|------|----------------------|---------|------------|
| `--max-model-len` / `"8192"` | Cap context + KV cache. | `2048` or `4096` (small GPU or large model) | `8192` | `16384`–`32768` or model max when VRAM allows |
| `--gpu-memory-utilization` / `"0.90"` | GPU memory fraction for vLLM. | `0.85`–`0.88` (shared GPU or OOM) | `0.90` | `0.92`–`0.95` only when stable; higher OOM risk |
| `--dtype` / `auto` | Precision selection (`bfloat16` if your team standardizes on it). | `auto` (let vLLM pick) | `bfloat16` on Ampere+ / many AMD | `float16` if BF16 is awkward; avoid `float32` unless you know you need it |
| `--max-num-seqs` / `"256"` | Concurrent sequences ceiling. | `32`–`64` (one busy GPU or tight memory) | `128`–`256` | `512+` only on large GPUs after testing; too high hurts memory and tail latency |

3. Apply the updated `ServingRuntime`:

   ```sh
   oc apply -f configs/samples/model-deploy/vllm-servingruntime.yaml
   # or: oc apply -f scratch/vllm-servingruntime.yaml
   oc rollout restart deployment/granite-3-1-8b-instruct-predictor
   ```

4. Wait for the model deployment to pick up the revision (new predictor pod may roll). Watch:

   ```sh
   oc get pods -n kserve-workshop -l serving.kserve.io/inferenceservice=granite-3-1-8b-instruct
   oc get events -n kserve-workshop --sort-by=.lastTimestamp | tail -20
   ```

- [ ] `oc apply` succeeds and pods become Ready without crash loops.

## Verification

- [ ] Dashboard — Deployment Started
- [ ] CLI — `oc get inferenceservice granite-3-1-8b-instruct -n kserve-workshop` and `oc describe inferenceservice granite-3-1-8b-instruct -n kserve-workshop` for conditions and events. Inspect the new args in the servingruntime `oc describe servingruntime granite-3-1-8b-instruct`
- [ ] Inference — Repeat a quick call from [Topic 5](/docs/05-generative-inference-workbench.md) (notebook or `/v1/models` / `/v1/chat/completions`) with the same Bearer token and inference endpoint.


<p align="center">
<a href="/docs/05-generative-inference-workbench.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/07-troubleshooting-best-practices.md">Next</a>
</p>
