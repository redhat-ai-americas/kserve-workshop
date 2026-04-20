# kserve-workshop

Hands-on workshop for deploying models on the **single-model serving platform (KServe RawDeployment)** in Red Hat OpenShift AI Self-Managed. Content aligns with the official guide: [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

**Audience:** Data scientists, ML engineers, and platform admins who deploy or serve models at scale. Prior experience with OpenShift projects, model storage (S3/OCI/PVC), and basic YAML is recommended.

**Duration:** 90–120 minutes, including labs (core topics about 60–90 minutes; optional NVIDIA NIM extension about 20–30 minutes).

**Format:** Short overview → live dashboard and CLI demonstrations → guided exercises → Q&A and troubleshooting.

If you are starting the workshop, open **[the first set of instructions](/docs/00-setup.md)**.

The repository layout follows [model-catalog-workshop](https://github.com/redhat-ai-americas/model-catalog-workshop) and the [hobbyist guide to RHOAI](https://github.com/redhat-na-ssa/hobbyist-guide-to-rhoai.git) workshop pattern.

## Learning outcomes

Participants should be able to:

- Store models in OCI images (model cars) or PVCs and understand trade-offs.
- Use the OpenShift AI **Deploy model** wizard with automatic or manual runtime and hardware selection.
- Deploy `InferenceService` resources with YAML and `oc` for repeatable, advanced scenarios (private registries, custom arguments).
- Choose deployment strategies (for example RollingUpdate versus Recreate), size CPU/memory/accelerators, and verify endpoints and monitoring signals.
- Apply common troubleshooting steps for runtime mismatches, resource pressure, and image pull issues.

## Lab sequence

| Step | Topic |
|------|--------|
| [0 – Setup](/docs/00-setup.md) | Prerequisites, cluster access, KServe readiness, optional automation |
| [1 – Overview & storage](/docs/01-overview-and-storage.md) | Single-model platform, storage options, related serving approaches |
| [2 – Prepare & store models](/docs/02-preparing-and-storing-models.md) | OCI with Podman, PVC upload from a workbench, formats |
| [3 – Dashboard wizard](/docs/03-dashboard-wizard.md) | Deploy model flow, runtime selection, strategies |
| [4 – YAML & CLI](/docs/04-yaml-and-cli.md) | `ServingRuntime`, `InferenceService`, private OCI |
| [5 – Advanced config & monitoring](/docs/05-advanced-verification-monitoring.md) | Resources, accelerators, auth, metrics, inference checks |
| [6 – Troubleshooting & practices](/docs/06-troubleshooting-best-practices.md) | Pitfalls, production tips, optional failure exercise |
| [7 – NIM extension (optional)](/docs/07-nim-extension.md) | NVIDIA NIM as an optional add-on |

## Primary documentation

- Red Hat OpenShift AI Self-Managed 3.4 — *Deploying models*: [single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform)

Use the product version that matches your cluster; procedures are consistent across recent 3.x releases, but UI labels and CRD details can differ slightly.
