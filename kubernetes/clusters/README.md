# Create a management cluster

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
    export VSPHERE_FOLDER=/$VSPHERE_DATACENTER/vm/Kubernetes/Clusters/Blue
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

# Create additonal clusters

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

# Bootstrap Flux

1.  Export Github token:

    ```
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
