# 7. Troubleshooting and best practices

<p align="center">
<a href="/docs/06-advanced-deployment.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>

### Objectives

- Diagnose common failures on the single-model serving platform.  
- Leave with a short production checklist for large-model deployments.

### Rationale

- Most incidents are runtime mismatch, resources, image pull, or GPU configuration — systematic checks save time.

### Takeaways

- Start from `InferenceService` conditions, classify pull vs run vs schedule, then use predictor pod logs for the runtime container.  
- Validate on the route with the same auth production uses (for example bearer token when the dashboard enables it)—not only in-cluster checks.  
- Keep runtime name, model format, resources, and hardware profile aligned with what the platform ships; mismatches are a common source of “wrong backend” or endless rollouts.

## Typical pitfalls

| Symptom | Things to check |
|--------|-----------------|
| Predictor **ImagePullBackOff** | Image name/tag, pull secrets, registry firewall, `imagePullPolicy` |
| **CrashLoop** / OOM | Memory limits, model size, batch settings |
| **Pending** pod | GPU requests vs node capacity, taints/tolerations, ResourceQuota |
| Wrong backend behavior | ServingRuntime vs model format, custom args |
| Rolling update stuck | Insufficient extra capacity for maxUnavailable/maxSurge semantics |

Commands:

```sh
oc logs deployment/<inferenceservice-name>-predictor -n kserve-workshop --tail=200 -c kserve-container
oc describe inferenceservice <name> -n kserve-workshop
```

## Best practices

### When deploying

- **Wire the whole path before you tune.** Data reaches the pod through project connections + `storageUri`, `oci://`, or the path you chose; the predictor process comes from the `ServingRuntime` (image and `args`). A failure in any leg—connection secret, URI, pull auth, or wrong `runtime` name—shows up as pull, mount, or startup errors, not as “model quality” issues.

- **Match the platform naming contract.** `InferenceService` metadata, `spec.predictor.model.runtime`, `modelFormat`, and hardware profile annotations must line up with runtimes and profiles your admins installed. “Almost right” often yields a pod on the wrong stack or never Ready.

- **Size for the serving process, not the checkpoint size alone.** Generative stacks (for example vLLM) need headroom for KV cache, concurrency, and overhead—OOM and CrashLoop are often limits and **`args`**, not mysterious defects.

- **Exercise the same path production uses.** Call the route with the same auth (for example Bearer token when `security.opendatahub.io/enable-auth` is true). In-cluster `curl` to the Service alone misses TLS, DNS, and token problems.

### When troubleshooting

- **Read `InferenceService` status first.** `PredictorReady`, `Ready`, and condition messages separate scheduling and image pull from model load and configuration. That avoids log-diving when the API already states the failure class.

- **Split “can’t pull” from “can’t run.”** ImagePullBackOff → image name/tag, pull secrets, registry reachability, mirrors / ICSP in restricted clusters. CrashLoop / OOM → pod logs, memory limits, vLLM (or runtime) args and model path. Pending → GPU requests, taints/tolerations, quota, node capacity. Treating these as one bucket wastes time.

- **Use predictor pod logs for the runtime container.** The Deployment is what executes; `oc describe inferenceservice` does not always surface every container-level error—tail logs from the revision you are debugging.

- **Do not treat `oc get events` as a durable log.** Events are short-lived. Rely on `describe` and logs when the event stream is empty.

## Optional exercise (~15–20 min)

- [ ] Apply an `InferenceService` with a wrong `hardware profile` name or invalid runtime name.  
- [ ] Capture the condition message and any event or `describe` output that explains the failure (events may already have expired).  
- [ ] Fix the manifest and confirm Ready.

<p align="center">
<a href="/docs/06-advanced-deployment.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
