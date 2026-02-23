# ASP Fantasy Setup

## Setup Auth

```bash
export DIR=apps/green/asp-fantasy
```

1. Create a `Secret` with basic auth credentials

```bash
htpasswd -Bbn $ASP_FANTASY_USER $ASP_FANTASY_PASSWORD > $DIR/asp-fantasy-auth
kubectl create secret generic asp-fantasy-admin-auth \
  --namespace asp-fantasy \
  --from-file=users=$DIR/asp-fantasy-auth \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=$SEALED_SECRET_CERT \
    > $DIR/secret-asp-fantasy-admin-auth.yaml
rm -rf $DIR/asp-fantasy-auth
```
