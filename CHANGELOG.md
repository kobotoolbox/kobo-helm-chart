# 6.0.0
- MongoDB 8 upgrade
  ACTION NEEDED IF USING THE MONGO DEPENDENCY:
  This upgrade involves downtime. You will likely have to scale the mongo deployment to 0 replicas and then back up in order to avoid Multi-Attach error for volume errors.
  Once the mongo 8 pod is healthy you will need to manually run this command in the instance afterwards: `db.adminCommand( { setFeatureCompatibilityVersion: "8.0", confirm: true } )`

# 4.0.5

- kpi "2.024.33"

# 4.0.1

- kpi "2.024.25a"

# 4.0.0

First stable release. We will begin posting changelogs for future work on the helm chart. A best effort will be given to use semantic versioning. However, breaking changes could still appear and we cannot test every combination of helm chart with each version of kobotoolbox. This project is still recommended only for advanced users.

- Remove all kobocat services (web and worker)
- Add kpi celery worker for kobocat queue
- Rename preInstall job and values to migrationJob
- Rebase (manually not actually with git) some features from django-helm-chart
- Major version upgrades on chart dependencies. 

## Upgrade Instructions

- Add KOBOCAT_URL environment variable to kpi set to full domain with protocol (https://kc.example.com)
- value "preInstall" renamed to "migrationJob". If you don't override this, you don't need to do anything.
- Remove kobocat service values
- Ensure that all Postgres connection strings use postgis protocol (postgis://example.com/db). Do not use postgres://example.com/db.
- Move kobocat ingress to kpi ingress. Example: (yours may look different)
```
  ingress:
    enabled: true
    hosts:
      - host: kf.example.com
        paths:
          - path: /*
            pathType: ImplementationSpecific
      - host: kc.example.com
        paths:
          - path: /*
            pathType: ImplementationSpecific
```
