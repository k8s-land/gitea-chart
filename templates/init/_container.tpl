{{/*
Create helm partial for gitea server
*/}}
{{- define "init" }}
- name: init
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  env:
  - name: MARIADB_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.mariadb.enabled }}
        name: {{ template "mariadb.fullname" . }}
        key: mariadb-password
      {{- else }}
        name: {{ printf "%s-%s" .Release.Name "externaldb" }}
        key: db-password
      {{- end }}
  - name: SCRIPT
    value: &script |-
      mkdir -p /datatmp/gitea/conf
      if [ ! -f /datatmp/gitea/conf/app.ini ]; then
        sed "s/MARIADB_PASSWORD/${MARIADB_PASSWORD}/g" < /etc/gitea/app.ini > /datatmp/gitea/conf/app.ini
      fi
  command: ["/bin/sh",'-c', *script]
  volumeMounts:
  - name: gitea-data
    mountPath: /datatmp
  - name: gitea-config
    mountPath: /etc/gitea
{{- end }}
