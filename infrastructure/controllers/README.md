#  Cluster Controllers Setup

## Set Environment Variables

1. Fill out the env file

```bash
cd <repo>/clusters/microk8s/
mv .env.sample .env
source .env
```

## Setup Teslamate

```bash
kubectl create secret generic cluster-user-auth \
  --namespace flux-system \
  --from-literal username=$WEAVE_GITOPS_USERNAME \
  --from-literal password=$(echo -n $WEAVE_GITOPS_PASSWORD | gitops get bcrypt-hash) \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-weave-gitops-cluster-user-auth.yaml
```

