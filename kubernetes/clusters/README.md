# Clusters

## Create a management cluster

1.  Create the bootstrap cluster
    
    ```sh
    source ~/kubernetes-bootstrapper/.envs
    kind create cluster
    clusterctl init --infrastructure vsphere --wait-providers
    ```

1.  Create `ClusterClass` and templates:

    ```
    envsubst < ~/kubernetes-bootstrapper/clusterclass-template.yaml | kubectl create -f -
    ```

1.  Export cluster specific environment variables:

    ```sh
    export CLUSTER_NAME=blue
    export VSPHERE_FOLDER=/$VSPHERE_DATACENTER/vm/Kubernetes/Clusters/$CLUSTER_NAME
    export KUBERNETES_VERSION=v1.26.6
    export CPI_IMAGE_K8S_VERSION=v1.26.2
    export VSPHERE_TEMPLATE=photon-4-kube-$KUBERNETES_VERSION
    export CONTROL_PLANE_MACHINE_COUNT=1
    export WORKER_MACHINE_COUNT=2
    export CONTROL_PLANE_ENDPOINT_IP=192.168.69.200
    export VIP_NETWORK_INTERFACE=eth0
    ```

1.  Create `Cluster` objects:

    ```
    envsubst < ~/kubernetes-bootstrapper/cluster-template.yaml | kubectl create -f -
    ```

1.  After the cluster is craeted, get the kubeconfig file:

    ```
    clusterctl get kubeconfig $CLUSTER_NAME > ~/kubernetes-bootstrapper/$CLUSTER_NAME.conf
    ```

1.  Deploy Calico CNI:

    ```
    kubectl --kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml
    ```

1. Deploy the CAPI controllers on the cluster

    ```
    clusterctl init --infrastructure vsphere --kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf
    ```

1.  Make the cluster self-managed:

    ```
    clusterctl move --to-kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf
    ```

1. Clean up the bootstrap KIND cluster:

    ```
    kind delete cluster
    ```

## Create additonal clusters

1.  Export cluster specific environment variables:

    ```sh
    export CLUSTER_NAME=greem
    export VSPHERE_FOLDER=/$VSPHERE_DATACENTER/vm/Kubernetes/Clusters/Green
    export KUBERNETES_VERSION=v1.26.6
    export CPI_IMAGE_K8S_VERSION=v1.26.2
    export VSPHERE_TEMPLATE=photon-4-kube-$KUBERNETES_VERSION
    export CONTROL_PLANE_MACHINE_COUNT=1
    export WORKER_MACHINE_COUNT=2
    export CONTROL_PLANE_ENDPOINT_IP=192.168.69.210
    export VIP_NETWORK_INTERFACE=eth0
    ```

1.  Create `Cluster` objects:

    ```
    envsubst < cluster-template.yaml | kubectl create -f
    ```

1.  After the cluster is craeted, get the kubeconfig file:

    ```
    clusterctl get kubeconfig $CLUSTER_NAME > $(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf
    ```

2.  Deploy Calico CNI:

    ```
    kubectl --kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml
    ```

## Bootstrap Flux

https://github.com/fluxcd/flux2

1.  Export Github token:

    ```
    export CLUSTER_NAME=blue
    export GITHUB_TOKEN=<your-token>
    ```

2.  Bootstrap Flux

    ```
    flux bootstrap github \
    --kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf \
    --owner=dkoshkin \
    --repository=homelab \
    --path=clusters/$CLUSTER_NAME \
    --personal
    ```

3.  Create Slack notifier Secret

    ```bash
    kubectl create secret generic slack-url \
    --kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf \
    --namespace flux-system \
    --from-literal address=$SLACK_URL
    ```

4.  Create the Slack notifier Provider

    ```bash
    kubectl create \
    --kubeconfig=$(pwd)/kubernetes-bootstrapper/$CLUSTER_NAME.conf \
    -f - <<EOF
    apiVersion: notification.toolkit.fluxcd.io/v1beta2
    kind: Provider
    metadata:
      name: slack
      namespace: flux-system
    spec:
      type: slack
      channel: general
      secretRef:
        name: slack-url
    EOF
    ```

##  Cluster Sealed Secrets

Create [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) for shared infrastrucutere.

```bash
export CLUSTER_SEALED_SECRETS_DIR=infrastructure/$CLUSTER_NAME/secrets
export SEALED_SECRET_CERT=$CLUSTER_SEALED_SECRETS_DIR/sealed-secret-cert.pem
```

1.  Setup Weave Gitops

    ```bash
    kubectl create secret generic cluster-user-auth \
    --namespace flux-system \
    --from-literal username=$WEAVE_GITOPS_USERNAME \
    --from-literal password=$(echo -n $WEAVE_GITOPS_PASSWORD | gitops get bcrypt-hash) \
    --dry-run=client \
    -o yaml | \
    kubeseal \
        --format=yaml \
        --cert=$SEALED_SECRET_CERT \
        > $CLUSTER_SEALED_SECRETS_DIR/weave-gitops-cluster-user-auth.yaml
    ```

1.  Setup Prometheus Grafana

    ```bash
    kubectl create secret generic prometheus-stack-grafana \
    --namespace prometheus \
    --from-literal admin-user=$PROMETHEUS_GRAFANA_USERNAME \
    --from-literal admin-password=$PROMETHEUS_GRAFANA_PASSWORD \
    --from-literal ldap-toml="" \
    --dry-run=client \
    -o yaml | \
    kubeseal \
        --format=yaml \
        --cert=$SEALED_SECRET_CERT \
        > $CLUSTER_SEALED_SECRETS_DIR/prometheus-stack-grafana.yaml
    ```

1.  Setup Cert Manager

    ```bash
    kubectl create secret generic cloudflare-api-token \
    --namespace cert-manager \
    --from-literal api-token=$CLOUDFLARE_API_TOKEN \
    --dry-run=client \
    -o yaml | \
    kubeseal \
        --format=yaml \
        --cert=$SEALED_SECRET_CERT \
        > $CLUSTER_SEALED_SECRETS_DIR/cloudflare-api-token.yaml
    ```

