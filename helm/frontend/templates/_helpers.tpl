# templates/_helpers.tpl
{{/* Generate a fullname */}}
{{- define "frontend.fullname" -}}
{{- printf "%s-frontend" .Release.Name -}}
{{- end -}}