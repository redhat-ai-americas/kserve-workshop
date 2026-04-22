# 7. Troubleshooting and best practices

<p align="center">
<a href="/docs/06-advanced-verification-monitoring.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>

### Objectives

- Diagnose **common failures** on the single-model serving platform.  
- Leave with a short **production checklist** for large-model deployments.

### Rationale

- Most incidents are **runtime mismatch**, **resources**, **image pull**, or **GPU** configuration — systematic checks save time.

### Takeaways

- Start from **events**, **pod logs**, and **`InferenceService` conditions**, then narrow to the runtime container.  
- Prefer **OCI** for large artifacts, **RollingUpdate** when HA matters and quota allows, and **monitoring** on errors and latency from day one.

## Typical pitfalls

| Symptom | Things to check |
|--------|-----------------|
| Predictor **ImagePullBackOff** | Image name/tag, **pull secrets**, registry firewall, `imagePullPolicy` |
| **CrashLoop** / OOM | Memory **limits**, model size, batch settings |
| **Pending** pod | **GPU** requests vs node capacity, **taints/tolerations**, **ResourceQuota** |
| Wrong backend behavior | **ServingRuntime** vs **model format**, custom **args** |
| Rolling update stuck | Insufficient **extra** capacity for maxUnavailable/maxSurge semantics |

Commands:

```sh
oc get events -n kserve-workshop --sort-by=.lastTimestamp
oc logs deploy/<predictor-deployment> -n kserve-workshop -c <container>
oc describe inferenceservice <name> -n kserve-workshop
```

## Best practices

- **Standardize** on OCI for large models to reduce node disk pressure and speed rollout.  
- **Test** endpoints after every change; automate smoke tests in CI where possible.  
- **Watch quotas** at namespace and cluster scope before enabling **RollingUpdate** on big models.  
- **Document** required runtime names, hardware profiles, and image prefixes for your enterprise registry.

## Optional exercise (~15–20 min)

- [ ] Apply an `InferenceService` with a **wrong** `imagePullSecret` or invalid **runtime** name.  
- [ ] Capture the **condition** message and **event** that explains the failure.  
- [ ] Fix the manifest and confirm **Ready**.

<p align="center">
<a href="/docs/06-advanced-verification-monitoring.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
