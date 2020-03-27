{{/*
Create helm partial for gitea server
*/}}
{{- define "gitea" }}
- name: gitea
  image: {{ .Values.images.gitea }}
  imagePullPolicy: {{ .Values.images.pullPolicy }}
  env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.mariadb.enabled }}
        name: {{ template "mariadb.fullname" . }}
        key: mariadb-password
      {{- else }}
        name: {{ printf "%s-%s" .Release.Name "externaldb" }}
        key: db-password
      {{- end }}
  ports:
  - name: ssh
    containerPort: 22
  - name: http
    containerPort: 3000
  livenessProbe:
    tcpSocket:
      port: http
    initialDelaySeconds: 200
    timeoutSeconds: 1
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 10
  readinessProbe:
    tcpSocket:
      port: http
    initialDelaySeconds: 5
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3
  resources:
{{ toYaml .Values.resources.gitea | indent 10 }}
  volumeMounts:
  - name: gitea-data
    mountPath: /data
  - name: gitea-config
    mountPath: /etc/gitea
{{- end }}
