# Sample manifests

- **`inferenceservice-oci-sample.yaml`** — Template `InferenceService` using `storageUri` with an `oci://` reference. Edit namespace, runtime name, image URI, and resources before `oc apply`.

- **`Containerfile.model-example`** — Minimal pattern for building a model image. Place files under `models/` (for example `models/1/...`) beside this file when building:

  ```sh
  mkdir -p model-build/models/1
  # populate model-build/models/1 with your artifacts
  cp Containerfile.model-example model-build/Containerfile
  cd model-build
  podman build -t quay.io/<org>/<repo>:<tag> .
  podman push quay.io/<org>/<repo>:<tag>
  ```

Validate the expected on-disk layout against your chosen **ServingRuntime** and the [deploying models](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform) documentation.
