# 5. Generative inference from a workbench

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-advanced-deployment.md">Next</a>
</p>

### Objectives

- Call the OpenAI-compatible HTTP API exposed by the vLLM deployment (for example Granite from [Topic 4](/docs/04-yaml-and-cli.md)).
- Retrieve a Bearer token from the service account secret in the OpenShift console.
- Create a dedicated OpenShift AI workbench (minimal Python image, default hardware profile) and run `extras/notebooks/generative-inference.ipynb` there.

### Rationale

- Data scientists usually validate models from a notebook or script, not only from `curl` on a laptop. The same route and token flow you use here is what automation and client apps repeat.
- A separate workbench (its own PVC) avoids ReadWriteOnce conflicts with [Topic 2](/docs/02-preparing-and-storing-models.md) Track B, where the model may be served from the first workbench’s volume while that workbench stays stopped.

### Takeaways

- With token authentication enabled on the deployment, every API call needs `Authorization: Bearer <token>`.  
- The token for `granite-3-1-8b-instruct-sa` is stored in a Secret of the same name (created in [Topic 4](/docs/04-yaml-and-cli.md) when you applied `model-sa-token.yaml`).  
- The bundled notebook keeps URL, token, and `MODEL_NAME` (OpenAI `model` field) in one place—`MODEL_NAME` must match an `id` from `GET /v1/models`. The chat cell parses the response and prints `choices[0].message.content` as the assistant sentence.

## Prerequisites

- [ ] `kserve-workshop` project with the Granite stack from Topic 4 (`InferenceService` `granite-3-1-8b-instruct`) in Ready state, with external route and token authentication enabled (as in the sample manifests).  
- [ ] A separate workbench from [Topic 2](/docs/02-preparing-and-storing-models.md) Track B when that PVC is used for serving—create it in Step 1 below (its own storage; avoids RWO conflicts).

## 1. Create the inference workbench

Use a new workbench only for this topic’s notebook (HTTP client to the model route). Do not reuse the Topic 2 Track B workbench if that volume is still attached to a PVC-based deployment.

1. In OpenShift AI, open project `kserve-workshop`.  
2. Open the Workbenches tab.  
3. Click Create workbench.  
4. Name: e.g. `inference-lab`.  
5. Image: choose the minimal Python / Jupyter image—`Jupyter | Minimal | CPU | Python 3.12`
6. Hardware profile: select  default-profile. This workbench does not need GPUs, only the Granite deployment does.  
7. Cluster storage: Set at the default size
8. Create and wait until the workbench is Running.  
9. Open the workbench to launch the JupyterLab environment.

More detail: [Creating a project workbench](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.2/html/working_on_projects/using-project-workbenches_projects) (match the doc version to your OpenShift AI release).

## 2. Copy the inference route

- [ ] In OpenShift AI → `kserve-workshop` → Deployments, open `granite-3-1-8b-instruct` and copy the external inference endpoint.  
- [ ] Or from the terminal: `oc get inferenceservice granite-3-1-8b-instruct -n kserve-workshop -o wide` and use the URL shown in output.

## 3. Get the Bearer token (OpenShift console)

Use the service account token secret the workshop applied for client access.

1. Open the OpenShift web console (not OpenShift AI).  
2. Go to Workloads → Secrets.  
3. Switch to the `kserve-workshop` namespace (project).  
4. Open the secret named `granite-3-1-8b-instruct-sa` (type kubernetes.io/service-account-token).  
5. Under Data, copy the `token` field value.  

Optional — CLI

```sh
oc extract secret/granite-3-1-8b-instruct-sa -n kserve-workshop --keys=token --to=-
```
## 4. Open the workshop notebook in the workbench

- [ ] In the workbench, open a terminal and clone this repo `https://github.com/redhat-ai-americas/kserve-workshop.git`
- [ ] In the file browser, open `kserve-workshop/extras/notebooks/generative-inference.ipynb` ([`generative-inference.ipynb`](/extras/notebooks/generative-inference.ipynb) in the repo).  
- [ ] Edit the first code cell: set `INFERENCE_BASE_URL`, `BEARER_TOKEN`, and `MODEL_NAME`. The `model` field must match an `id` from `GET /v1/models` (the notebook defaults to `granite-3.1-8b-instruct`)

- [ ] Run all cells: confirm `/v1/models` returns 200, then `/v1/chat/completions` succeeds.

## Hands-on exercise (~15–25 min)

- [ ] Confirm [Prerequisites](#prerequisites): Granite `InferenceService` is Started, the external route works, and you use a separate workbench if Topic 2 Track B still ties the serving PVC to another workbench.
- [ ] Create the inference workbench (per Step 1 above); wait until it is running and JupyterLab opens.
- [ ] Copy the HTTPS inference URL from the deployment or `oc get inferenceservice` (Step 2).
- [ ] Retrieve the `token` from Secret `granite-3-1-8b-instruct-sa` (Step 3)
- [ ] Open `extras/notebooks/generative-inference.ipynb` (Step 4), set `INFERENCE_BASE_URL`, `BEARER_TOKEN`, and `MODEL_NAME` (match an `id` from `GET /v1/models` if chat fails).
- [ ] Run all cells end-to-end: `GET /v1/models` succeeds, then `POST /v1/chat/completions` prints assistant content.

<p align="center">
<a href="/docs/04-yaml-and-cli.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/06-advanced-deployment.md">Next</a>
</p>
