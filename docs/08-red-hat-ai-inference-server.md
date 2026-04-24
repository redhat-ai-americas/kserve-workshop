# 8. Red Hat AI Inference Server on OpenShift

<p align="center">
<a href="/docs/07-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>

### Objectives

- Name [Red Hat AI Inference Server](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index) as a separate product path from OpenShift AI single-model / KServe (`InferenceService`, `ServingRuntime`).
- Deploy Red Hat AI Inference Server on OpenShift.
- Verify the stack with the OpenAI-compatible HTTP API on the Route host.

### Rationale

- Topics 0–7 focus on OpenShift AI and `InferenceService`. Some teams instead run the RHAIS container image on plain OpenShift with standard objects (`Deployment`, `Service`, `Route`). The names sound similar; the APIs are not the same. Under the hood, all generative inference uses the vLLM serving runtime.

### Takeaways

- Cluster admins normally install Node Feature Discovery and the NVIDIA (or AMD) GPU Operator before you create namespace workloads; confirm they are healthy before debugging a stuck pod.
- Model weights land on a PVC (here via an initContainer using ORAS); the main container mounts that volume and `/dev/shm` for vLLM.
- Pin the RHAIS image by digest or tag from the [Red Hat AI Inference Server 3.2 documentation](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index) for your release—do not copy an old digest from a blog or older workshop snapshot.

## Prerequisites

- [ ] OpenShift CLI (`oc`) and a user who can `oc apply` into the target namespace (and create Routes if you expose the service).  
- [ ] NFD and the GPU operator for your hardware are Running (see Step 1).  
- [ ] Pull access to `registry.redhat.io` (pull secret or cluster-wide entitlement).  
- [ ] Edit [`configs/samples/rhaiis-deploy/pvc-model-cache.yaml`](/configs/samples/rhaiis-deploy/pvc-model-cache.yaml) and set `storageClassName` to a class that exists on your cluster (`oc get storageclass`).

Official reference (diagrams, digest updates, and variant procedures): [Deploying Red Hat AI Inference Server in OpenShift Container Platform](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index), Chapter 5.

Workshop manifests (Git-tracked, same order as below): [`configs/samples/rhaiis-deploy/`](/configs/samples/rhaiis-deploy/).

## 1. Confirm Node Feature Discovery and the GPU operator

These steps assume operators are already installed per Chapters 2–4 of the guide. You are only verifying before you spend time on model pods.

1. NFD — controllers should be Ready:

   ```sh
   oc get pods -n openshift-nfd
   ```

2. NVIDIA GPU Operator (skip if you use AMD and the AMD chapter instead):

   ```sh
   oc get pods -n nvidia-gpu-operator
   ```

3. Confirm at least one node advertises `nvidia.com/gpu` (NVIDIA example):

   ```sh
   oc describe node | grep -E 'nvidia.com/gpu|^Name:'
   ```

- [ ] Operator pods are Running / Completed where the guide expects, and GPU capacity is visible on nodes.

## 2. Namespace and project context

The sample YAML uses namespace `rhaiis-namespace`. If you cannot create `Namespace` objects, use `oc new-project rhaiis-namespace` instead of the first line. Otherwise:

```sh
oc apply -f configs/samples/rhaiis-deploy/namespace.yaml
oc project rhaiis-namespace
```

- [ ] `oc project -q` prints `rhaiis-namespace`.

## 3. Image pull secret for `registry.redhat.io`

Create a dockercfg-style secret so the cluster can pull `registry.redhat.io/rhaiis/...` and the init image if needed. Example (from a workstation that can already pull those images):

```sh
oc create secret generic docker-secret \
  --from-file=.dockercfg="${HOME}/.docker/config.json" \
  --type=kubernetes.io/dockercfg \
  -n rhaiis-namespace \
  --dry-run=client -o yaml | oc apply -f -
```

- [ ] `oc get secret docker-secret -n rhaiis-namespace` exists.

