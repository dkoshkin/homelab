# Observability Setup

## Setup Alertmanager Slack Webhook

```bash
export DIR=infrastructure/base/observability/kube-prometheus-stack
```

1. Create a `SealedSecret` with the Slack webhook URL

```bash
kubectl create secret generic alertmanager-slack-webhook \
  --namespace observability \
  --from-literal webhook-url=$SLACK_URL \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=$SEALED_SECRET_CERT \
    > $DIR/alertmanager-slack-webhook.yaml
```
