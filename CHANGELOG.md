# 6.1.0
- Move from Redis to Valkey.

  The dependency is aliased as "redis", so every resource keeps the name it already has and
  the `kobo.redis.*` template helpers work unchanged. Only the values shape changes.

  ACTION NEEDED IF USING THE REDIS/VALKEY DEPENDENCY:

  The `redis:` values follow the upstream chart now, so a few keys moved:

  | was                            | is now                                |
  | ------------------------------ | ------------------------------------- |
  | `auth.password`                | `auth.aclUsers.default.password`      |
  | `commonConfiguration`          | `valkeyConfig`                        |
  | `master.persistence.size`      | `dataStorage.requestedSize`           |
  | `master.resources`             | `resources` (top level now)           |
  | `architecture`, `sentinel.*`   | gone - standalone renders a Deployment|

  Valkey authenticates with ACL users rather than a single password. A `default` user is
  required; clients connecting as `redis://:password@host` authenticate as that user, so
  existing connection strings keep working.

  Two names change on the cluster: the password now lives in `<release>-redis-auth` under the
  key `default-password`, and the service loses its suffix - connect to `<release>-redis`
  rather than `<release>-redis-master`. If you pinned `redis.image.*`, drop it.

  ## Migrating without losing your data

  The new chart can adopt the volume your old redis was already using, so there is no dump
  and restore. Point it at the existing claim:

      redis:
        dataStorage:
          persistentVolumeClaimName: "redis-data-{{ .Release.Name }}-redis-master-0"

  Scale the old StatefulSet to 0 first so it lets go of the volume - it is ReadWriteOnce, and
  the new pod cannot attach until the old one is gone:

      kubectl scale statefulset <release>-redis-master --replicas=0

  Then upgrade as usual. The new pod mounts the same volume and loads the existing dump, so
  sessions, queued tasks and cache all survive. Expect well under a minute of downtime.

  One thing to be aware of: once an instance uses `persistentVolumeClaimName` it should keep
  using it. Removing the setting later makes the chart provision a fresh empty volume instead
  of the one holding your data.

  A note on `--reuse-values`: it keeps the previous release's values but drops this chart's
  own `redis:` defaults, so anything the chart would normally supply (the ACL user, the
  memory config, resources) silently falls back to whatever the old release had. If you
  deploy that way, set those explicitly in your own values file.

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
