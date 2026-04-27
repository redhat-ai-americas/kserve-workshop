# 4. Deploying models via YAML and `oc` (advanced control)

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-generative-inference-workbench.md">Next</a>
</p>

### Objectives

- Deploy an `InferenceService` with `oc apply` for repeatable GitOps-style workflows.
- Apply a `HardwareProfile` so you can assign models to specific compute nodes. 
- Reference ServingRuntime names available on the cluster.

### Rationale

- The dashboard is fastest for one-offs; YAML under version control is how teams standardize pulls, resources, and ServingRuntime settings, and promote them through review and automation.
- The model `InferenceService` we will use sets `opendatahub.io/hardware-profile-name: nvidia-gpu`. OpenShift AI uses `HardwareProfile` objects (in `redhat-ods-applications`) to turn that name into CPU, memory, accelerator, and scheduling defaults. If the `HardwareProfile` is missing, the controller won't create the pods because it doesn't see any available resources.

## Hardware profile 

The file [`configs/samples/hardware-profile/hardware-profile.yaml`](/configs/samples/hardware-profile/hardware-profile.yaml) defines `HardwareProfile/nvidia-gpu` in `redhat-ods-applications`, matching the `opendatahub.io/hardware-profile-*` annotations on [`configs/samples/model-deploy/inferenceservice.yaml`](/configs/samples/model-deploy/inferenceservice.yaml). Cluster admin or equivalent RBAC is usually required; facilitators often apply it once per environment.

## Full sample stack for oc apply -f

Files under `configs/samples/model-deploy/` are plain Kubernetes YAML (no Helm, no Argo CD). They deploy a GPU vLLM stack with a Red Hat Granite model image (stored in `registry.redhat.io`). 

Apply in this order—hardware profile first , then `ServingRuntime` before the `InferenceService` that references it:

```sh
oc apply -f configs/samples/hardware-profile/hardware-profile.yaml
oc apply -f configs/samples/model-deploy/vllm-servingruntime.yaml
oc apply -f configs/samples/model-deploy/model-sa-token.yaml
oc apply -f configs/samples/model-deploy/inferenceservice.yaml
```

Use the ordered commands above on first deploy; applying only `model-deploy/` can create the `InferenceService` before its `ServingRuntime` exists.

The [`inferenceservice.yaml`](/configs/samples/model-deploy/inferenceservice.yaml) already sets `storageUri` to an `oci://` Granite model (granite-3-1-8b) image on `registry.redhat.io`.

- [ ] Hardware profile: applied.
- [ ] For private `registry.redhat.io` pulls, use cluster pull secrets or add `opendatahub.io/connections` on the `InferenceService` per [Private OCI registry](#private-oci-registry) and Red Hat docs.  

```sh
oc get servingruntime -n kserve-workshop
oc get inferenceservice -n kserve-workshop
```


## Hands-on exercise (~20–30 min)

- [ ] Deploy using YAML: follow the ordered `oc apply -f` steps in [Full sample stack for oc apply -f](#full-sample-stack-for-oc-apply--f), including [Hardware profile](#hardware-profile-step-1-for-the-full-sample) when `nvidia-gpu` is not already installed (GPU / cluster support required).  
- [ ] Confirm READY condition and capture the URL from status (you will use it in [Topic 5](/docs/05-generative-inference-workbench.md)).  
- [ ] (Optional) Add a deliberate mistake (wrong runtime name), observe failure, fix, re-apply.

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-generative-inference-workbench.md">Next</a>
</p>