## 4. Optional Hugging Face token secret

The guide creates a Secret for `HF_TOKEN` when you pull models from Hugging Face. The bundled `deployment-granite.yaml` stages weights with ORAS from `registry.redhat.io`; create this secret only if your manifest uses HF.

```sh
# Optional — only if your Deployment references hf-secret
export HF_TOKEN='<your_huggingface_token>'
oc create secret generic hf-secret \
  --from-literal=HF_TOKEN="${HF_TOKEN}" \
  -n rhaiis-namespace \
  --dry-run=client -o yaml | oc apply -f -
```

## 5. PVC for model cache

1. Edit [`pvc-model-cache.yaml`](/configs/samples/rhaiis-deploy/pvc-model-cache.yaml): set `storageClassName` (and `storage` if your class requires a different size).

2. Apply:

   ```sh
   oc apply -f configs/samples/rhaiis-deploy/pvc-model-cache.yaml
   ```

- [ ] `oc get pvc model-cache -n rhaiis-namespace` reaches Bound.

## 6. Deployment: initContainer (model) + RHAIS vLLM

1. Edit [`deployment-granite.yaml`](/configs/samples/rhaiis-deploy/deployment-granite.yaml): set `spec.template.spec.containers[0].image` to the current `registry.redhat.io/rhaiis/vllm-cuda-rhel9` digest or tag from Chapter 5 of the product doc. Adjust `resources` if your GPU or policy differs.

2. Apply:

   ```sh
   oc apply -f configs/samples/rhaiis-deploy/deployment-granite.yaml
   ```

3. Watch the rollout:

   ```sh
   oc get deployment -n rhaiis-namespace -w
   ```

   In another terminal, if the pod does not become Ready, inspect events and logs:

   ```sh
   oc describe pod -n rhaiis-namespace -l app=granite
   oc logs -n rhaiis-namespace -l app=granite -c granite --tail=200
   ```

- [ ] `oc get deployment granite -n rhaiis-namespace` shows AVAILABLE `1/1` (or your chosen replica count).

## 7. Service

```sh
oc apply -f configs/samples/rhaiis-deploy/service-granite.yaml
```

- [ ] `oc get svc granite -n rhaiis-namespace` shows a ClusterIP and port 80 → targetPort 8000.

## 8. Route (external HTTPS)

```sh
oc apply -f configs/samples/rhaiis-deploy/route-granite.yaml
```

Resolve the hostname:

```sh
export RHAIS_HOST="$(oc get route granite -n rhaiis-namespace -o jsonpath='{.spec.host}')"
echo "https://${RHAIS_HOST}"
```

## Verification

- [ ] Models — `curl` (use `https://`, `-k` only if you accept the default edge cert in a lab):

  ```sh
  curl -sS "https://${RHAIS_HOST}/v1/models" | head
  ```

- [ ] Chat — send a minimal `/v1/chat/completions` body; set `"model"` to the `--served-model-name` (or `id` returned by `/v1/models`) from your Deployment `args`.

- [ ] Troubleshooting — classify ImagePullBackOff (secret / entitlement), Pending (GPU / quota), CrashLoop (args, OOM, model path) using the same habits as [Topic 7](/docs/07-troubleshooting-best-practices.md).

## Hands-on exercise (~15–20 min)

- [ ] Complete Step 1 operator checks; stop if NFD or the GPU operator is unhealthy.  
- [ ] Run Step 2 and Step 3; confirm project `rhaiis-namespace` and `docker-secret`.  
- [ ] Edit and apply Step 5 PVC; wait for Bound.  
- [ ] Edit and apply Step 6 `Deployment`; reach Ready.  
- [ ] Apply Step 7 and Step 8 manifests; run `/v1/models` and one `/v1/chat/completions` call (Verification above).

<p align="center">
<a href="/docs/07-troubleshooting-best-practices.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/README.md">Next</a>
</p>
