# 4. Deploying models via YAML and `oc` (advanced control)

<p align="center">
<a href="/docs/03-dashboard-wizard.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-advanced-verification-monitoring.md">Next</a>
</p>

### Objectives

- Deploy an `InferenceService` with **`oc apply`** for repeatable GitOps-style workflows.
- Reference **ServingRuntime** names available on the cluster and handle **private OCI** registries.

### Rationale

- Dashboard deployments are convenient; YAML is how you integrate **private images**, **custom args**, and **CI/CD**.

### Takeaways

- `spec.predictor.model.runtime` must match an existing `ServingRuntime` name.  
- Private images need **`imagePullSecrets`** on the service account used by the predictor (see product docs for your version).

## ServingRuntime

Clusters often ship or pre-apply runtimes (for example OpenVINO). List what you can use:

```sh
oc get servingruntime -n <namespace>
oc get servingruntime -A   # if cluster-scoped listing is allowed
```

Install or update runtimes according to [Red Hat documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform); your admin may use `oc process` on packaged templates where provided.

## InferenceService example (public OCI)

This repository includes a commented sample: [`configs/samples/inferenceservice-oci-sample.yaml`](/configs/samples/inferenceservice-oci-sample.yaml).

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

- [ ] Deploy your sample using YAML.  
- [ ] Confirm **READY** condition and capture the **URL** from status.  
- [ ] (Optional) Add a deliberate mistake (wrong runtime name), observe failure, fix, re-apply.

<p align="center">
<a href="/docs/03-dashboard-wizard.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/05-advanced-verification-monitoring.md">Next</a>
</p>
