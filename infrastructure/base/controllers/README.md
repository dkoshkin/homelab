#  Cluster Controllers Setup

## Setup Weave Gitops

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
    > infrastructure/base/controllers/secret-weave-gitops-cluster-user-auth.yaml
```

## Setup Prometheus Grafana

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
    > infrastructure/base/controllers/secret-prometheus-stack-grafana.yaml
```
