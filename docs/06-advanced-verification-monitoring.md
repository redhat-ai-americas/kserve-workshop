# 6. vLLM arguments, verification, and monitoring

<p align="center">
<a href="/docs/05-generative-inference-workbench.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/07-troubleshooting-best-practices.md">Next</a>
</p>

### Objectives

- Tune **vLLM** by editing the **`ServingRuntime`** YAML you applied in [Topic 4](/docs/04-yaml-and-cli.md), then **`oc apply`** again.  
- Re-verify **readiness** and a short **inference** smoke test after the change.  
- Locate **metrics** for the deployment in the dashboard and optionally in **OpenShift Observe**.

### Rationale

- You already deployed the stack from Git-tracked YAML; changing **`spec.containers[].args`** in the same file keeps **reviews, diffs, and repeatability** aligned with how you introduced the runtime—no one-off GUI drift.

### Takeaways

- **vLLM** reads flags from the container **`args`** list (each YAML `-` item is one **argv** token—pair flags like **`--max-model-len`** and **`"8192"`** on separate lines).  
- Common flags include **`--max-model-len`**, **`--gpu-memory-utilization`**, **`--dtype`**, and **`--max-num-seqs`**; oversizing can cause OOM or slow first token.  
- After **`oc apply`**, watch the **predictor** pods until the new revision is healthy before trusting latency numbers.

## Tune vLLM arguments in YAML

Workshop file: [`configs/samples/model-deploy/vllm-servingruntime.yaml`](/configs/samples/model-deploy/vllm-servingruntime.yaml). The **`granite-3-1-8b-instruct`** `ServingRuntime` sets **`spec.containers[0].args`** for the vLLM process (alongside **`command`**: `python -m vllm.entrypoints.openai.api_server`).

1. **Copy** the file to `scratch/` if you prefer not to edit the repo copy:

   ```sh
   cp configs/samples/model-deploy/vllm-servingruntime.yaml scratch/vllm-servingruntime.yaml
   ```

2. **Edit** `args:` under **`spec.containers`** (same file in-repo or under `scratch/`). The sample already includes a **Topic 6** block with example flags—**change the numbers** to match your GPU memory and latency goals, or **remove** lines you do not want.

| Example args (two YAML entries per flag) | Role |
|------------------------------------------|------|
| `--max-model-len` / `"8192"` | Cap context + KV cache. |
| `--gpu-memory-utilization` / `"0.90"` | GPU memory fraction for vLLM. |
| `--dtype` / `auto` | Precision selection (`bfloat16` if your team standardizes on it). |
| `--max-num-seqs` / `"256"` | Concurrent sequences ceiling. |

3. **Apply** the updated `ServingRuntime`:

   ```sh
   oc apply -f configs/samples/model-deploy/vllm-servingruntime.yaml
   # or: oc apply -f scratch/vllm-servingruntime.yaml
   ```

4. **Wait** for the model deployment to pick up the revision (new **predictor** pod may roll). Watch:

   ```sh
   oc get pods -n kserve-workshop -l serving.kserve.io/inferenceservice=granite-3-1-8b-instruct
   oc get events -n kserve-workshop --sort-by=.lastTimestamp | tail -20
   ```

   If nothing rolls automatically, your operator version may require an **`InferenceService`** nudge (for example delete the predictor **Pod** once so it recreates) — follow your cluster’s guidance; avoid deleting the `InferenceService` unless you intend to.

- [ ] **`oc apply`** succeeds and pods become **Ready** without crash loops.

## Verification

- [ ] **Dashboard** — Deployment **Ready**; inference **URL** unchanged unless the route was recreated.  
- [ ] **CLI** — `oc get inferenceservice granite-3-1-8b-instruct -n kserve-workshop` and `oc describe inferenceservice granite-3-1-8b-instruct -n kserve-workshop` for **conditions** and **events**.  
- [ ] **Inference** — Repeat a quick call from [Topic 5](/docs/05-generative-inference-workbench.md) (notebook or **`/v1/models`** / **`/v1/chat/completions`**) with the same **Bearer** token.

## Monitoring

- [ ] OpenShift AI **dashboard** metrics for the deployment: request rate, latency, utilization (widgets depend on version).  
- [ ] **OpenShift console** → **Observe** — If **User Workload Monitoring** is enabled, explore metrics for the predictor **Pods** and **Routes**.

## Hands-on (~15–25 min)

- [ ] Change at least one **vLLM** argument in **`vllm-servingruntime.yaml`** (for example lower **`--max-model-len`**), **`oc apply`**, and confirm the pod restarts cleanly.  
- [ ] Run one **smoke inference** and note latency versus before (informal comparison is enough).  
- [ ] Open one **metrics** view and name one signal you would alert on in production.

<p align="center">
<a href="/docs/05-generative-inference-workbench.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/07-troubleshooting-best-practices.md">Next</a>
</p>
