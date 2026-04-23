# Sample manifests

- **`../extras/notebooks/generative-inference.ipynb`** — Pre-filled notebook for [Topic 5](/docs/05-generative-inference-workbench.md); set route URL and Bearer token from Secret **`granite-3-1-8b-instruct-sa`**.

- **`hardware-profile/hardware-profile.yaml`** — **`HardwareProfile`** named **`nvidia-gpu`** in **`redhat-ods-applications`**, used by the Granite sample in [Topic 4](/docs/04-yaml-and-cli.md). Apply **before** that `InferenceService` when the profile is missing (often **admin-only**).

- **`inferenceservice-oci-sample.yaml`** (this directory) — Template `InferenceService` with `storageUri` `oci://…` for the **MobileNet v2 ONNX** image from [Topic 2](/docs/02-preparing-and-storing-models.md). Namespace **`kserve-workshop`**; edit **runtime**, **image URI**, and **resources** before `oc apply`.

- **`Containerfile.model-example`** — Minimal pattern for building a model image. The workshop copies **`extras/models/mobilenetv2-7.onnx`** into `models/1/` before building:

  ```sh
  mkdir -p scratch/model-build/models/1
  cp extras/models/mobilenetv2-7.onnx scratch/model-build/models/1/
  podman build -f configs/samples/Containerfile.model-example \
    -t quay.io/<org>/<repo>:<tag> scratch/model-build
  podman push quay.io/<org>/<repo>:<tag>
  ```

Validate the expected on-disk layout against your chosen **ServingRuntime** and the [deploying models](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform) documentation.
