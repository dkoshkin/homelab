#  Cluster Configs Setup

## Setup Cert Manager

1. Create a `SealedSecret` for Let's Encrypt Cloudflare issuer

```bash
kubectl create secret generic cloudflare-api-token \
  --namespace cert-manager \
  --from-literal api-token=$CLOUDFLARE_API_TOKEN \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=$SEALED_SECRET_CERT \
    > secret-cloudflare-api-token.yaml
```
