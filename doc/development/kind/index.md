---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Developing for Kubernetes with KinD

This guide is meant to serve as a cross-platform resource for setting up a local Kubernetes development environment.
In this guide, we'll be using [KinD](https://kind.sigs.k8s.io). It creates a Kubernetes cluster using Docker, and provides easy mechanisms for deploying different versions as well as multiple nodes.

We will also make use of [nip.io](https://nip.io), which lets us map any IP address to a hostname using a format like this: `192.168.1.250.nip.io`, which maps to `192.168.1.250`. No installation is required.

NOTE: **Note:**
With the SSL-enabled installation options below, if you want to clone repositories and push changes, you will have to do so over HTTPS instead of SSH. We are planning to address this with an update to GitLab Shell's service exposure via NodePorts.

## Preparation

### Required information

All of the following installation options require knowing your host IP. Here are a couple options to find this information:

- Linux: `hostname -i`
- MacOS: `ipconfig getifaddr en0`

NOTE: **Note:**
Most MacOS systems use `en0` as the primary interface. If using a system with a different primary interface, please substitute that interface name for `en0`.

### Using namespaces

It is considered best practice to install applications in namespaces other than `default`. You can create a namespace using `kubectl create namespace (some name)`, and then add on `--namespace (some name)` to future `kubectl` commands. If you don't want to type that repeatedly, check out `kubens` from the [kubectx](https://github.com/ahmetb/kubectx) project.

### Installing dependencies

You can use `asdf` ([more info](../index.md#common-developer-tools)) to install the following tools:

- `kubectl`
- `helm`
- `kind`

Note that `kind` uses Docker to run local Kubernetes clusters, so be sure to [install Docker](https://docs.docker.com/get-docker/).

### Obtaining configuration examples

Clone the GitLab Chart repository for local copies of the configuration example files referenced in the next steps:

```shell
git clone https://gitlab.com/gitlab-org/charts/gitlab.git
```

### Adding GitLab Helm chart

Follow these commands to set up your system to access the GitLab Helm charts:

```shell
helm repo add gitlab https://charts.gitlab.io/
helm repo update
```

### Clone the GitLab chart repository

The following instructions use files in the [GitLab Chart repository](https://gitlab.com/gitlab-org/charts/gitlab). Be sure to have it cloned locally and navigate to the repository root in your shell.

### Enter your host domain

With the GitLab chart repository cloned, open `examples/kind/values-base.yaml` and replace `(your host IP)` with the value obtained [above](#required-information) under `global.hosts.domain`.

## Deployment options

Select from one of the following deployment options based on your needs.

### NGINX Ingress NodePort with SSL

In this method, we will use `kind` to expose the NGINX controller service's NodePorts to ports on your local machine with SSL enabled.

```shell
kind create cluster --config examples/kind/kind-ssl.yaml
helm upgrade --install gitlab gitlab/gitlab -f examples/kind/values-base.yaml -f examples/kind/values-ssl.yaml
```

You can then access GitLab at `https://gitlab.(your host IP).nip.io`.

#### (Optional) Add root CA

In order for your browser to trust our self-signed certificate, download the root CA and trust it:

```shell
kubectl get secret gitlab-wildcard-tls-ca -ojsonpath='{.data.cfssl_ca}' | base64 --decode > gitlab.(your host IP).nip.io.ca.pem
```

Now that the root CA is downloaded, you can add it to your local chain (instructions vary per platform and are readily available online).

NOTE: **Note:**
If you need to log into the registry with `docker login`, you will need to take additional steps to configure the registry to work with your self-signed certificates. More instructions can be found [here](https://docs.docker.com/registry/deploying/#run-an-externally-accessible-registry) and [here](https://blog.container-solutions.com/adding-self-signed-registry-certs-docker-mac).

### NGINX Ingress NodePort without SSL

In this method, we will use `kind` to expose the NGINX controller service's NodePorts to ports on your local machine with SSL disabled.

```shell
kind create cluster --config examples/kind/kind-no-ssl.yaml
helm upgrade --install gitlab gitlab/gitlab -f examples/kind/values-base.yaml -f examples/kind/values-no-ssl.yaml
```

Access GitLab at `http://gitlab.(your host IP).nip.io`.

NOTE: **Note:**
If you need to log into the registry with `docker login`, you will need to tell Docker to [trust your insecure registry](https://docs.docker.com/registry/insecure/#deploy-a-plain-http-registry).

### Handling DNS

This guide assumes you have network access to [nip.io](https://nip.io). If this is not available to you, please refer to the [handling DNS](../minikube/index.md#handling-dns) section in the Minikube documentation which will also work for KinD.

NOTE: Note:
When editing **/etc/hosts**, remember to use the [host computer's IP address](#required-information) rather than the output of `$(minikube ip)`.

## Cleaning up

When you're ready to clean up your local system, run this command:

```shell
kind delete cluster
```

NOTE: **Note:**
If you named your cluster upon creation, or if you are running multiple clusters, you can delete specific ones with the `--name` flag.
