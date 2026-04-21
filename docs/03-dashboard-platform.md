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

## Open the Deploy model flow

Deploy into **the same Data Science project** you created in [Topic 0](/docs/00-setup.md) with `oc new-project` (the namespace you use for all lab steps—the project you opened for the overview demo in [Topic 1](/docs/01-overview-and-storage.md)).

1. In the **OpenShift AI** dashboard, go to **Projects**.
2. Select **that project** so you are working inside it (not the cluster-wide list only).
3. Open the **Deployments** tab for the project.
4. Click **Deploy model** to start the flow described in the next section.

> If **Deploy model** is missing, confirm you are inside the correct project, that [Topic 0](/docs/00-setup.md) verification passed, and that single-model serving is enabled for your cluster.

## Platform flow

Typical stages (after **Deploy model**):

1. **Model details** — Name, **location** (URI, OCI, PVC), **type** (predictive vs generative).  
2. **Model deployment** — Display name, **hardware profile**, CPU/memory (and GPU if applicable), **ServingRuntime** (auto or pick from list).  
3. **Advanced** — Optional **AI asset** endpoint registration, **external route**, **token authentication**, **environment variables** and **arguments** (for example vLLM flags), **deployment strategy** (**RollingUpdate** vs **Recreate**).

## Runtime selection

For the **MobileNet ONNX** sample from [Topic 2](/docs/02-preparing-and-storing-models.md), choose a **predictive** / **ONNX**-capable runtime (often **OpenVINO**, for example a `ServingRuntime` named like `kserve-ovms` on CPU).

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

- [ ] In your **Topic 0** project: **Deployments** → **Deploy model** (see [Open the Deploy model flow](#open-the-deploy-model-flow) above).  
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
