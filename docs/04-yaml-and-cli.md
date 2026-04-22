# 4. Deploying models via YAML and `oc` (advanced control)

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-advanced-verification-monitoring.md">Next</a>
</p>

### Objectives

- Deploy an `InferenceService` with **`oc apply`** for repeatable GitOps-style workflows.
- Reference **ServingRuntime** names available on the cluster and handle **private OCI** registries.

### Rationale

- Dashboard deployments are convenient; YAML is how you integrate **private images**, **custom args**, and **CI/CD**.

## Full sample stack for oc apply -f

Files live under **`configs/samples/model-deploy/`**. They are plain Kubernetes YAML (no Helm, no Argo CD). They deploy a **GPU vLLM** stack with a **Red Hat Granite** model image (`registry.redhat.io`). **Edit every `namespace: kserve-workshop` field** (and names if you change them) to match your Data Science project before applying.

Apply **in this order** so the `ServingRuntime` exists before the `InferenceService` references it:

```sh
oc apply -f configs/samples/model-deploy/vllm-servingruntime.yaml
oc apply -f configs/samples/model-deploy/model-sa-token.yaml
oc apply -f configs/samples/model-deploy/inferenceservice.yaml
```

Use the **ordered** commands above on first deploy; applying the whole directory at once can process files in an order where the `InferenceService` is created before the `ServingRuntime` exists.

- [ ] Confirm your project has a **hardware profile** and **GPU** capacity matching the annotations (see `inferenceservice.yaml`).  
- [ ] For **private** `registry.redhat.io` pulls, use cluster pull secrets or add `opendatahub.io/connections` on the `InferenceService` per [Private OCI registry](#private-oci-registry) and Red Hat docs.  
- [ ] `model-sa-token.yaml` is optional client RBAC; skip it if you only need the deployed endpoint.

```sh
oc get servingruntime -n <your-project>
oc get inferenceservice -n <your-project>
```

## InferenceService example (public OCI)

This repository includes a commented sample: [`configs/samples/inferenceservice-oci-sample.yaml`](/configs/samples/inferenceservice-oci-sample.yaml). It assumes you built and pushed the **MobileNet** image from [Topic 2](/docs/02-preparing-and-storing-models.md) (or use a facilitator-provided `oci://` URI).

- [ ] Copy the sample into `scratch/` and replace placeholders (`<namespace>`, `quay.io/...`, runtime name, resources).

```sh
cp configs/samples/inferenceservice-oci-sample.yaml scratch/my-isvc.yaml
# edit scratch/my-isvc.yaml
```

Minimal shape (align field names with your cluster’s KServe / OpenShift AI version):

```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sample-isvc-oci
  namespace: <your-project>
spec:
  predictor:
    model:
      runtime: kserve-ovms
      modelFormat:
        name: onnx
      storageUri: oci://quay.io/<user>/<repo>:<tag>
      resources:
        requests:
          cpu: "100m"
          memory: "500Mi"
        limits:
          cpu: "500m"
          memory: "4Gi"
```

- [ ] Apply:

```sh
oc apply -f scratch/my-isvc.yaml
```

- [ ] Watch status:

```sh
oc get inferenceservice -n <your-project>
oc describe inferenceservice sample-isvc-oci -n <your-project>
```

## Private OCI registry

- [ ] Create a **pull secret** in your namespace for the registry.  
- [ ] Attach it to the **default** service account (or the service account your `InferenceService` uses per documentation):

```sh
oc secrets link default <pull-secret-name> --for=pull
```

- [ ] Re-apply the `InferenceService` and verify the predictor pod pulls successfully (`oc get pods`, `oc describe pod`).

## Hands-on exercise (~20–30 min)

- [ ] Deploy using YAML: either the **MobileNet** scratch file from [InferenceService example (public OCI)](#inferenceservice-example-public-oci) **or** the ordered **`oc apply -f`** steps in [Full sample stack for oc apply -f](#full-sample-stack-for-oc-apply--f) (GPU / Granite—only if your cluster supports it).  
- [ ] Confirm **READY** condition and capture the **URL** from status.  
- [ ] (Optional) Add a deliberate mistake (wrong runtime name), observe failure, fix, re-apply.

<p align="center">
<a href="/docs/03-dashboard-platform.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-advanced-verification-monitoring.md">Next</a>
</p>
