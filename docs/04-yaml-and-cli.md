# 4. Deploying models via YAML and `oc` (advanced control)

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-advanced-verification-monitoring.md">Next</a>
</p>

### Objectives
- Apply a **`HardwareProfile`** when the sample references one by name, so annotations resolve to concrete resources.
- Deploy an `InferenceService` with **`oc apply`** for repeatable GitOps-style workflows.
- Reference **ServingRuntime** names available on the cluster and handle **private OCI** registries.

### Rationale

- Dashboard deployments are convenient; YAML is how you can start to automate model deployment. 

In Red Hat OpenShift AI, you can use hardware profiles to manage and allocate specific hardware resources, such as hardware accelerators, specialized memory, or CPU-only nodes for data science, machine learning, and generative AI workloads.

Hardware profiles are custom resources (CRs) for targeted scheduling that allow you to specify the exact resources you need for workloads such as workbenches and model serving. You can create your hardware profile in OpenShift AI to specify a particular hardware configuration by going to Settings
Hardware profiles on the OpenShift AI dashboard. 

- The Granite **sample** `InferenceService` sets **`opendatahub.io/hardware-profile-name: nvidia-gpu`**. OpenShift AI uses **`HardwareProfile`** objects to turn that name into **CPU, memory, accelerator**, and **scheduling** defaults. If **`nvidia-gpu`** is missing, the controller has no authoritative sizing for that annotation—apply the workshop profile **before** the `InferenceService`, or reuse a profile your admins already installed.

## Hardware profile (step 1 for the full sample)

The file [`configs/samples/hardware-profile/hardware-profile.yaml`](/configs/samples/hardware-profile/hardware-profile.yaml) defines **`HardwareProfile/nvidia-gpu`** in **`redhat-ods-applications`**, matching the `opendatahub.io/hardware-profile-*` annotations on [`configs/samples/model-deploy/inferenceservice.yaml`](/configs/samples/model-deploy/inferenceservice.yaml).

## Full sample stack for oc apply -f

Files under **`configs/samples/model-deploy/`** are plain Kubernetes YAML (no Helm, no Argo CD). They deploy a **GPU vLLM** stack with a **Red Hat Granite** model image (`registry.redhat.io`). Model objects use **`kserve-workshop`** ([Topic 0](/docs/00-setup.md)).

Apply **in this order**—hardware profile first, then `ServingRuntime` before the `InferenceService` that references it:

```sh
oc apply -f configs/samples/hardware-profile/hardware-profile.yaml
oc apply -f configs/samples/model-deploy/vllm-servingruntime.yaml
oc apply -f configs/samples/model-deploy/model-sa-token.yaml
oc apply -f configs/samples/model-deploy/inferenceservice.yaml
```

Use the **ordered** commands above on first deploy; applying only **`model-deploy/`** can create the `InferenceService` before its `ServingRuntime` exists. If you don't have a hardware profile, then there won't be an available node to schedule your model.

- [ ] **Hardware profile:** applied or **`nvidia-gpu`** already present in **`redhat-ods-applications`**.  
- [ ] For **private** `registry.redhat.io` pulls, use cluster pull secrets or add `opendatahub.io/connections` on the `InferenceService` per [Private OCI registry](#private-oci-registry) and Red Hat docs.  
- [ ] `model-sa-token.yaml` is optional client RBAC; skip it if you only need the deployed endpoint.

```sh
oc get servingruntime -n kserve-workshop
oc get inferenceservice -n kserve-workshop
```



<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-advanced-verification-monitoring.md">Next</a>
</p>
