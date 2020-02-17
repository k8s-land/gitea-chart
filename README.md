# Gitea

[Gitea](https://gitea.com/) is a lightweight GitHub clone.  This is for those who wish to self host their own git repos on kubernetes.

This chart is based upon the work done by [@jfelten](https://github.com/jfelten/gitea-helm-chart)

## TLDR

```sh
helm repo add k8s-land https://charts.k8s.land
helm install gitea k8s-land/gitea
```

## Introduction

This chart bootstraps both [Gitea](http://gitea.com) and MariaDB.

In this chart, the following are ran:
  - Gitea
  - Memcached
  - Mariadb

## Prerequisites

- Kubernetes 1.12+
- Helm 3.0+
- PV provisioner for persistent data support

## Installing the Chart

By default, we use ingress to expose the service.

To install WITHOUT persistent storage / development:

```bash
helm repo add k8s-land https://charts.k8s.land
helm install gitea k8s-land/gitea
```

For production / installing with persistent data:

```sh
helm show values k8s-land/gitea > values.yaml
vim values.yaml # Edit to enable persistent storage
helm install gitea k8s-land/gitea -f values.yaml
```

### Database Configuration

By default, we will launch a Mariadb database:

```yaml
mariadb:
  enabled: true
```

To use an external database, disable the in-pod database and fill in the "externalDB" values:

```yaml
mariadb:
  enabled: false

#Connect to an external database
 externalDB:
  dbUser: "postgres"
   dbPassword: "<MY_PASSWORD>"
   dbHost: "db-service-name.namespace.svc.cluster.local" # or some external host
   dbPort: "5432"
   dbDatabase: "gitea"
```

## Persistent Data

By default, persistent data is not enabled and thus you'll have to enable it from within the `values.yaml`.

Unless otherwise set to true, data will be deleted when the Pod is restarted. 

To prevent data loss, we will enable persistent data.

First, enable persistency:

```yaml
persistence:
  enabled: true
```


If you wish for helm **NOT** to replace data when re-deploying (updating the chart), add the `resource-policy` annotation:

```yaml
persistence:
  annotations:
    "helm.sh/resource-policy": keep
```

To use a previously created PVC / volume, use the following: 

```yaml
 existingGiteaClaim: gitea-gitea
```

## Ingress And External Host/Ports

Gitea requires ports to be exposed for accessibility. The recommended way is using **ingress**, however, you can supply `LoadBalancer` to your values alternatively.

By default, we expose via an ingress:

To expose via an ingress:

```yaml
ingress:
  enabled: true
```

To expose the web application this chart will generate an ingress using the ingress controller of choice if specified. If an ingress is enabled services.http.externalHost must be specified. To expose SSH services it relies on either a LoadBalancer or NodePort.

## Upgrading

When upgrading, make sure you have the following enabled:

  - Persistency for both mariadb + Gitea
  - Using `existingGiteaClaim`
  - Due to using the [bitnami/mariadb](https://github.com/helm/charts/tree/master/stable/mariadb) chart, make sure to HARDCODE your passwords within `values.yaml`.  Or else you'll be unable to update mariadb

## Configuration

Refer to [values.yaml](values.yaml) for the full run-down on defaults.

The following table lists the configurable parameters of this chart and their default values.

| Parameter                             | Description                                                                                                                  | Default                   |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------|---------------------------|
| `images.gitea`                        | `gitea` image                                                                                                                | `gitea/gitea:1.9.3`       |
| `images.memcached`                    | `memcached` image                                                                                                            | `memcached:1.5.19-alpine` |
| `images.pullPolicy`                   | Image pull policy                                                                                                            | `IfNotPresent`            |
| `images.pullSecrets`                  | Specify an array of pull secrets                                                                                             | `[]`                      |
| `memcached.maxItemMemory`             | Max item memory                                                                                                              | `64`                      |
| `memcached.verbosity`                 | Verbosity                                                                                                                    | `v`                       |
| `memcached.extendedOptions`           | Extended options for memcached                                                                                               | `modern`                  |
| `ingress.enabled`                     | Switch to create ingress for this chart deployment                                                                           | `true`                    |
| `ingress.hostname `                   | Hostname to be used for the ingress                                                                                          | `gitea.local`             |
| `ingress.certManager`                 | Asks if we want to use cert-manager or not (let's encrypt, etc.)                                                             | `true`                    |
| `ingress.annotations`                 | Annotations used by the ingress                                                                                              | `[]`                      |
| `ingress.hosts `                      | Additional hosts to be used by the ingress                                                                                   | `[]`                      |
| `ingress.tls `                        | TLS secret keys to be used with Gitea                                                                                        | `[]`                      |
| `service.http.serviceType`            | type of kubernetes services used for http i.e. ClusterIP, NodePort or LoadBalancer                                           | `ClusterIP`               |
| `service.http.port`                   | http port for web traffic                                                                                                    | `3000`                    |
| `service.http.NodePort`               | Manual NodePort for web traffic                                                                                              | `nil`                     |
| `service.http.externalPort`           | Port exposed on the internet by a load balancer or firewall that redirects to the ingress or NodePort                        | `8280`                    |
| `service.http.externalHost`           | IP or DNS name exposed on the internet by a load balancer or firewall that redirects to the ingress or Node for http traffic | `gitea.local`             |
| `service.ssh.serviceType`             | type of kubernetes services used for ssh i.e. ClusterIP, NodePort or LoadBalancer                                            | `ClusterIP`               |
| `service.ssh.port`                    | http port for web traffic                                                                                                    | `22`                      |
| `service.ssh.NodePort`                | Manual NodePort for ssh traffic                                                                                              | `nil`                     |
| `service.ssh.externalPort`            | Port exposed on the internet by a load balancer or firewall that redirects to the ingress or NodePort                        | `nil`                     |
| `service.ssh.externalHost`            | IP or DNS name exposed on the internet by a load balancer or firewall that redirects to the ingress or Node for http traffic | `gitea.local`             |
| `resources.gitea.requests.memory`     | gitea container memory request                                                                                               | `500Mi`                   |
| `resources.gitea.requests.cpu`        | gitea container request cpu                                                                                                  | `1000m`                   |
| `resources.gitea.limits.memory`       | gitea container memory limits                                                                                                | `2Gi`                     |
| `resources.gitea.limits.cpu`          | gitea container CPU/Memory resource requests/limits                                                                          | `1`                       |
| `resources.memcached.requests.memory` | memcached container memory request                                                                                           | `64Mi`                    |
| `resources.memcached.requests.cpu`    | memcached container request cpu                                                                                              | `50m`                     |
| `persistence.enabled`                 | Create PVCs to store gitea data                                                                               | `false`                   |
| `persistence.existingGiteaClaim`      | Already existing PVC that should be used for gitea data.                                                                     | `nil`                     |
| `persistence.giteaSize`               | Size of gitea pvc to create                                                                                                  | `10Gi`                    |
| `persistence.annotations`             | Annotations to set on created PVCs                                                                                           | `nil`                     |
| `persistence.storageClass`            | NStorageClass to use for dynamic provision if not 'default'                                                                  | `nil`                     |
| `mariadb.enabled`                     | Enable or diable mariadb                                                                                                     | `true`                    |
| `mariadb.replication.enabled`         | Enable or diable replication                                                                                                 | `false`                   |
| `mariadb.db.name`                     | Default name                                                                                                                 | `gitea`                   |
| `mariadb.db.user`                     | Default user                                                                                                                 | `gitea`                   |
| `mariadb.persistence.enabled`         | Enable or diable persistence                                                                                                 | `true`                    |
| `mariadb.persistence.accessMode`      | What access mode to use                                                                                                      | `ReadWriteOnce`           |
| `mariadb.persistence.size`            | What size of database to use                                                                                                 | `8Gi`                     |
| `externalDB.dbUser`                   | external db user                                                                                                             | ` unset`                  |
| `externalDB.dbPassword`               | external db password                                                                                                         | ` unset`                  |
| `externalDB.dbHost`                   | external db host                                                                                                             | ` unset`                  |
| `externalDB.dbPort`                   | external db port                                                                                                             | ` unset`                  |
| `externalDB.dbDatabase`               | external db database name                                                                                                    | ` unset`                  |
| `config.disableInstaller`             | Disable the installer                                                                                                        | `false`                   |
| `config.offlineMode`                  | Sets Gitea's Offline Mode. Values are `true` or `false`.                                                                     | `false`                   |
| `config.requireSignin`                | Require Gitea user to be signed in to see any pages. Values are `true` or `false`.                                           | `false`                   |
| `config.disableRegistration`          | Disable Gitea's user registration. Values are `true` or `false`.                                                             | `false`                   |
| `config.openidSignin`                 | Allow login with OpenID. Values are `true` or `false`.                                                                       | `true`                    |
| `nodeSelector`                        | Node to be selected                                                                                                          | `{}`                      |
| `affinity`                            | Affinity settings for pod assignment                                                                                         | `{}`                      |
| `tolerations`                         | Toleration labels for pod assignment                                                                                         | `[]`                      |
| `deploymentAnnotations`               | Deployment annotations to be used                                                                                            | `{}`                      |
| `podAnnotations`                      | Pod deployment annotations to be used                                                                                        | `{}`                      |
