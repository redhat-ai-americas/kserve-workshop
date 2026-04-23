# 4. Deploying models via YAML and `oc` (advanced control)

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-generative-inference-workbench.md">Next</a>
</p>

### Objectives

- Deploy an `InferenceService` with **`oc apply`** for repeatable GitOps-style workflows.
- Apply a **`HardwareProfile`** when the sample references one by name, so annotations resolve to concrete resources.
- Reference **ServingRuntime** names available on the cluster and handle **private OCI** registries.

### Rationale

- Dashboard deployments are convenient; YAML is how you integrate **private images**, **custom args**, and **CI/CD**.
- The Granite **sample** `InferenceService` sets **`opendatahub.io/hardware-profile-name: nvidia-gpu`**. OpenShift AI uses **`HardwareProfile`** objects (in **`redhat-ods-applications`**) to turn that name into **CPU, memory, accelerator**, and **scheduling** defaults. If **`nvidia-gpu`** is missing, the controller has no authoritative sizing for that annotation—apply the workshop profile **before** the `InferenceService`, or reuse a profile your admins already installed.

## Hardware profile (step 1 for the full sample)

The file [`configs/samples/hardware-profile/hardware-profile.yaml`](/configs/samples/hardware-profile/hardware-profile.yaml) defines **`HardwareProfile/nvidia-gpu`** in **`redhat-ods-applications`**, matching the `opendatahub.io/hardware-profile-*` annotations on [`configs/samples/model-deploy/inferenceservice.yaml`](/configs/samples/model-deploy/inferenceservice.yaml). **Cluster admin** or equivalent RBAC is usually required; facilitators often apply it **once** per environment. If **`nvidia-gpu`** already exists, skip the **first** `oc apply` in the ordered block below.

## Full sample stack for oc apply -f

Files under **`configs/samples/model-deploy/`** are plain Kubernetes YAML (no Helm, no Argo CD). They deploy a **GPU vLLM** stack with a **Red Hat Granite** model image (`registry.redhat.io`). Model objects use **`kserve-workshop`** ([Topic 0](/docs/00-setup.md)).

Apply **in this order**—hardware profile first (when needed), then `ServingRuntime` before the `InferenceService` that references it:

```sh
oc apply -f configs/samples/hardware-profile/hardware-profile.yaml
oc apply -f configs/samples/model-deploy/vllm-servingruntime.yaml
oc apply -f configs/samples/model-deploy/model-sa-token.yaml
oc apply -f configs/samples/model-deploy/inferenceservice.yaml
```

Use the **ordered** commands above on first deploy; applying only **`model-deploy/`** can create the `InferenceService` before its `ServingRuntime` exists. **Skip** the hardware-profile line if you lack RBAC or the profile is already present.

The bundled [`inferenceservice.yaml`](/configs/samples/model-deploy/inferenceservice.yaml) already sets **`storageUri`** to an **`oci://`** Granite model image on **`registry.redhat.io`**—there is no separate sample manifest outside **`model-deploy/`**.

- [ ] **Hardware profile:** applied or **`nvidia-gpu`** already present in **`redhat-ods-applications`**.  
- [ ] For **private** `registry.redhat.io` pulls, use cluster pull secrets or add `opendatahub.io/connections` on the `InferenceService` per [Private OCI registry](#private-oci-registry) and Red Hat docs.  
- [ ] `model-sa-token.yaml` is optional client RBAC; skip it if you only need the deployed endpoint.

```sh
oc get servingruntime -n kserve-workshop
oc get inferenceservice -n kserve-workshop
```

## Private OCI registry

- [ ] Create a **pull secret** in **`kserve-workshop`** for the registry.  
- [ ] Attach it to the **default** service account (or the service account your `InferenceService` uses per documentation):

```sh
oc project kserve-workshop
oc secrets link default <pull-secret-name> --for=pull
```

- [ ] Re-apply the `InferenceService` and verify the predictor pod pulls successfully (`oc get pods`, `oc describe pod`).

## Hands-on exercise (~20–30 min)

- [ ] Deploy using YAML: follow the ordered **`oc apply -f`** steps in [Full sample stack for oc apply -f](#full-sample-stack-for-oc-apply--f), including [Hardware profile](#hardware-profile-step-1-for-the-full-sample) when **`nvidia-gpu`** is not already installed (GPU / cluster support required).  
- [ ] Confirm **READY** condition and capture the **URL** from status (you will use it in [Topic 5](/docs/05-generative-inference-workbench.md)).  
- [ ] (Optional) Add a deliberate mistake (wrong runtime name), observe failure, fix, re-apply.

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-generative-inference-workbench.md">Next</a>
</p>
