# 5. Generative inference from a workbench

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-advanced-verification-monitoring.md">Next</a>
</p>

### Objectives

- Call the **OpenAI-compatible** HTTP API exposed by the **vLLM** deployment (for example **Granite** from [Topic 4](/docs/04-yaml-and-cli.md)).
- Retrieve a **Bearer token** from the workshop **service account** secret in the OpenShift console.
- Run the pre-built notebook **`extras/notebooks/generative-inference.ipynb`** in an OpenShift AI **workbench**.

### Rationale

- Data scientists usually validate models from a **notebook** or script, not only from `curl` on a laptop. The same **route** and **token** flow you use here is what automation and client apps repeat.

### Takeaways

- With **token authentication** enabled on the deployment, every API call needs **`Authorization: Bearer <token>`**.  
- The token for **`granite-3-1-8b-instruct-sa`** is stored in a **Secret** of the same name (created in [Topic 4](/docs/04-yaml-and-cli.md) when you applied `model-sa-token.yaml`).  
- The bundled notebook keeps **URL** and **token** in one place so you can iterate on prompts without retyping headers.

## Prerequisites

- [ ] **`kserve-workshop`** project with the **Granite** stack from Topic 4 (**`InferenceService` `granite-3-1-8b-instruct`**) **Ready**, with **external route** and **token authentication** enabled (as in the sample manifests).  
- [ ] A **workbench** running in **`kserve-workshop`** (create one under **Workbenches** if you do not already have it from [Topic 2](/docs/02-preparing-and-storing-models.md)).

## 1. Copy the inference route

- [ ] In **OpenShift AI** → **`kserve-workshop`** → **Deployments** (or **Models** / **Model deployments**, depending on version), open **`granite-3-1-8b-instruct`** and copy the **inference URL** / **API URL** (HTTPS).  
- [ ] Or from the terminal: `oc get inferenceservice granite-3-1-8b-instruct -n kserve-workshop -o wide` and use the **URL** shown in status (no trailing slash when you pass it to the notebook).

## 2. Get the Bearer token (OpenShift console)

Use the **service account token** secret the workshop applied for client access.

1. Open the **OpenShift** web console (not only OpenShift AI).  
2. Switch to the **`kserve-workshop`** namespace (project).  
3. Go to **Workloads** → **Secrets**.  
4. Open the secret named **`granite-3-1-8b-instruct-sa`** (type **kubernetes.io/service-account-token**).  
5. Under **Data**, reveal the **`token`** field and copy its value (the UI usually shows the decoded string).  

If the secret is missing, re-apply [Topic 4](/docs/04-yaml-and-cli.md) `model-sa-token.yaml` or ask a facilitator.

**Optional — CLI:**

```sh
oc get secret granite-3-1-8b-instruct-sa -n kserve-workshop -o jsonpath='{.data.token}' | base64 -d
echo
```

## 3. Open the workshop notebook in the workbench

- [ ] In the workbench (**JupyterLab**), open a terminal and clone or update this repo under **`/opt/app-root/src/`** if you do not already have it (same pattern as [Topic 2](/docs/02-preparing-and-storing-models.md)).  
- [ ] In the file browser, open **`extras/notebooks/generative-inference.ipynb`** ([`generative-inference.ipynb`](/extras/notebooks/generative-inference.ipynb) in the repo).  
- [ ] Edit the first code cell: set **`INFERENCE_BASE_URL`** to your route (scheme + host + any path prefix the UI shows) and **`BEARER_TOKEN`** to the token from step 2.  
- [ ] Run all cells: confirm **`/v1/models`** returns **200**, then try **`/v1/chat/completions`** with the sample body.

> **TLS:** If the cluster uses a private CA, the notebook uses `verify=False` for a quick lab; in production, pass a proper CA bundle or use the cluster trust store.

## Hands-on (~20–30 min)

- [ ] Retrieve the token from **Secrets** → **`granite-3-1-8b-instruct-sa`** → **token**.  
- [ ] Run **`generative-inference.ipynb`** end-to-end with a successful chat completion.  
- [ ] Change the user message in the last cell and confirm the model reply updates.

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-advanced-verification-monitoring.md">Next</a>
</p>
