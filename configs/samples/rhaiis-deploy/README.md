# Red Hat AI Inference Server sample (Topic 8)

Full lab: [`docs/08-red-hat-ai-inference-server.md`](/docs/08-red-hat-ai-inference-server.md) at the repository root (GPU teardown, `docker-secret`, apply order, HTTPS route, smoke test). This file is a short manifest index only.

Plain `Deployment` + `Service` + `Route` using the Red Hat AI Inference Server vLLM CUDA image and the Chapter 5 ORAS artifact `rhelai1/granite-3-1-8b-instruct-quantized-w8a8:1.5` (not the Topic 4 modelcar). `route-granite.yaml` sets edge TLS on the Route; clients should use `https://` with the route host. Product guide: [Deploying Red Hat AI Inference Server in OpenShift Container Platform](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html-single/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index).

## Before you apply

1. Stop the KServe `InferenceService` and create `docker-secret` — follow `docs/08-red-hat-ai-inference-server.md` (Steps 1–2).
2. PVC storage: edit `pvc-model-cache.yaml` (size and optional `storageClassName`) for your environment.

## Apply order

From the repository root:

```sh
oc apply -f configs/samples/rhaiis-deploy/namespace.yaml
oc apply -f configs/samples/rhaiis-deploy/pvc-model-cache.yaml
oc apply -f configs/samples/rhaiis-deploy/deployment-granite.yaml
oc apply -f configs/samples/rhaiis-deploy/service-granite.yaml
oc apply -f configs/samples/rhaiis-deploy/route-granite.yaml
```

Watch the rollout:

```sh
oc get pods -n rhaii-namespace -l app=granite-rhaiis -w
```

## Smoke test

```sh
HOST=$(oc get route granite-rhaiis -n rhaii-namespace -o jsonpath='{.spec.host}')
curl -sS -X POST "https://${HOST}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "granite-3-1-8b-instruct-quantized-w8a8",
    "messages": [{"role": "user", "content": "Say hello in one sentence."}],
    "temperature": 0.1
  }'
```

## Cleanup

```sh
oc delete -f configs/samples/rhaiis-deploy/route-granite.yaml --ignore-not-found
oc delete -f configs/samples/rhaiis-deploy/service-granite.yaml --ignore-not-found
oc delete -f configs/samples/rhaiis-deploy/deployment-granite.yaml --ignore-not-found
# PVC retains data for a later retry; delete explicitly if you want a clean cache:
# oc delete -f configs/samples/rhaiis-deploy/pvc-model-cache.yaml --ignore-not-found
```
