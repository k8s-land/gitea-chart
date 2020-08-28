{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 24 -}}
{{- end -}}

{{- define "mariadb.fullname" -}}
{{- printf "%s-%s" .Release.Name "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*    
Return the appropriate apiVersion for ingress.    
*/}}    
{{- define "gitea.ingress.apiVersion" -}}    
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}    
{{- print "extensions/v1beta1" -}}    
{{- else -}}    
{{- print "networking.k8s.io/v1beta1" -}}    
{{- end -}}    
{{- end -}}  

{{- define "gitea-secret-name" -}}
{{- if .Values.config.secretName -}}
    {{ .Values.config.secretName }}
{{- else -}}
    {{ template "fullname" . }}
{{- end -}}
{{- end -}}

{{- define "db-secret-name" -}}
{{- if .Values.mariadb.enabled -}}
    {{- if .Values.mariadb.existingSecret -}}
        {{ .Values.mariadb.existingSecret }}
    {{- else -}}
        {{ template "mariadb.fullname" . }}
    {{- end -}}
{{- else -}}
    {{- if .Values.externalDB.secretName -}}
        {{ .Values.externalDB.secretName }}
    {{- else -}}
        {{ printf "%s-externalDB" (include "fullname" .) }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "db-secret-key" -}}
{{- if .Values.mariadb.enabled -}}
    {{- print "mariadb-password" -}}
{{- else -}}
    {{ .Values.externalDB.passwordKey }}
{{- end -}}
{{- end -}}