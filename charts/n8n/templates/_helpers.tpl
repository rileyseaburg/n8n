{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "n8n.fullname" -}}
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
{{- define "n8n.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Worker selector labels
*/}}
{{- define "n8n.workerSelectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Redis selector labels
*/}}
{{- define "n8n.redisSelectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL selector labels
*/}}
{{- define "n8n.postgresqlSelectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}-postgresql
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "n8n.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "n8n.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the image name
*/}}
{{- define "n8n.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{- if $registry -}}
{{ $registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- else -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end }}

{{/*
Get the Redis image name
*/}}
{{- define "n8n.redisImage" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.queue.redis.image.registry -}}
{{- if $registry -}}
{{ $registry }}/{{ .Values.queue.redis.image.repository }}:{{ .Values.queue.redis.image.tag }}
{{- else -}}
{{ .Values.queue.redis.image.repository }}:{{ .Values.queue.redis.image.tag }}
{{- end -}}
{{- end }}

{{/*
Get the PostgreSQL image name
*/}}
{{- define "n8n.postgresqlImage" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.database.postgresql.image.registry -}}
{{- if $registry -}}
{{ $registry }}/{{ .Values.database.postgresql.image.repository }}:{{ .Values.database.postgresql.image.tag }}
{{- else -}}
{{ .Values.database.postgresql.image.repository }}:{{ .Values.database.postgresql.image.tag }}
{{- end -}}
{{- end }}

{{/*
Get the encryption key
*/}}
{{- define "n8n.encryptionKey" -}}
{{- if .Values.n8n.encryptionKey }}
{{- .Values.n8n.encryptionKey }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
Get database type for n8n
*/}}
{{- define "n8n.databaseType" -}}
{{- if eq .Values.database.type "sqlite" }}sqlite{{- end }}
{{- if eq .Values.database.type "postgresdb" }}postgresdb{{- end }}
{{- if eq .Values.database.type "mysqldb" }}mysqldb{{- end }}
{{- if eq .Values.database.type "mariadb" }}mariadb{{- end }}
{{- end }}

{{/*
Common n8n environment variables
*/}}
{{- define "n8n.commonEnv" -}}
- name: N8N_HOST
  value: {{ .Values.n8n.host | quote }}
- name: N8N_PORT
  value: {{ .Values.n8n.port | quote }}
- name: N8N_PROTOCOL
  value: {{ .Values.n8n.protocol | quote }}
- name: N8N_USER_FOLDER
  value: {{ .Values.n8n.userFolder | quote }}
- name: N8N_DIAGNOSTICS_ENABLED
  value: {{ .Values.n8n.diagnosticsEnabled | quote }}
- name: N8N_VERSION_NOTIFICATIONS_ENABLED
  value: {{ .Values.n8n.versionNotificationsEnabled | quote }}
{{- if .Values.n8n.versionNotificationsInfoUrl }}
- name: N8N_VERSION_NOTIFICATIONS_INFO_URL
  value: {{ .Values.n8n.versionNotificationsInfoUrl | quote }}
{{- end }}
- name: EXECUTIONS_DATA_MAX_AGE
  value: {{ .Values.n8n.executions.dataMaxAge | quote }}
- name: EXECUTIONS_DATA_PRUNE_MAX_COUNT
  value: {{ .Values.n8n.executions.dataPruneMaxCount | quote }}
- name: EXECUTIONS_TIMEOUT
  value: {{ .Values.n8n.executions.timeout | quote }}
- name: EXECUTIONS_TIMEOUT_MAX
  value: {{ .Values.n8n.executions.maxTimeout | quote }}
- name: N8N_CONCURRENCY_PRODUCTION_LIMIT
  value: {{ .Values.n8n.executions.concurrencyProduction | quote }}
- name: WORKFLOWS_CALLER_POLICY_DEFAULT_OPTION
  value: {{ .Values.n8n.workflows.callerPolicyDefaultOption | quote }}
- name: TZ
  value: {{ .Values.timezone | quote }}
{{- if .Values.n8n.taskRunners.enabled }}
- name: N8N_RUNNERS_ENABLED
  value: "true"
- name: N8N_RUNNERS_MODE
  value: {{ .Values.n8n.taskRunners.mode | quote }}
{{- if .Values.n8n.taskRunners.python.enabled }}
- name: N8N_NATIVE_PYTHON_RUNNER
  value: "true"
{{- end }}
{{- end }}
{{- if .Values.n8n.security.auditLogEnabled }}
- name: N8N_AUDIT_LOG_ENABLED
  value: "true"
{{- end }}
{{- if .Values.n8n.externalSecrets.enabled }}
- name: N8N_EXTERNAL_SECRETS_ENABLED
  value: "true"
- name: N8N_EXTERNAL_SECRETS_UPDATE_INTERVAL
  value: {{ .Values.n8n.externalSecrets.updateInterval | quote }}
{{- end }}
{{- end }}

{{/*
Database environment variables
*/}}
{{- define "n8n.databaseEnv" -}}
- name: DB_TYPE
  value: {{ include "n8n.databaseType" . }}
{{- if eq .Values.database.type "postgresdb" }}
{{- if .Values.database.postgresql.external }}
- name: DB_POSTGRESDB_HOST
  value: {{ .Values.database.postgresql.host | quote }}
- name: DB_POSTGRESDB_PORT
  value: {{ .Values.database.postgresql.port | quote }}
{{- else }}
- name: DB_POSTGRESDB_HOST
  value: {{ include "n8n.fullname" . }}-postgresql
- name: DB_POSTGRESDB_PORT
  value: "5432"
{{- end }}
- name: DB_POSTGRESDB_DATABASE
  value: {{ .Values.database.postgresql.database | quote }}
- name: DB_POSTGRESDB_USER
  value: {{ .Values.database.postgresql.username | quote }}
- name: DB_POSTGRESDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "n8n.fullname" . }}-db-secret
      key: password
