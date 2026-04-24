# 1. Overview of the single-model serving platform and model storage

<p align="center">
<a href="/docs/00-setup.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/02-preparing-and-storing-models.md">Next</a>
</p>

### Objectives

- Explain how **KServe** inference server fits large or resource-heavy models.
- Compare storage and serving options so participants can choose appropriately in their environment.

### Rationale

- Serving architecture and storage choices directly affect startup time, operability, and cost. Aligning terminology with the product docs avoids confusion during dashboard and YAML labs.

### Takeaways

- One model instance maps to a dedicated serving path on this platform; storage can be **URI/S3**, **OCI**, or **PVC**.
- **OCI model images (model cars)** reduce duplication and can improve startup compared to repeatedly syncing large files to PVCs.

## Core concepts

**KServe Model Serving**  
Each deployed model gets its own serving deployment. This pattern suits predictive and large language models that need isolation and predictable resources. Details and diagrams are in Red Hat’s guide: [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.2/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

**Other approaches (context only)**  
- **Distributed inference** (for example **llm-d** where available): scaled-out LLM inference across multiple pods.  
- **NVIDIA NIM**: optimized inference microservices; OpenShift AI supported deployments.

**Model storage**

| Approach | Typical use |
|----------|-------------|
| **S3 / HTTP(S) URI** | Central object store; good for shared artifacts and automation. |
| **OCI image** | Pack model weights and layout into a model car image; pre-fetch and less disk churn on the node |
| **PVC** | Simple upload from a workbench; good for smaller artifacts or teams without a registry workflow. |

## Hands-on (~10 min)

- [ ] In OpenShift AI: **Projects** → **`kserve-workshop`** → **Deployments** → start **Deploy model** 
- [ ] Walk through the first screen: model **location** and **type** (predictive vs generative) without submitting.
- [ ] Discuss where each storage type appears and when OCI is preferable for **large** models.

## Exercise (participants, ~5 min)

- [ ] Open the deploy platform and identify: storage source fields, runtime selection (auto vs manual), and hardware profile (if shown).

<p align="center">
<a href="/docs/00-setup.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/02-preparing-and-storing-models.md">Next</a>
</p>
