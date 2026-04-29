# 8. Red Hat AI Inference Server on OpenShift

<p align="center">
<a href="/docs/07-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>

### Objectives

- Contrast OpenShift AI single-model serving (`InferenceService` / KServe, Topics 3–6) with Red Hat AI Inference Server deployed as a normal OpenShift `Deployment` using the product container image.
- Free the GPU by stopping the workshop KServe model before starting this stack.
- Apply manifests under [`configs/samples/rhaiis-deploy/`](/configs/samples/rhaiis-deploy/), expose an HTTPS `Route` with edge TLS, and run an OpenAI-compatible smoke test with the correct served model id.

### Rationale

Topics 3–6 use the OpenShift AI control plane and `InferenceService` objects. [Red Hat AI Inference Server](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html-single/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index) is also shipped as container images on `registry.redhat.io`.

### Official reference

- [Deploying Red Hat AI Inference Server in OpenShift Container Platform 3.2](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html-single/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index) — Node Feature Discovery, NVIDIA or AMD GPU Operator, then deployment and inference (Chapters 2–5).

> Run commands from the repository root unless noted otherwise.

## Prerequisites

- [ ] You can log in with `oc`, project `kserve-workshop` exists, and you have used or understand the Granite sample and `registry.redhat.io` pulls.
- [ ] Project `rhaii-namespace` exists for Topic 8 (for example `oc new-project rhaii-namespace`, or apply `configs/samples/rhaiis-deploy/namespace.yaml`).
- [ ] GPU node and NVIDIA GPU Operator (or AMD stack per the guide) — on OpenShift AI workshop clusters this is usually already satisfied; on a minimal OCP cluster, install NFD and the appropriate GPU Operator per Chapters 2–4 before the lab below.
- [ ] Cluster default `StorageClass` (or edit the PVC manifest to set one explicitly).

## Step 1 — Stop the KServe model and free the GPU


If you deployed the Granite `InferenceService` from [Topic 4](/docs/04-yaml-and-cli.md), its predictor holds `nvidia.com/gpu` until those pods terminate. Do this first so the Red Hat AI Inference Server pod can schedule.

- [ ] Delete the `InferenceService` (removes the predictor `Deployment` and frees the accelerator):

```sh
oc delete inferenceservice granite-3-1-8b-instruct -n kserve-workshop
```

- [ ] Wait until no predictor pods remain:

```sh
oc get pods -n kserve-workshop
```

You should not see a `granite-3-1-8b-instruct-predictor-…` pod in Running state.

## Step 2 — Registry pull secret (`docker-secret`)

The vLLM image and the ORAS init container both pull from `registry.redhat.io`. Create a secret named `docker-secret` in `rhaii-namespace`. The sample `Deployment` expects type `kubernetes.io/dockerconfigjson` with data key `.dockerconfigjson` (projected as `config.json` under `DOCKER_CONFIG=/auth` for ORAS, and used in `imagePullSecrets`).

### Copy the cluster pull secret (workshops, no personal password)

Use this when you have rights to read `openshift-config/pull-secret` (usually `cluster-admin`). That secret is created at install and normally includes `registry.redhat.io`.

- [ ] Confirm the source secret exists:

```sh
oc get secret pull-secret -n openshift-config
```

- [ ] Copy it into `rhaii-namespace` as `docker-secret` (replace/remove any old secret first):

```sh
oc delete secret docker-secret -n rhaii-namespace --ignore-not-found
TMP=$(mktemp)
oc get secret pull-secret -n openshift-config -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d > "$TMP"
oc create secret generic docker-secret \
  --from-file=.dockerconfigjson="$TMP" \
  --type=kubernetes.io/dockerconfigjson \
  -n rhaii-namespace
rm -f "$TMP"
```

- [ ] Verify type:

```sh
oc get secret docker-secret -n rhaii-namespace -o jsonpath='{.type}{"\n"}'
```

Expected: `kubernetes.io/dockerconfigjson`.

## Step 3 — Storage and workload manifests

- [ ] Apply in order. The `Route` in [`route-granite.yaml`](/configs/samples/rhaiis-deploy/route-granite.yaml) sets `spec.tls` with `termination: edge` and `insecureEdgeTerminationPolicy: Redirect`.

```sh
oc apply -f configs/samples/rhaiis-deploy/namespace.yaml
oc apply -f configs/samples/rhaiis-deploy/pvc-model-cache.yaml
oc apply -f configs/samples/rhaiis-deploy/deployment-granite.yaml
oc apply -f configs/samples/rhaiis-deploy/service-granite.yaml
oc apply -f configs/samples/rhaiis-deploy/route-granite.yaml
```

- [ ] Watch until the pod is ready (model pull on first run can take several minutes):

```sh
oc get pods -n rhaii-namespace -l app=granite-rhaiis -w
```

Press Ctrl+C when the pod shows `Running` and `READY` `1/1`.

## Step 4 — Confirm the Route and host

- [ ] Confirm the route exists and has a host (and TLS in `spec` if you inspect YAML):

```sh
oc get route granite-rhaiis -n rhaii-namespace
```

- [ ] Optional: print the hostname only:

```sh
oc get route granite-rhaiis -n rhaii-namespace -o jsonpath='{.spec.host}{"\n"}'
```

Use this host only with the `https://` scheme in clients. Do not use a different model id in JSON than the deployment: the OpenAI `model` field must match `--served-model-name` in the manifest (`granite-3-1-8b-instruct-quantized-w8a8`).

## Step 5 — Smoke test (`POST /v1/chat/completions`)

From the repository root (or any shell where `oc` points at the cluster), set `HOST` to the route hostname and call the API over HTTPS:

```sh
HOST=$(oc get route granite-rhaiis -n rhaii-namespace -o jsonpath='{.spec.host}')
curl -sS -X POST "https://${HOST}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "granite-3-1-8b-instruct-quantized-w8a8",
    "messages": [{"role": "user", "content": "What is AI?"}],
    "temperature": 0.1
  }'
```

Optional quick listing of served models:

```sh
curl -sS "https://${HOST}/v1/models"
```



## Hands-on checklist (~20–30 min)

- [ ] Stopped the KServe `InferenceService` in `kserve-workshop` and confirmed predictor pods are gone (GPU free).
- [ ] Created `docker-secret` in `rhaii-namespace`, applied `rhaiis-deploy/` manifests in order, reached Ready for `granite-rhaiis`.
- [ ] Applied the `Route` with edge TLS; used `https://` and model id `granite-3-1-8b-instruct-quantized-w8a8` in `POST /v1/chat/completions`.

<p align="center">
<a href="/docs/07-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
