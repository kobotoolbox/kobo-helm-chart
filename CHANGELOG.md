4.0.0

First stable release. We will begin posting changelogs for future work on the helm chart. A best effort will be given to use semantic versioning. However, breaking changes could still appear and we cannot test every combination of helm chart with each version of kobotoolbox. This project is still recommended only for advanced users.

- Remove all kobocat services (web and worker)
- Add kpi celery worker for kobocat queue
- Rename preInstall job and values to migrationJob
- Rebase (manually not actually with git) some features from django-helm-chart
- Major version upgrades on chart dependencies. 
