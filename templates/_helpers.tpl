{{/*
Expand the name of the chart.
*/}}
{{- define "kobo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kobo.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kobo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kobo.labels" -}}
helm.sh/chart: {{ include "kobo.chart" . }}
{{ include "kobo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kobo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kobo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kobo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kobo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Guess the public kpi url, assume https
*/}}
{{- define "kobo.kpiUrl" -}}
{{- if .Values.kpi.ingress.enabled }}
{{- with (first .Values.kpi.ingress.hosts) }}https://{{ .host }}{{- end }}{{- end }}
{{- end }}

{{/*
Guess the public kobocat url, assume https
*/}}
{{- define "kobo.kobocatUrl" -}}
{{- if .Values.kobocat.ingress.enabled }}
{{- with (first .Values.kobocat.ingress.hosts) }}https://{{ .host }}{{- end }}{{- end }}
{{- end }}

{{/*
Guess the public enketo at url, assume https
*/}}
{{- define "kobo.enketoUrl" -}}
{{- if .Values.enketo.ingress.enabled }}
{{- with (first .Values.enketo.ingress.hosts) }}https://{{ .host }}{{- end }}{{- end }}
{{- end }}

{{- define "kobo.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}-postgresql
{{- else -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL connection URL
Requires POSTGRES_PASSWORD to be set environment variable
*/}}
{{- define "kobo.postgresql.url" -}}
{{- printf "postgres://%s:$(POSTGRES_PASSWORD)@%s:5432/%s" .Values.postgresql.auth.username (include "kobo.postgresql.fullname" .) .Values.kpi.env.normal.KPI_DATABASE_NAME -}}
{{- end -}}

{{/*
PostgreSQL connection URL for KoboCat
Requires POSTGRES_PASSWORD to be set environment variable
*/}}
{{- define "kobo.postgresql.kc_url" -}}
{{- printf "postgis://%s:$(POSTGRES_PASSWORD)@%s:5432/%s" .Values.postgresql.auth.username (include "kobo.postgresql.fullname" .) .Values.kobocat.env.normal.KOBOCAT_DATABASE_NAME -}}
{{- end -}}


{{- define "kobo.mongodb.fullname" -}}
{{- if .Values.mongodb.fullnameOverride -}}
{{- .Values.mongodb.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.mongodb.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}-mongodb
{{- else -}}
{{- printf "%s-%s" .Release.Name "mongodb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
MongoDB connection URL
Requires MONGODB_PASSWORD to be set environment variable
*/}}
{{- define "kobo.mongodb.url" -}}
{{- if .Values.kobotoolbox.mongoDatabase -}}
{{- .Values.kobotoolbox.mongoDatabase -}}
{{- else -}}
{{- if eq .Values.mongodb.architecture "replicaset" -}}
{{- printf "mongodb://%s:$(MONGODB_PASSWORD)@%s-headless:27017/%s?replicaSet=rs0" (first .Values.mongodb.auth.usernames) (include "kobo.mongodb.fullname" .) (first .Values.mongodb.auth.databases) -}}
{{- else -}}
{{- printf "mongodb://%s:$(MONGODB_PASSWORD)@%s:27017/%s" (first .Values.mongodb.auth.usernames) (include "kobo.mongodb.fullname" .) (first .Values.mongodb.auth.databases) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "kobo.redis.fullname" -}}
{{- if .Values.redis.fullnameOverride -}}
{{- .Values.redis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.redis.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}-redis
{{- else -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Redis connection URL (without DB number)
Requires REDIS_PASSWORD to be set environment variable
*/}}
{{- define "kobo.redis.url" -}}
{{- printf "redis://:$(REDIS_PASSWORD)@%s-master:6379" (include "kobo.redis.fullname" .) -}}
{{- end -}}
