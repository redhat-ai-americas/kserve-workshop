# kserve-workshop

Hands-on workshop for deploying models on the **single-model serving platform (KServe RawDeployment)** in Red Hat OpenShift AI Self-Managed. Content aligns with the official guide: [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

**Audience:** Data scientists, ML engineers, and platform admins who deploy or serve models at scale. Prior experience with OpenShift projects, model storage (S3/OCI/PVC), and basic YAML is recommended.

**Duration:** About 90–120 minutes, including labs (core topics about 70–100 minutes, depending on optional GPU segments).

**Format:** Short overview → live dashboard and CLI demonstrations → guided exercises → Q&A and troubleshooting.

If you are starting the workshop, open **[the first set of instructions](/docs/00-setup.md)**.

**Namespace:** All labs assume a single Data Science project / OpenShift namespace named **`kserve-workshop`**. Create it in Topic 0 with `oc new-project kserve-workshop` (or `oc project kserve-workshop` if it already exists).

The repository layout follows the [hobbyist guide to RHOAI](https://github.com/redhat-na-ssa/hobbyist-guide-to-rhoai.git) workshop pattern.

## Learning outcomes

Participants should be able to:

- Store the bundled **MobileNet v2 ONNX** in OCI images (model cars) or PVCs and understand trade-offs.
- Use the OpenShift AI **Deploy model** platform with automatic or manual runtime and hardware selection.
- Deploy `InferenceService` resources with YAML and `oc` for repeatable, advanced scenarios (private registries, custom arguments).
- Call a **generative** model over HTTPS with a **Bearer token** from a workbench using the bundled notebook.
- Tune **vLLM** arguments in the UI, verify readiness, and skim **metrics** for a deployment.
- Apply common troubleshooting steps for runtime mismatches, resource pressure, and image pull issues.

## Lab sequence

| Step | Topic |
|------|--------|
| [0 – Setup](/docs/00-setup.md) | Prerequisites, cluster access, KServe readiness, optional automation |
| [1 – Overview & storage](/docs/01-overview-and-storage.md) | Single-model platform, storage options, related serving approaches |
| [2 – Prepare & store models](/docs/02-preparing-and-storing-models.md) | **MobileNet ONNX** (bundled in-repo), PVC (default) or optional OCI / Quay / integrated registry |
| [3 – Dashboard platform](/docs/03-dashboard-platform.md) | Deploy model flow, runtime selection, strategies |
| [4 – YAML & CLI](/docs/04-yaml-and-cli.md) | `ServingRuntime`, `InferenceService`, private OCI |
| [5 – Generative inference](/docs/05-generative-inference-workbench.md) | Route + SA token secret, notebook on a workbench |
| [6 – vLLM tuning & monitoring](/docs/06-advanced-verification-monitoring.md) | Standard **vLLM** args in the GUI, verification, metrics |
| [7 – Troubleshooting & practices](/docs/07-troubleshooting-best-practices.md) | Pitfalls, production tips, optional failure exercise |

## Primary documentation

- Red Hat OpenShift AI Self-Managed 3.4 — *Deploying models*: [single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform)

Use the product version that matches your cluster; procedures are consistent across recent 3.x releases, but UI labels and CRD details can differ slightly.