- name: DB_POSTGRESDB_SCHEMA
  value: {{ .Values.database.postgresql.schema | quote }}
{{- if .Values.database.postgresql.ssl }}
- name: DB_POSTGRESDB_SSL_ENABLED
  value: "true"
{{- end }}
{{- else if eq .Values.database.type "mysqldb" }}
- name: DB_MYSQLDB_HOST
  value: {{ .Values.database.mysql.host | quote }}
- name: DB_MYSQLDB_PORT
  value: {{ .Values.database.mysql.port | quote }}
- name: DB_MYSQLDB_DATABASE
  value: {{ .Values.database.mysql.database | quote }}
- name: DB_MYSQLDB_USER
  value: {{ .Values.database.mysql.username | quote }}
- name: DB_MYSQLDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "n8n.fullname" . }}-db-secret
      key: password
{{- else if eq .Values.database.type "mariadb" }}
- name: DB_MYSQLDB_HOST
  value: {{ .Values.database.mariadb.host | quote }}
- name: DB_MYSQLDB_PORT
  value: {{ .Values.database.mariadb.port | quote }}
- name: DB_MYSQLDB_DATABASE
  value: {{ .Values.database.mariadb.database | quote }}
- name: DB_MYSQLDB_USER
  value: {{ .Values.database.mariadb.username | quote }}
- name: DB_MYSQLDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "n8n.fullname" . }}-db-secret
      key: password
{{- end }}
{{- end }}

{{/*
Queue environment variables
*/}}
{{- define "n8n.queueEnv" -}}
{{- if eq .Values.executionMode "queue" }}
- name: EXECUTIONS_MODE
  value: "queue"
{{- if .Values.queue.redis.external }}
- name: QUEUE_BULL_REDIS_HOST
  value: {{ .Values.queue.redis.host | quote }}
- name: QUEUE_BULL_REDIS_PORT
  value: {{ .Values.queue.redis.port | quote }}
{{- if .Values.queue.redis.username }}
- name: QUEUE_BULL_REDIS_USERNAME
  value: {{ .Values.queue.redis.username | quote }}
{{- end }}
{{- if .Values.queue.redis.password }}
- name: QUEUE_BULL_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "n8n.fullname" . }}-redis-secret
      key: password
{{- end }}
{{- if .Values.queue.redis.database }}
- name: QUEUE_BULL_REDIS_DB
  value: {{ .Values.queue.redis.database | quote }}
{{- end }}
{{- else if .Values.queue.redis.deploy }}
- name: QUEUE_BULL_REDIS_HOST
  value: {{ include "n8n.fullname" . }}-redis
- name: QUEUE_BULL_REDIS_PORT
  value: "6379"
{{- end }}
- name: QUEUE_HEALTH_CHECK_ACTIVE
  value: "true"
{{- end }}
{{- end }}