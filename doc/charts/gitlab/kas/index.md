---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Using the GitLab-Kas chart

The `kas` sub-chart provides a configurable deployment of the [Kubernetes Agent Server](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent#gitlab-kubernetes-agent-server-kas), which is the server-side component of the [GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent) implementation.

## Requirements

This chart depends on access to the GitLab API and the Gitaly Servers. An Ingress will be deployed if this chart is enabled.

## Design Choices

The `kas` container used in this chart will use a distroless image for minimal resource consumption. The deployed services will be exposed by an Ingress which will use [WebSocket proxying](https://nginx.org/en/docs/http/websocket.html) to permit communication in long lived connections with the external component [`agentk`](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent#gitlab-kubernetes-agent-agentk), which is its Kubernetes cluster-side agent counterpart.

Follow the link for further information about the [GitLab Kubernetes Agent architecure](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md).

## Configuration

`kas` is deployed turned off by default. To enable it on your GitLab server, use the Helm flag, like: `helm instal --set gitlab.kas.enabled=true`.

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                | Default        | Description                      |
| ------------------------ | -------------- | ---------------------------------|
| `annotations`            | `{}`           | Pod annotations                  |
| `enabled`                | `false`        | installs / uninstalls `kas`      |
| `image.repository`       | `registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/kas` | image repository |
| `image.tag`              | `latest-race`  | image tag                        |
| `hpa.targetAverageValue` | `100m`         | Set the autoscaling target value (cpu) |
| `ingress.annotations`    | `{}`           | ingress annotations              |
| `ingress.tls`            | `{}`           | ingress tls configuration        |
| `maxReplicas`            | `10`           | HPA `maxReplicas`                |
| `maxUnavailable`         | `1`            | HPA `maxUnavailable`             |
| `minReplicas`            | `2`            | HPA `maxReplicas`                |
| `serviceAccount.annotations` | `{}`       | service account annotations      |
| `service.externalPort`   | `5005`         | external port                    |
| `service.internalPort`   | `5005`         | internal port                    |
| `service.type`           | `ClusterIP`    | service type                     |