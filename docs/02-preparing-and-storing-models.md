# 2. Preparing and storing models

<p align="center">
<a href="/docs/01-overview-and-storage.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/03-dashboard-platform.md">Next</a>
</p>

### Objectives

- Use the **bundled MobileNet v2 ONNX** model shipped in this repository (no Hugging Face or external download required).
# Pick a path:
- **Track A:** Package the same file into an **OCI** image with Podman and push to a registry you can use (e.x. **Quay**).
- **Track B:** Place the model on a **PVC** via a workbench when registry access is limited.

### Rationale

- The deployment platform and `InferenceService` both expect a consistent on-disk layout and model format for the chosen runtime (for this lab: **ONNX** with an OpenVINO).

### Takeaways

- The workshop standardizes on **`extras/models/mobilenetv2-7.onnx`** so everyone has the same artifact after `git clone`.
- OCI layouts use a **version** folder under `models/` (here: **`models/1/`**).
- PVC workflow: put files where the workbench and serving storage can see them (commonly under `/opt/app-root/src/` or a mounted PVC path).

## Sample model in this repository

After cloning, the MobileNet ONNX file is here:

```text
extras/models/mobilenetv2-7.onnx
```

See [`extras/models/README.md`](/extras/models/README.md) for license and provenance.

---

## Track A — Build OCI image with Podman (optional; run locally)

Use the same ONNX file to build a model image (model car). You need Podman (or Docker) and permission to push to at least one registry the cluster can pull from.

### 1. Stage the layout

From the repository root:

```sh
mkdir -p scratch/model-build/models/1
cp extras/models/mobilenetv2-7.onnx scratch/model-build/models/1/

podman build -f configs/samples/Containerfile.model-example \
  -t mobilenet-onnx-workshop:1 \
  scratch/model-build
```

- [ ] Build completes without errors.

### 2. Choose a registry and push

```sh
podman tag mobilenet-onnx-workshop:1 quay.io/<org>/<repo>:<tag>
podman login quay.io
podman push quay.io/<org>/<repo>:<tag>
```

Record **`oci://quay.io/<org>/<repo>:<tag>`** for the platform flow or YAML.

**Option B — Facilitator-only image**  
A model car image has been pre-built and published to Quay; participants can skip the image build and push process, and reference `quay.io/rh-ee-petdavis/mobilenet-onnx-workshop:1` in the later step.

---

## Track B — PVC / workbench

This track follows Red Hat’s documented flow: Upload model files to the PVC attached to a workbench, then deploy using existing cluster storage. For the upstream procedure, see *Deploying models* → Uploading model files to a Persistent Volume Claim (PVC) in [Red Hat OpenShift AI documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

### 1. Open the `kserve-workshop` project

1. Log in to the **OpenShift AI** dashboard.
2. Go to **Projects**).
3. Switch the filter from A.I. projects to All projects.
3. Open the **`kserve-workshop`** project ([Topic 0](/docs/00-setup.md)).

### 2. Create a workbench

1. Open the **Workbenches** tab for that project.
2. Click **Create workbench**.
3. **Name:** e.g. `kserve-lab`.
4. **Image:** choose `Jupyter | Minimal | CPU | Python 3.12`.
5. Create the workbench and wait until its state is **Running**.

More detail: [Creating a project workbench](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/working_on_projects/using-project-workbenches_projects) (adjust the doc version to match your install).

### 3. Open the workbench

1. When the workbench is running, click the name to open. Your browser opens a JupyterLab environment on the cluster.

### 4. Place `mobilenetv2-7.onnx` under `/opt/app-root/src/`

**Clone the repo inside the workbench terminal**

1. Open a terminal in the workbench
2. Run:

   ```sh
   cd /opt/app-root/src
   git clone https://github.com/redhat-ai-americas/kserve-workshop.git
   mkdir -p models
   cp kserve-workshop/extras/models/mobilenetv2-7.onnx models/
   ls -la models/mobilenetv2-7.onnx
   ```

**Stop the workbench after copying (before Topic 3 deploy)**

The workbench PVC is usually ReadWriteOnce: only one pod can mount it at a time. After your model file is on the volume, stop the workbench from **`kserve-workshop`** (**Workbenches** → stop). That releases the PVC so Deploy model in Topic 3 can use the same storage.

### 5. Record PVC name and path for Topic 3

For Deploy model (Topic 3), you will choose existing cluster storage / PVC and a path to the model file on that volume.

- **PVC:** select the PVC name attached to this workbench. This can be found in the OpenShift AI dashboard under the project’s **Cluster storage** tab. 
- **Path:** relative to that volume’s root—e.g. You will just use the model root. For example, `models/` if you used the layout above.

Write these down; Topic 3 uses them in the platform.

---

## Formats and runtime

- **ONNX** — pair with an OpenVINO `ServingRuntime` on your cluster.

## Exercise (~25–35 min)

- [ ] **Everyone:** Confirm `extras/models/mobilenetv2-7.onnx` is present after clone (`ls -la extras/models/`).
- [ ] **Track A:** Image builds locally and pushes successfully; record `oci://...` for Topic 3–4.
- [ ] **Track B:** Model file is under `/opt/app-root/src/...` in the workbench; PVC + relative path recorded for Topic 3; workbench stopped before Topic 3 deploy (same PVC).


<p align="center">
<a href="/docs/01-overview-and-storage.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/03-dashboard-platform.md">Next</a>
</p>
