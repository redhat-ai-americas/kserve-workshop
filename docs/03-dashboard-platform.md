# 3. Deploying models via the dashboard platform

<p align="center">
<a href="/docs/02-preparing-and-storing-models.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/04-yaml-and-cli.md">Next</a>
</p>

### Objectives

- Complete a **Deploy model** flow end-to-end using the OpenShift AI dashboard.
- Choose **runtime** (automatic or manual), **hardware profile**, and **deployment strategy** deliberately.

### Rationale

- The platform is the fastest path for data scientists. Understanding each step maps directly to the YAML fields you will edit in [Topic 4](/docs/04-yaml-and-cli.md).

### Takeaways

- **Auto runtime** matches hardware and model format when possible; use **manual** when multiple runtimes apply or when admins require a specific stack.
- **RollingUpdate** favors availability when enough resources exist; **Recreate** can succeed on tighter quotas but causes brief downtime.

## Platform flow (check against current UI)

Follow the official doc section for labels in your release: [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

Typical stages:

1. **Model details** — Name, **location** (URI, OCI, PVC), **type** (predictive vs generative).  
2. **Model deployment** — Display name, **hardware profile**, CPU/memory (and GPU if applicable), **ServingRuntime** (auto or pick from list).  
3. **Advanced** — Optional **AI asset** endpoint registration, **external route**, **token authentication**, **environment variables** and **arguments** (for example vLLM flags), **deployment strategy** (**RollingUpdate** vs **Recreate**).

## Runtime selection

For the **MobileNet ONNX** sample from [Topic 2](/docs/02-preparing-and-storing-models.md), choose a **predictive** / **ONNX**-capable runtime (often **OpenVINO / OVMS**, for example a `ServingRuntime` named like `kserve-ovms` on CPU).

- **Automatic** — Platform picks a runtime consistent with format and accelerator (for example GPU + generative → vLLM variant on many clusters).  
- **Manual** — Use when you must pin OpenVINO, Caikit, or a custom `ServingRuntime`.  
- **Admin defaults** — Some clusters set defaults for distributed or specialized stacks; if behavior surprises you, check cluster `ServingRuntime` and `InferenceService` defaults with your platform team.

## Deployment strategies

| Strategy | Behavior | When to use |
|----------|-----------|-------------|
| **RollingUpdate** | New revision before old terminates | Enough quota/headroom; **zero-downtime** goal |
| **Recreate** | Tear down then start | Tight resources; acceptable downtime |

Some distributed or llm-d related defaults prefer **Recreate**; confirm in your environment.

## Hands-on exercise (~25–35 min)

- [ ] Deploy the **MobileNet** artifact you prepared in [Topic 2](/docs/02-preparing-and-storing-models.md) (PVC **or** `oci://` image).  
- [ ] Select appropriate **hardware** and **runtime** (auto unless you need manual).  
- [ ] Optionally register an **AI asset** if your organization uses the model registry integration.  
- [ ] Deploy and wait until the **Deployments** (or model list) shows **Ready**.  
- [ ] Copy the **inference URL** or route for Topic 5.

<p align="center">
<a href="/docs/02-preparing-and-storing-models.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/04-yaml-and-cli.md">Next</a>
</p>
