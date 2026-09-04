# KoboToolbox Helm Chart

This chart is intended for high availability instances of KoboToolbox. Small and casual instances should use [kobo-install](https://github.com/kobotoolbox/kobo-install).

This chart is still being tested and isn't intended for external use at this time. Versions may change for no reason at all or breaking changes may apply without updating the version.

# Design decisions

- As generic as possible, agnostic about the environment variables set for each service
- Supports high availability via k8s's horizontal pod autoscaler (HPA), pod disruption budget (PDB), and topology spread constraints
- Stick to defaults and conventions from `helm create` when possible
- Every deployment/job should do one thing. Migrate, run uwsgi, run celery, etc

# Usage
This chart requires values for `kpi.version` and `enketo.version` - there are no defaults set for them.

1. Carefully review values.yaml. Set image tag version, if desired. Set databases, secret keys, etc.
1. `helm install your-kobo oci://ghcr.io/kobotoolbox/kobo -f your-values.yaml --set kpi.version=VERSION_TO_DEPLOY --set enketo.version=VERSION_TO_DEPLOY`

## Nginx SSL

To enable SSL on the KPI nginx sidecar, create a Kubernetes TLS secret and reference it in your values.

**Using a self-signed certificate:**

```bash
# Generate a self-signed certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=your-domain.example.com/O=your-org"

# Create the Kubernetes secret
kubectl create secret tls my-kobo-tls \
  --cert=tls.crt \
  --key=tls.key \
  --namespace your-namespace
```

Then enable SSL in your values:

```yaml
kpi:
  nginx:
    ssl:
      enabled: true
      certSecret: my-kobo-tls
```

The secret must contain `tls.crt` and `tls.key` keys (the default when created with `kubectl create secret tls`).

## Upgrading
This chart requires values for `kpi.version` and `enketo.version` - there are no defaults set for them.

1. `helm repo update`
1. `helm upgrade your-kobo kobo -f your-values.yaml --set kpi.version=VERSION_TO_DEPLOY --set enketo.version=VERSION_TO_DEPLOY`

Tip: Consider using helm diff to preview changes first.

# Acknowledgements

Includes ideas from:

- https://gitlab.com/burke-software/django-helm-chart
- https://github.com/one-acre-fund/kobo-k8s/
- unicef helm chart
