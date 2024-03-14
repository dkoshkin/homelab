# Clusters

## Set environment variables

```
source $(pwd)/kubernetes/clusters/.envs
```

## Bootstrap Flux

https://github.com/fluxcd/flux2

1.  Export Github token:

    ```
    export CLUSTER_NAME=green
    export GITHUB_TOKEN=<your-token>
    ```

2.  Bootstrap Flux

    ```
    flux bootstrap github \
    --components-extra=image-reflector-controller,image-automation-controller \
    --kubeconfig=$(pwd)/kubernetes/clusters/$CLUSTER_NAME.conf \
    --owner=dkoshkin \
    --repository=homelab \
    --path=clusters/$CLUSTER_NAME \
    --read-write-key \
    --personal
    ```

3.  Create Slack notifier Secret

    ```bash
    kubectl create secret generic slack-url \
    --kubeconfig=$(pwd)/kubernetes/clusters/$CLUSTER_NAME.conf \
    --namespace flux-system \
    --from-literal address=$SLACK_URL
    ```

4.  Create the Slack notifier Provider

    ```bash
    kubectl create \
    --kubeconfig=$(pwd)/kubernetes/clusters/$CLUSTER_NAME.conf \
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

mkdir -p $CLUSTER_SEALED_SECRETS_DIR
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


1.  Setup Cert Manager

    ```bash
    cat <<EOF >$CLUSTER_SEALED_SECRETS_DIR/cloudflare-api-token.yaml
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: cert-manager
    ---
    EOF
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

