# 8. Red Hat AI Inference Server on OpenShift

<p align="center">
<a href="/docs/07-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>

### Objectives

- Name **[Red Hat AI Inference Server](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index)** as a **separate** product path from OpenShift AI **single-model / KServe** (`InferenceService`, `ServingRuntime`).
- Map the **official OpenShift deployment guide** to a short checklist: operators → secrets and storage → workload → network.

### Rationale

- Topics **0–7** focus on **OpenShift AI** and **`InferenceService`**. Some teams instead run the **RHAIS container image** on plain OpenShift with standard objects (**`Deployment`**, **`Service`**, **`Route`**). The names sound similar; the APIs are not the same.

### Takeaways

- The linked **3.2** guide assumes a cluster with **supported accelerators** and (for that topology) **full internet access**; it starts with **Node Feature Discovery** and the **NVIDIA or AMD GPU Operator** before any model pod runs.
- **Chapter 5** walks through **Secrets** (for example registry pull config and optional Hugging Face token), a **PVC** for model cache, a **`Deployment`** (often an **initContainer** to stage weights, then the **vLLM** process from the RHAIS image), a **`Service`**, and an optional **`Route`** for HTTPS access.
- Verification in the product doc uses the **OpenAI-compatible** HTTP API (for example **`/v1/chat/completions`**) against the route host—same *style* of client check as [Topic 5](/docs/05-generative-inference-workbench.md), different control plane.

## Prerequisites (usually facilitator / cluster admin)

- [ ] **Chapters 2–4** of the guide: **NFD** and the **GPU operator** that matches your hardware are installed and healthy (see verification `oc get pods` in each chapter).
- [ ] A **project namespace** reserved for the inference stack (the doc uses an example such as **`rhaiis-namespace`**; align with your org’s naming).

## Deployment shape (Chapter 5, condensed)

Work through the guide in order; do not copy YAML blindly—**storage class**, **image digest**, and **resource** blocks must match your cluster and entitlement.

1. **Secrets** — registry credentials for **`registry.redhat.io`**; the guide also creates a **Hugging Face** token **Secret** when that flow applies—use only what matches your install variant.
2. **PVC** — cache volume for model files (access mode and size per your storage class).
3. **`Deployment`** — **initContainer** (the current example uses **ORAS** to pull a **Granite** artifact from **`registry.redhat.io`** into the PVC) + main container running **`python -m vllm.entrypoints.openai.api_server`** from the **RHAIS** image; **GPU** `limits`/`requests` and **`/dev/shm`** as documented.
4. **`Service`** — front the **vLLM** **port** (example in doc: target **8000**).
5. **`Route`** (optional) — expose the **Service** for clients outside the cluster.

Official procedure and examples: [Chapter 5. Deploying Red Hat AI Inference Server and inference serving the model](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html/deploying_red_hat_ai_inference_server_in_openshift_container_platform/deploying-inference-serving-the-model_install).

## Hands-on exercise (~10–15 min)

- [ ] Open the **single-page** guide and skim **Chapters 1–5**: note what is **cluster-wide** (operators) versus **namespace-scoped** (Secrets, PVC, `Deployment`, `Service`, `Route`).
- [ ] In **Chapter 5**, list the **Kubernetes kinds** in the order the doc creates them (at least five types).
- [ ] (Optional) If your facilitator provides a **demo namespace** with a completed install, run `oc get deployment,svc,route -n <namespace>` and **`GET`** **`/v1/models`** (or **`/v1/chat/completions`**) against the route with **`curl`** as in the doc’s verification section.

<p align="center">
<a href="/docs/07-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
