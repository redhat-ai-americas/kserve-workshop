# 7. Troubleshooting and best practices

<p align="center">
<a href="/docs/06-advanced-deployment.md">Prev</a>
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
- **Model storage** is a product-supported choice (**S3-compatible storage, URI, OCI image, or PVC** via project connections)—match it to governance and pipeline, not a one-line default.  
- **RollingUpdate** and **GPU** workloads need enough **quota and schedulable capacity** for surge semantics; add **monitoring** for errors and latency as you harden for production.

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
# Predictor Deployment is usually <InferenceService-name>-predictor; adjust -c if your pod template uses another container name.
oc logs deployment/<inferenceservice-name>-predictor -n kserve-workshop --tail=200 -c kserve-container
oc describe inferenceservice <name> -n kserve-workshop
```

**Note:** **Events** in Kubernetes are **short-lived**; `oc get events` can be empty even when a rollout recently succeeded—rely on **`oc describe`**, **pod logs**, and **`InferenceService` conditions** when events have already aged out.

## Operational checklist (with product references)

Use the documentation version that matches your cluster (this workshop links **OpenShift AI Self-Managed 3.4** as an example). The points below summarize **documented product behavior** and **standard OpenShift concerns**—they are a presentation aid, not a replacement for [Red Hat support](https://access.redhat.com/support) or your internal runbooks.

- **Pick model storage deliberately.** Red Hat documents **S3-compatible storage, a URI, an OCI image, or a PVC** (with a project connection) as ways to supply a model. For **OCI** (“modelcars” in KServe), the product documentation states it can help **reduce repeated downloads, reduce local disk use, and use pre-fetched images**—benefits still depend on your registry, network, and how you version images. See [*Deploying models*](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index) (Chapter 1 *Storing models*) and [Deploying a model stored in an OCI image by using the CLI](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/deploying_models/deploying_models#deploying-model-stored-in-oci-image_rhoai-user).
- **Plan registry authentication for private OCI models.** For a private OCI repository, the OpenShift AI documentation directs you to configure **image pull secrets** (including on the `InferenceService` when required). See the same *Deploying models* guide and [Using image pull secrets](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/images/managing-images#using-image-pull-secrets) in OpenShift Container Platform documentation.
- **Validate after every material change.** Re-check **`InferenceService` conditions** and run a **small inference smoke test** after edits to runtime args, resources, or storage—this matches the verification mindset in the product deployment procedures; **CI automation** is your organization’s quality bar, not a statement unique to OpenShift AI.
- **Size quotas before aggressive rollouts.** Rolling updates that need **temporary extra pods**, **GPU**, or **large images** can hit **namespace or cluster `ResourceQuota`** and scheduling limits. Review [Using quotas and limit ranges](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/scalability_and_performance/compute-resource-quotas) in OpenShift Container Platform documentation alongside your GPU and registry capacity.
- **Keep an operations record for repeatability.** Track approved **`ServingRuntime` names**, **hardware profile** name and namespace (for example `opendatahub.io/hardware-profile-*` annotations), **image references** and **mirroring** rules for `registry.redhat.io` or a private registry, and who may change **`spec.containers[].args`**. Anchor day-to-day work to [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

## Optional exercise (~15–20 min)

- [ ] Apply an `InferenceService` with a **wrong** `hardware profile` name or invalid **runtime** name.  
- [ ] Capture the **condition** message and **event** that explains the failure.  
- [ ] Fix the manifest and confirm **Ready**.

<p align="center">
<a href="/docs/06-advanced-deployment.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
