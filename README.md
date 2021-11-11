# KoBo Toolbox Helm Chart

This chart is intended for high availability instances of KoBo Toolbox. Small and casual instances should use [kobo-install](https://github.com/kobotoolbox/kobo-install). 

# Design decisions

- Does not include databases - expects only environment variables for external databases
- As generic as possible, agnostic about the environment variables set for each service
- Supports high availability via k8s's horizontal pod autoscaler (HPA), pod disruption budget (PDB), and topology spread constraints
- Stick to defaults and conventions from `helm create` when possible
- Every deployment/job should do one thing. Migrate, run uwsgi, run celery, etc

# Usage

Carefully review values.yaml

Set image tag versions yourself, do not set to latest.

## Upgrading



# Acknowledgements

Includes ideas from:

- https://gitlab.com/burke-software/django-helm-chart
- https://github.com/one-acre-fund/kobo-k8s/
- unicef helm chart
