# 6. vLLM arguments, verification, and monitoring

<p align="center">
<a href="/docs/05-generative-inference-workbench.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/07-troubleshooting-best-practices.md">Next</a>
</p>

### Objectives

- Add **standard vLLM server arguments** to the running deployment using the **OpenShift AI** UI.  
- Re-verify **readiness** and a short **inference** smoke test after the change.  
- Locate **metrics** for the deployment in the dashboard and optionally in **OpenShift Observe**.

### Rationale

- **vLLM** behavior (context length, memory use, dtype) is controlled mainly by **process arguments**. Tuning them in the GUI before exporting to YAML is how many teams iterate.

### Takeaways

- Common flags include **`--max-model-len`**, **`--gpu-memory-utilization`**, **`--dtype`**, and **`--max-num-seqs`**; mismatches to GPU memory show up as OOM or slow first token.  
- After any change, confirm **conditions**, **events**, and one **HTTP** call before declaring success.

## Tune vLLM arguments in the OpenShift AI UI

These steps assume a **single-model** deployment already exists (for example **Granite** from [Topic 4](/docs/04-yaml-and-cli.md)). Exact labels vary by OpenShift AI version; look for **model deployment**, **edit**, **advanced**, or **runtime arguments** / **container arguments**.

1. Open **OpenShift AI** → project **`kserve-workshop`**.  
2. Open **Deployments** (or **Models** / **Model deployments**) and select **`granite-3-1-8b-instruct`**.  
3. Use **Edit** / **Configure** (or the action menu) to open settings where **container arguments**, **extra arguments**, or **vLLM** options appear.  
4. Add or adjust a small set of **standard** arguments (examples below). **Save** and allow a new revision to roll out.

Suggested examples (pick what your cluster memory allows; do not copy blindly):

| Argument | Role |
|----------|------|
| `--max-model-len 8192` | Cap context + KV cache footprint. |
| `--gpu-memory-utilization 0.90` | Fraction of GPU memory vLLM may use. |
| `--dtype auto` | Let vLLM pick precision (or `bfloat16` if your stack recommends it). |
| `--max-num-seqs 256` | Concurrent sequences limit (tune with latency goals). |

> If the UI only exposes **environment variables**, consult your version’s docs for the supported mapping to **vLLM**; some installs use a single **arguments** text field with space-separated tokens.

- [ ] After save, wait until the deployment shows **Ready** (or the new revision is healthy).

## Verification

- [ ] **Dashboard** — Deployment **Ready**; copy the inference **URL** if it changed.  
- [ ] **CLI** — `oc get inferenceservice granite-3-1-8b-instruct -n kserve-workshop` and `oc describe inferenceservice granite-3-1-8b-instruct -n kserve-workshop` for **conditions** and **events**.  
- [ ] **Inference** — Repeat a quick call from [Topic 5](/docs/05-generative-inference-workbench.md) (notebook or `curl` to **`/v1/models`** / **`/v1/chat/completions`**) with the same **Bearer** token.

## Monitoring

- [ ] OpenShift AI **dashboard** metrics for the deployment: request rate, latency, utilization (widgets depend on version).  
- [ ] **OpenShift console** → **Observe** — If **User Workload Monitoring** is enabled, explore metrics for the predictor **Pods** and **Routes**.

## Hands-on (~15–25 min)

- [ ] Change at least one **vLLM** argument (for example lower **`--max-model-len`**), roll out, and confirm the pod restarts cleanly.  
- [ ] Run one **smoke inference** and note latency versus before (informal comparison is enough).  
- [ ] Open one **metrics** view and name one signal you would alert on in production.

<p align="center">
<a href="/docs/05-generative-inference-workbench.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/07-troubleshooting-best-practices.md">Next</a>
</p>
