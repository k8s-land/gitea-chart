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
