# 2. Preparing and storing models

<p align="center">
<a href="/docs/01-overview-and-storage.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/03-dashboard-wizard.md">Next</a>
</p>

### Objectives

- Use the **bundled MobileNet v2 ONNX** sample shipped in this repository (no Hugging Face or external download required for class).
- **Track B (default):** Place the model on a **PVC** via a workbench when registry access is limited.
- **Track A (optional):** Package the same file into an **OCI** image with Podman and push to a registry you can use (**Quay**, or the **OpenShift integrated registry**).

### Rationale

- Deployment wizards and `InferenceService` both expect a consistent **on-disk layout** and **model format** for the chosen runtime (for this lab: **ONNX** with an OpenVINO / OVMS-style `ServingRuntime` such as `kserve-ovms`—names vary by cluster).

### Takeaways

- The workshop standardizes on **`extras/models/mobilenetv2-7.onnx`** so everyone has the same artifact after `git clone`.
- OCI layouts use a **version** folder under `models/` (here: **`models/1/`**); adjust if your runtime documentation requires `models/<name>/1/`.
- PVC workflow: put files where the workbench and serving storage can see them (commonly under `/opt/app-root/src/` or a mounted PVC path).

## Sample model in this repository

After cloning, the MobileNet ONNX file is here:

```text
extras/models/mobilenetv2-7.onnx
```

See [`extras/models/README.md`](/extras/models/README.md) for license and provenance.

---

## Track B — PVC / workbench (recommended default)

Use this when participants **do not** have access to Quay or prefer not to build images.

- [ ] Create or use a **workbench** in your Data Science project and ensure storage/PVC is available per your OpenShift AI version.
- [ ] Copy the bundled model into the workbench project tree (upload via Jupyter **or** clone this repo inside the workbench and copy from `extras/models/`).
- [ ] Note the **path** you will use in the **Deploy model** wizard or in YAML (PVC `storageUri` form depends on product version—follow [Red Hat documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform)).

**From OpenShift Web Terminal** (with this repo cloned):

```sh
cp extras/models/mobilenetv2-7.onnx scratch/
ls -la scratch/mobilenetv2-7.onnx
```

Upload `scratch/mobilenetv2-7.onnx` to the workbench if your serving deployment reads from a PVC path you populate that way.

---

## Track A — OCI image with Podman (optional)

Use the **same** ONNX file to build a **model image** (model car). You need **Podman** (or Docker) and **permission to push** to at least one registry the cluster can pull from.

### 1. Stage the layout

From the **repository root**:

```sh
mkdir -p scratch/model-build/models/1
cp extras/models/mobilenetv2-7.onnx scratch/model-build/models/1/

podman build -f configs/samples/Containerfile.model-example \
  -t mobilenet-onnx-workshop:local \
  scratch/model-build
```

- [ ] Build completes without errors.

### 2. Choose a registry and push

**Option A — Your Quay.io repository (facilitator or participant)**  
If the cluster can pull from `quay.io`:

```sh
podman tag mobilenet-onnx-workshop:local quay.io/<org>/<repo>:<tag>
podman login quay.io
podman push quay.io/<org>/<repo>:<tag>
```

Record **`oci://quay.io/<org>/<repo>:<tag>`** for the wizard or YAML.

**Option B — OpenShift integrated registry**  
OpenShift includes an image registry (often `image-registry.openshift-image-registry.svc:5000` inside the cluster). With rights to push to **your** namespace:

```sh
# Log in the CLI to the integrated registry (exact flags depend on OpenShift version).
oc registry login

# Example tag (replace <project> with your Data Science namespace):
REGISTRY=$(oc registry info --public=true 2>/dev/null || echo "image-registry.openshift-image-registry.svc:5000")
# Some clusters use oc registry info; if unset, ask your admin for the registry host to use with podman login.

podman tag mobilenet-onnx-workshop:local "$REGISTRY/<project>/mobilenet-onnx-workshop:latest"
podman push "$REGISTRY/<project>/mobilenet-onnx-workshop:latest"
```

Use the **`oci://...`** form your cluster expects for pulls (add **pull secrets** on the service account if the registry is private). See OpenShift documentation: [Accessing the registry](https://docs.redhat.com/en/documentation/openshift_container_platform/4.15/html/registry/accessing-the-registry).

**Option C — Facilitator-only image**  
The instructor builds once and publishes to Quay; participants only **reference** `oci://quay.io/<instructor-org>/...` and skip `podman push`.

---

## Formats and runtime

- **ONNX** — pair with an **OpenVINO / OVMS**-style `ServingRuntime` on your cluster (example name: `kserve-ovms`; **verify** with `oc get servingruntime -A`).
- Install or enable runtimes per [deploying models](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform) if the list is empty.

## Exercise (~25–35 min)

- [ ] **Everyone:** Confirm `extras/models/mobilenetv2-7.onnx` is present after clone (`ls -la extras/models/`).
- [ ] **Track B:** Model file is visible in the workbench or PVC path you will deploy from; record that path.
- [ ] **Track A (optional):** Image builds locally and pushes successfully; record **`oci://...`** for Topic 3–4.

### Verify locally (facilitators)

From the repo root:

```sh
./scripts/verify-workshop-samples.sh
```

<p align="center">
<a href="/docs/01-overview-and-storage.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/03-dashboard-wizard.md">Next</a>
</p>
