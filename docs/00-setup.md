# 0. Prerequisites and setup

<p align="center">
<a href="/README.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/01-overview-and-storage.md">Next</a>
</p>

> Run commands from the root directory of this repository unless noted otherwise. Some steps create files under `scratch/`, which is ignored by `.gitignore`.

## Official reference

Follow Red Hat documentation for architecture and procedures: [Deploying models on the single-model serving platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.2/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform).

## Checklist

- [ ] Access to an OpenShift cluster with Red Hat OpenShift AI Self-Managed installed (this material targets the 3.x line; match docs to your installed version).
- [ ] Ability to log in to the OpenShift AI dashboard as a project user with cluster admin or dedicated admin rights.
- [ ] KServe enabled on the cluster (set to managed in the DataScienceCluster).
- [ ] A Data Science project named `kserve-workshop`.
- [ ] For OCI model images: [Podman](https://podman.io/) (or Docker) on your laptop or bastion, and credentials to push to a registry (for example [Quay.io](https://quay.io/)).
- [ ] For GPU exercises: GPU Operator and Node Feature Discovery configured.
- [ ] A sample model for testing (this repo includes MobileNet ONNX under `extras/models/`, or use another URI suitable for your runtime).
- [ ] `oc` CLI installed and network access to the cluster API.
- [ ] Comfort with YAML, basic container workflows, and HTTP inference concepts.

## Clone and prepare

- [ ] Open a `bash` terminal on your machine.

- [ ] Clone this repository and enter the directory.

```sh
git clone https://github.com/redhat-ai-americas/kserve-workshop.git

cd kserve-workshop
```

- [ ] Log in to the cluster.

```sh
oc login <openshift_api_url> -u <username> -p <password>
```

- [ ] Create and use the workshop namespace (OpenShift project) `kserve-workshop`:

```sh
oc new-project kserve-workshop
```

For the remaining labs you may use your local shell or the Web Terminal.

### Cloning in the OpenShift Web Terminal

It works the same way as on your laptop: `git clone …` and `cd kserve-workshop` give you all lab files (`docs/`, `extras/models/`, `configs/samples/`), as long as the cluster allows outbound HTTPS to your Git host (for example `github.com`). If git clone fails, use a fork on an allowed host, a zip you upload to a workbench, or clone from your laptop and copy files with `oc cp`.

### How to read the modules (Markdown) in a terminal

The lessons are plain `.md` files under `docs/`. The Web Terminal does not render GitHub-style navigation; use any of these:

| Approach | How |
|--------|-----|
| Pager | `less docs/01-overview-and-storage.md` (quit with `q`) |
| Print | `cat docs/00-setup.md` |
| Editor | `vi docs/02-preparing-and-storing-models.md` if you prefer |
| Browser | Open the same repo on GitHub (or your fork) and read online while using the terminal for commands |
| Workbench | If you also cloned into JupyterLab / code-server, open the `.md` file in the IDE for nicer formatting |

Links like `/docs/…` in the files are meant for GitHub; in the shell, paths are relative to the repo root, e.g. `docs/01-overview-and-storage.md`.

## Verify KServe and model serving

- [ ] Confirm KServe APIs exist: `oc api-resources | grep -E 'inferenceservice|servingruntime' || true`
- [ ] Optional: `oc get servingruntime -A` — may be empty until runtimes are installed (see [Red Hat docs](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.2/html-single/deploying_models/index#deploying_models_on_the_single_model_serving_platform)).
- [ ] Open OpenShiftAI using the application drop down in the top right of the OpenShift Console.

<p align="center">
<a href="/README.md">Prev</a>
&nbsp;&nbsp;&nbsp;
<a href="/docs/01-overview-and-storage.md">Next</a>
</p>
