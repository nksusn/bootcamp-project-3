{{/* Define chart name */}}
{{- define "backend.name" -}}
{{ .Chart.Name }}
{{- end }}

{{/* Define full name */}}
{{- define "backend.fullname" -}}
{{ printf "%s-%s" .Release.Name (include "backend.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Define chart version */}}
{{- define "backend.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
