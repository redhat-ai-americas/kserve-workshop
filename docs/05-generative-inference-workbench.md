# 5. Generative inference from a workbench

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-advanced-deployment.md">Next</a>
</p>

### Objectives

- Call the **OpenAI-compatible** HTTP API exposed by the **vLLM** deployment (for example **Granite** from [Topic 4](/docs/04-yaml-and-cli.md)).
- Retrieve a **Bearer token** from the workshop **service account** secret in the OpenShift console.
- Create a **dedicated** OpenShift AI **workbench** (minimal Python image, default hardware profile) and run **`extras/notebooks/generative-inference.ipynb`** there.

### Rationale

- Data scientists usually validate models from a **notebook** or script, not only from `curl` on a laptop. The same **route** and **token** flow you use here is what automation and client apps repeat.
- A **separate** workbench (its own PVC) avoids **ReadWriteOnce** conflicts with [Topic 2](/docs/02-preparing-and-storing-models.md) **Track B**, where the model may be served from the **first** workbench’s volume while that workbench stays stopped.

### Takeaways

- With **token authentication** enabled on the deployment, every API call needs **`Authorization: Bearer <token>`**.  
- The token for **`granite-3-1-8b-instruct-sa`** is stored in a **Secret** of the same name (created in [Topic 4](/docs/04-yaml-and-cli.md) when you applied `model-sa-token.yaml`).  
- The bundled notebook keeps **URL**, **token**, and **`MODEL_NAME`** (OpenAI **`model`** field) in one place—**`MODEL_NAME`** must match an **`id`** from **`GET /v1/models`**. The chat cell **parses** the response and prints **`choices[0].message.content`** as the assistant sentence.

## Prerequisites

- [ ] **`kserve-workshop`** project with the **Granite** stack from Topic 4 (**`InferenceService` `granite-3-1-8b-instruct`**) **Ready**, with **external route** and **token authentication** enabled (as in the sample manifests).  
- [ ] A **separate** workbench from [Topic 2](/docs/02-preparing-and-storing-models.md) **Track B** when that PVC is used for serving—create it in **Step 1** below (its own storage; avoids RWO conflicts).

## 1. Create the inference workbench

Use a **new** workbench only for this topic’s notebook (HTTP client to the model route). Do **not** reuse the Topic 2 **Track B** workbench if that volume is still attached to a **PVC-based** deployment.

1. In **OpenShift AI**, open project **`kserve-workshop`**.  
2. Open the **Workbenches** tab.  
3. Click **Create workbench** (or **Add workbench** / **Create**).  
4. **Name:** e.g. **`inference-lab`**.  
5. **Image:** choose the **minimal** Python / Jupyter image—**`Jupyter | Minimal | CPU | Python 3.12`** or 
6. **Hardware profile:** select  **default-profile**. This workbench does not need GPUs, only the **Granite** deployment does.  
7. Leave **cluster storage** at the default size unless your admin specifies otherwise, then **Create** and wait until the workbench is **Running**.  
8. Open the workbench to launch **JupyterLab**.

More detail: [Creating a project workbench](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/working_on_projects/using-project-workbenches_projects) (match the doc version to your OpenShift AI release).

## 2. Copy the inference route

- [ ] In **OpenShift AI** → **`kserve-workshop`** → **Deployments** (or **Models** / **Model deployments**, depending on version), open **`granite-3-1-8b-instruct`** and copy the **inference URL** / **API URL** (HTTPS).  
- [ ] Or from the terminal: `oc get inferenceservice granite-3-1-8b-instruct -n kserve-workshop -o wide` and use the **URL** shown in status (no trailing slash when you pass it to the notebook).

## 3. Get the Bearer token (OpenShift console)

Use the **service account token** secret the workshop applied for client access.

1. Open the **OpenShift** web console (not only OpenShift AI).  
2. Switch to the **`kserve-workshop`** namespace (project).  
3. Go to **Workloads** → **Secrets**.  
4. Open the secret named **`granite-3-1-8b-instruct-sa`** (type **kubernetes.io/service-account-token**).  
5. Under **Data**, reveal the **`token`** field and copy its value (the UI usually shows the decoded string).  

**Optional — CLI**

```sh
oc extract secret/granite-3-1-8b-instruct-sa -n kserve-workshop --keys=token --to=-

## 4. Open the workshop notebook in the workbench

- [ ] In the workbench (**JupyterLab**), open a terminal and clone this repo `https://github.com/redhat-ai-americas/kserve-workshop.git`
- [ ] In the file browser, open **`kserve-workshop/extras/notebooks/generative-inference.ipynb`** ([`generative-inference.ipynb`](/extras/notebooks/generative-inference.ipynb) in the repo).  
- [ ] Edit the first code cell: set **`INFERENCE_BASE_URL`**, **`BEARER_TOKEN`**, and **`MODEL_NAME`**. The **`model`** field must match an **`id`** from **`GET /v1/models`** (the notebook defaults to **`granite-3.1-8b-instruct`**

- [ ] Run all cells: confirm **`/v1/models`** returns **200**, then **`/v1/chat/completions`** succeeds.


<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-advanced-deployment.md">Next</a>
</p>
