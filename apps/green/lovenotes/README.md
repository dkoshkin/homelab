# Lovenotes Setup

## Setup Auth

```bash
export DIR=apps/green/lovenotes
```

1. Create a `Secret` with basic auth credentials

```bash
htpasswd -Bbn $LOVENOTES_USER $LOVENOTES_PASSWORD > $DIR/lovenotes-auth
kubectl create secret generic lovenotes-admin-auth \
  --namespace lovenotes \
  --from-file=users=$DIR/lovenotes-auth \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=$SEALED_SECRET_CERT \
    > $DIR/secret-lovenotes-admin-auth.yaml
rm -rf $DIR/lovenotes-auth
```
