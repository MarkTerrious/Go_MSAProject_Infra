{{/*
Expand the name of the chart.
*/}}
{{- define "argo-resource.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-resource.fullname" -}}
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
{{- define "argo-resource.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}

{{- define "argo-prod-labels" -}}
env: "prod"
{{- end }}

{{- define "argo-local-labels" -}}
env: "local"
{{- end }}


{{- define "argo-resource.labels" -}}
{{- if eq .Values.deploy_env ""}}
{{ include "argo-local-labels" . }}
{{- end }}

{{- if eq .Values.deploy_env "prod"}}
{{ include "argo-prod-labels" . }}
{{- end }}

helm.sh/chart: {{ include "argo-resource.chart" . }}
{{ include "argo-resource.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-resource.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argo-resource.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argo-resource.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argo-resource.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
