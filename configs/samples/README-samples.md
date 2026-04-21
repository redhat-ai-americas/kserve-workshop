# Sample manifests

- **`inferenceservice-oci-sample.yaml`** — Template `InferenceService` using `storageUri` with an `oci://` reference for the **MobileNet v2 ONNX** image you built in [Topic 2](/docs/02-preparing-and-storing-models.md). Edit namespace, runtime name, image URI, and resources before `oc apply`.

- **`Containerfile.model-example`** — Minimal pattern for building a model image. The workshop copies **`extras/models/mobilenetv2-7.onnx`** into `models/1/` before building:

  ```sh
  mkdir -p scratch/model-build/models/1
  cp extras/models/mobilenetv2-7.onnx scratch/model-build/models/1/
  podman build -f configs/samples/Containerfile.model-example \
    -t quay.io/<org>/<repo>:<tag> scratch/model-build
  podman push quay.io/<org>/<repo>:<tag>
  ```

Validate the expected on-disk layout against your chosen **ServingRuntime** and the [deploying models](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform) documentation.
