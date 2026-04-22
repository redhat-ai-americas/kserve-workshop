# 3. Deploying models via the dashboard platform

<p align="center">
<a href="/docs/02-preparing-and-storing-models.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/04-yaml-and-cli.md">Next</a>
</p>

### Objectives

- Complete a **Deploy model** flow end-to-end using the OpenShift AI dashboard.
- For **model location**, pick the same kind of storage as in [Topic 2](/docs/02-preparing-and-storing-models.md): **Quay / OCI image** or **PVC**, and wire the correct **connection**.
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

## Platform flow

Typical stages (after **Deploy model**):

1. **Model details** — **Location** and **connection** (registry vs PVC)—see [Model details: connection and path](#model-details-connection-and-path). Also **type** (predictive vs generative).  
2. **Model deployment** — Display name, **hardware profile**, CPU/memory (and GPU if applicable), **ServingRuntime** (auto or pick from list).  
3. **Advanced** — Optional **AI asset** endpoint registration, **external route**, **token authentication**, **environment variables** and **arguments** (for example vLLM flags), **deployment strategy** (**RollingUpdate** vs **Recreate**).

## Model details: connection and path

Use the **same track** you followed in [Topic 2](/docs/02-preparing-and-storing-models.md). Labels in the UI vary by version; look for **model location**, **data source**, or **where your model is stored**, then **connection** (or **data connection**) for pull credentials or PVC selection.

### Track A — OCI image on Quay (Topic 2 optional track)

You pushed an image with Podman and recorded **`oci://quay.io/<org>/<repo>:<tag>`**.

1. **Model type:** choose **Predictive** (not generative) when asked.  
2. **Location / format:** pick the option for a **model in a container image** / **OCI** / **registry image** (not “HTTP URL only” for this lab).  
3. **Image URI:** enter **`oci://quay.io/<org>/<repo>:<tag>`** exactly as in Topic 2.  
4. **Connection:** select or create a **data connection** to **Quay** (`quay.io`) so the serving workload can **pull** the image. Use credentials the cluster is allowed to use (robot account, token, or the same access you used for `podman push`, as policy allows).  
   - If nothing is listed, add a connection from the project (often **Data connections** → **Add data connection** → **OCI compatible registry** / **Docker registry**) with registry URL **`https://quay.io`** (or your org’s Quay hostname) and username/password or token.  
   - **OpenShift integrated registry** instead of Quay: same idea—OCI URI and a connection that can pull from that registry.

### Track B — PVC / existing cluster storage (Topic 2 default)

You placed **`mobilenetv2-7.onnx`** on the workbench PVC and recorded **PVC name** + **relative path**.

1. **Model type:** **Predictive**; **ONNX** if the form asks for format.  
2. **Location:** choose **existing cluster storage** / **PVC** / **storage on the cluster** (not the Quay/OCI path for this track).  
3. **Connection / storage:** select the **PVC** attached to your workbench—the name you noted in Topic 2 (you can confirm under the project’s **Cluster storage** tab).  
4. **Path:** enter the path **relative to the volume root** served to the model container, e.g. **`models/mobilenetv2-7.onnx`** (matching the file under `/opt/app-root/src/` in the workbench).  

> **Do not** point at a random empty PVC: it must be the volume where you copied the ONNX file in Topic 2, or the deploy will not find the artifact.

After this screen, both tracks continue to **Model deployment** (hardware, runtime) and **Advanced** the same way.

## Runtime selection

For the **MobileNet** stored in [Topic 2](/docs/02-preparing-and-storing-models.md), you must choose a **predictive** / **ONNX**-capable runtime. In this workshop we will use **OpenVINO**.

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
- [ ] **Model details:** follow **Track A** or **Track B** under [Model details: connection and path](#model-details-connection-and-path) so your **connection** matches Topic 2 (Quay/OCI **or** PVC) and your URI or file path is correct.  
- [ ] Select appropriate **hardware** and **runtime** (auto unless you need manual).  
- [ ] Optionally register an **AI asset** if your organization uses the model registry integration.  
- [ ] Deploy and wait until the **Deployments** (or model list) shows **Ready**.  
- [ ] Copy the **inference URL** or route for Topic 5.

<p align="center">
<a href="/docs/02-preparing-and-storing-models.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/04-yaml-and-cli.md">Next</a>
</p>
