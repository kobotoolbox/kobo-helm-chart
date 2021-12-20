# KoBo Toolbox Helm Chart

This chart is intended for high availability instances of KoBo Toolbox. Small and casual instances should use [kobo-install](https://github.com/kobotoolbox/kobo-install). 

This chart is not stable and should probably not be used at all. Versions may change for no reason at all or breaking changes may apply without updating the version.

# Design decisions

- Does not include databases - expects only environment variables for external databases
- As generic as possible, agnostic about the environment variables set for each service
- Supports high availability via k8s's horizontal pod autoscaler (HPA), pod disruption budget (PDB), and topology spread constraints
- Stick to defaults and conventions from `helm create` when possible
- Every deployment/job should do one thing. Migrate, run uwsgi, run celery, etc

# Usage

1. `helm repo add kobo https://gitlab.com/api/v4/projects/32216873/packages/helm/stable`
1. Carefully review values.yaml. Set image tag version, do not set to latest. Set databases, secret keys, etc.
1. `helm install your-kobo kobo/kobo -f your-values.yaml`

## Upgrading

Upgrades are at your own risk.

1. `helm repo update`
1. `helm upgrade your-kobo kobo -f your-values.yaml`

Tip: Consider using helm diff to preview changes first.

# Acknowledgements

Includes ideas from:

- https://gitlab.com/burke-software/django-helm-chart
- https://github.com/one-acre-fund/kobo-k8s/
- unicef helm chart
