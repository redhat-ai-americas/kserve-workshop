# Red Hat AI Inference Server (plain OpenShift) samples

YAML for [Topic 8](/docs/08-red-hat-ai-inference-server.md). Matches the resource order in [Red Hat AI Inference Server 3.2 — Deploying on OpenShift](https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.2/html/deploying_red_hat_ai_inference_server_in_openshift_container_platform/index), Chapter 5.

Apply order:

1. Create the namespace (`namespace.yaml`) or `oc new-project rhaiis-namespace`.
2. Create `docker-secret` for `registry.redhat.io` (not stored in git — use `oc create secret` from Topic 8).
3. `pvc-model-cache.yaml` — edit `storageClassName` for your cluster.
4. `deployment-granite.yaml` — confirm the RHAIS `image` digest or tag against the product doc before apply.
5. `service-granite.yaml`
6. `route-granite.yaml`

Secrets are not committed here; use the commands in the topic doc.
