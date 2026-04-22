# 5. Advanced configuration, verification, and monitoring

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-troubleshooting-best-practices.md">Next</a>
</p>

### Objectives

- Tune **requests/limits**, **accelerators**, and runtime **arguments** for your model class.
- Verify readiness and exercise the **inference endpoint** with authentication when enabled.
- Locate **metrics** in the dashboard and optionally in OpenShift monitoring.

### Rationale

- Production readiness requires more than a green checkbox: you must confirm **latency**, **errors**, and **utilization** under load.

### Takeaways

- GPU requests use extended resources (for example `nvidia.com/gpu: "1"`).  
- Token auth and routes follow OpenShift patterns; see the same documentation chapter for integrated security options.  
- User workload monitoring (if enabled) unlocks PromQL in the console for deeper analysis.

## Resources and accelerators

- **CPU / memory** — Set requests and limits compatible with your **hardware profile** and quota. Undersized memory is a common cause of OOM on large models.  
- **GPUs** — Ensure **NFD** and **GPU Operator** are healthy; nodes are labeled/tainted per your cluster design. Match **ServingRuntime** to vendor (NVIDIA, AMD, Intel Gaudi, and so on).  
- **Hardware profiles** — Dashboard profiles should align with runtimes; mismatches surface as scheduling failures.

## Advanced runtime options

- **Environment variables** and **container args** — Used for chat templates, batch size, precision, and backend-specific flags. Consult your runtime’s documentation and Red Hat’s model deployment guide.  
- **Probes** — KServe sets sensible defaults; override only with good reason.  
- **Routes and auth** — External route exposure and **token** or **service account** auth as described in product docs.

## Verification

- [ ] **Dashboard** — Deployment shows Ready; copy URL.  
- [ ] **CLI** — `oc get inferenceservice -n kserve-workshop` shows **URL** and **conditions**.  
- [ ] **Inference** — `curl` or a small script against the predict or OpenAI-compatible path (for example `/v1/chat/completions` for compatible generative stacks), passing **Bearer** token if required.

Example (adjust host, path, and body to your runtime):

```sh
curl -k https://<route-host>/<optional-prefix>/v1/models \
  -H "Authorization: Bearer $(oc whoami -t)"
```

## Monitoring

- [ ] OpenShift AI **dashboard** metrics: request rate, latency, utilization (exact widgets depend on version).  
- [ ] **OpenShift console** → **Observe** — If **User Workload Monitoring** is enabled, run PromQL for your serving pods and routes.

## Hands-on (~15–25 min)

- [ ] Edit your deployment to add or change **GPU** or **memory** limits (within quota).  
- [ ] Roll out and confirm pods reschedule cleanly.  
- [ ] Run a **smoke inference** and record HTTP status and latency.  
- [ ] Open monitoring views and identify one metric you would alert on in production.

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-troubleshooting-best-practices.md">Next</a>
</p>
