# 2. Preparing and storing models

<p align="center">
<a href="/docs/01-overview-and-storage.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/03-dashboard-wizard.md">Next</a>
</p>

### Objectives

- Package a model for **OCI** serving using Podman and a minimal container layout.
- Upload model files to a **PVC** from a workbench when registry workflows are not required.

### Rationale

- Deployment wizards and `InferenceService` both expect a consistent **on-disk layout** and **model format** for the chosen runtime (OpenVINO, vLLM, Caikit, and so on). Preparing artifacts correctly prevents obscure runtime errors.

### Takeaways

- OCI images often use a versioned directory structure such as `models/1/...` under the container root.
- PVC workflow: place files under the workbench project path (commonly under `/opt/app-root/src/` or your team’s convention) so the serving pod can mount the claim.

## OCI: build and push with Podman

Red Hat’s deploying models documentation describes building model images with **Podman**, using a small base such as **ubi-micro**, setting permissions, and running as a non-root user. Adapt names to your registry.

**Example pattern** (illustrative — adjust paths and base image to your environment):

1. Lay out weights under `models/1/` in a temporary build directory.  
2. Use a `Containerfile` that copies that tree, sets `chmod` as required, and ends with `USER 65534` (or another non-root UID per your policy).  
3. Build and push to Quay.io or your internal registry.

Sample files live in this repo:

- [`configs/samples/Containerfile.model-example`](/configs/samples/Containerfile.model-example)  
- [`configs/samples/README-samples.md`](/configs/samples/README-samples.md)

**Commands** (replace registry and tags):

```sh
mkdir -p scratch/model-build/models/1
# copy your model files into scratch/model-build/models/1/

podman build -f configs/samples/Containerfile.model-example -t quay.io/<org>/<repo>:<tag> scratch/model-build
podman push quay.io/<org>/<repo>:<tag>
```

- [ ] Build succeeds locally.  
- [ ] Push succeeds and the image is readable from the cluster (firewall / pull secrets if private).

## PVC: upload from a workbench

- [ ] Create or attach a **PVC** to your data science project as documented for your OpenShift AI version.
- [ ] Open **JupyterLab** or **code-server** workbench.
- [ ] Upload model files into your project directory (for example under `/opt/app-root/src/`).
- [ ] Confirm paths in the terminal with `ls` and note the path you will pass to the deploy wizard or YAML (`storageUri` pointing at PVC).

## Formats (runtime-dependent)

- **ONNX** — often paired with **OpenVINO** runtimes (`kserve-ovms` or equivalent name on your cluster).  
- **Caikit** — Caikit-based runtimes expect Caikit layout and configuration.  
- **Hugging Face** — many generative flows use a model ID or URI; verify your **ServingRuntime** supports the chosen backend.

Always cross-check the **model format** field in the UI or `InferenceService` with the [product documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform) for your version.

## Exercise (~25–35 min)

Choose **one** track:

**Track A — OCI**

- [ ] Build and push a **small** ONNX or test model image using the sample `Containerfile` as a base.
- [ ] Record the full image reference: `oci://quay.io/...`.

**Track B — PVC**

- [ ] Upload a small test model to the workbench PVC.
- [ ] Record the storage path you will use in deployment.

<p align="center">
<a href="/docs/01-overview-and-storage.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/03-dashboard-wizard.md">Next</a>
</p>
