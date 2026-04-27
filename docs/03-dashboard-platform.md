# 3. Deploying models via the dashboard platform

<p align="center">
<a href="/docs/02-preparing-and-storing-models.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/04-yaml-and-cli.md">Next</a>
</p>

### Objectives

- Deploy a model using the OpenShift AI dashboard.
- For model location, pick the same kind of storage as in [Topic 2](/docs/02-preparing-and-storing-models.md): Quay / OCI image or PVC, and wire the correct connection.
- Choose runtime (automatic or manual), hardware profile, and deployment strategy deliberately.

### Rationale

- The platform is the fastest path for deploying a model. Understanding each step maps directly to the YAML fields you will edit in [Topic 4](/docs/04-yaml-and-cli.md).

### Takeaways

- Auto runtime matches hardware and model format when possible; use manual when multiple runtimes apply or when admins require a specific stack.
- RollingUpdate favors availability when enough resources exist; Recreate can succeed on tighter quotas but causes brief downtime.

## Open the Deploy model flow

Deploy into the `kserve-workshop` project from [Topic 0](/docs/00-setup.md).

1. In the OpenShift AI dashboard, go to Projects.
2. Select `kserve-workshop`.
3. Open the Deployments tab for the project.
4. Click Deploy model to start the flow described in the next section.

## Model details: connection and path

Use the same track you followed in [Topic 2](/docs/02-preparing-and-storing-models.md). 

### Track A — OCI image on Quay (Topic 2 optional track)

You pushed an image with Podman and recorded `oci://quay.io/<org>/<repo>:<tag>`, or use the pre-deployed `quay.io/rh-ee-petdavis/mobilenet-onnx-workshop:1`


1. Model Location: Pick URI.  
2. URI: Enter the quay image path with oci://. For example: `oci://quay.io/rh-ee-petdavis/mobilenet-onnx-workshop:1`
3. Name: Choose a model name.
4. Model type: choose Predictive.  
5. Connection: select `create a connection to this location` so the serving workload can pull the image.  
6. Model deployment name: Select a name for the deployment
7. Hardware profile: Leave as default-profile
8. Model framework: select onnx - 1

- continue to next section


### Track B — PVC / existing cluster storage

You placed `mobilenetv2-7.onnx` on the workbench PVC and recorded PVC name + model root path.

1. Model Location: choose `Cluster storage` 
2. Model path: `PVC name` + `relative model root path` (`models/`).  
3. Model type: choose `Predictive`.  

- continue to next section

After this screen, both tracks continue to Model deployment (hardware, runtime) and Advanced the same way.


1. Model deployment name: Select a name for the deployment
2. Hardware profile: Leave as default-profile
3. Model framework: select onnx - 1
4. Serving Runtime: you must choose a predictive / ONNX-capable runtime. In this workshop we will use OpenVINO.

Advanced Settings
5. Check both `Make model deployment available through an external route` and `Require token authentication`

## Deployment strategies

| Strategy | Behavior | When to use |
|----------|-----------|-------------|
| RollingUpdate | New revision before old terminates | Enough quota/headroom; zero-downtime goal |
| Recreate | Tear down then start | Tight resources; acceptable downtime |

6. Click `next,` and then review and click `Deploy Model`

## Hands-on exercise (~25–35 min)

- [ ] In `kserve-workshop`: Deployments → Deploy model (see [Open the Deploy model flow](#open-the-deploy-model-flow) above).  
- [ ] Model details: follow Track A or Track B under [Model details: connection and path](#model-details-connection-and-path) so your connection matches Topic 2 (Quay/OCI or PVC) and your URI or file path is correct.  
- [ ] Select appropriate Hardware profile and runtime.  
- [ ] Deploy and wait until the Deployments shows Started for the model.  
- [ ] Copy the extended inference endpoint (route) for Topic 5.

<p align="center">
<a href="/docs/02-preparing-and-storing-models.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/04-yaml-and-cli.md">Next</a>
</p>
