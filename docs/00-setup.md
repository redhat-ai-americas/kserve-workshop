# 0. Prerequisites and setup

<p align="center">
<a href="/README.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/01-overview-and-storage.md">Next</a>
</p>

> Run commands from the **root directory of this repository** unless noted otherwise. Some steps create files under `scratch/`, which is ignored by `.gitignore`.

## Official reference

Follow Red Hat documentation for architecture and procedures: [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

## Checklist

- [ ] Access to an OpenShift cluster with **Red Hat OpenShift AI Self-Managed** installed (this material targets the 3.x line; match docs to your installed version).
- [ ] Ability to log in to the **OpenShift AI dashboard** as a project user (cluster admin or dedicated admin rights if you must enable or approve runtimes).
- [ ] **Single-model serving** and **KServe** enabled on the cluster; cluster or namespace has **ServingRuntime** resources available (for example vLLM for NVIDIA, OpenVINO, or your approved custom runtimes).
- [ ] A **Data Science project** (or equivalent) with a **storage connection** where needed (S3-compatible, OCI registry, or PVC).
- [ ] For **OCI model images**: [Podman](https://podman.io/) (or Docker) on your laptop or bastion, and credentials to push to a registry (for example [Quay.io](https://quay.io/)).
- [ ] For **GPU** exercises: GPU Operator and Node Feature Discovery configured; accelerators visible to workloads in your namespace.
- [ ] A **sample model** for testing (small ONNX for OpenVINO, or a Hugging Face URI / OCI reference suitable for your runtime).
- [ ] **`oc`** CLI installed and network access to the cluster API.
- [ ] Comfort with YAML, basic container workflows, and HTTP inference concepts.

## Clone and prepare

- [ ] Open a `bash` terminal on your machine (workshop scripts are tested with bash).

- [ ] Clone this repository and enter the directory.

```sh
git clone https://github.com/redhat-ai-americas/kserve-workshop.git

cd kserve-workshop
```

- [ ] Create a scratch directory for generated files.

```sh
mkdir -p scratch
```

- [ ] Log in to the cluster.

```sh
oc login <openshift_api_url> -u <username> -p <password>
```

- [ ] Set your target **namespace** for labs (replace with your project name).

```sh
oc project <your-data-science-project>
```

## Optional: automated prerequisites (step 0)

From the repository root, you can install the OpenShift **Web Terminal** operator and apply a console banner. This mirrors other RHOAI workshops and gives you `oc` in the browser.

- [ ] Run:

```sh
./scripts/setup.sh -s 0
```

> [!NOTE]
> After Web Terminal installs, refresh the OpenShift console if the terminal menu does not appear.

For the remaining labs you may use your **local** shell or the **Web Terminal**.

## Verify KServe and model serving

- [ ] Confirm KServe APIs are available:

```sh
oc api-resources | grep -E 'inferenceservice|servingruntime' || true
```

- [ ] List ServingRuntimes (names vary by cluster):

```sh
oc get servingruntime -A 2>/dev/null || oc get servingruntime
```

- [ ] In the OpenShift AI UI, open your project → **Deployments** (or **Models**) and confirm you can start the **Deploy model** flow. See [Red Hat documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform) for the exact menu names in your version.

<p align="center">
<a href="/README.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/01-overview-and-storage.md">Next</a>
</p>
