{{/*
Create helm partial for gitea server
*/}}
{{- define "init" }}
- name: init
  image: {{ .Values.images.gitea }}
  imagePullPolicy: {{ .Values.images.pullPolicy }}
  env:
  - name: SCRIPT
    value: &script |-
      mkdir -p /datatmp/gitea/conf

      if [ -f /etc/gitea-secret/internal-token ]; then
        cp /etc/gitea-secret/internal-token /datatmp/gitea/conf/internal-token
      fi
      if [ ! -f /datatmp/gitea/conf/internal-token ]; then
        # File must exist, Gitea will generate the content if empty.
        touch /datatmp/gitea/conf/internal-token
      fi

      {{- if not .Values.config.immutableConfig }}
      if [ -f /datatmp/gitea/conf/app.ini ]; then
        chmod u+w /datatmp/gitea/conf/app.ini
        exit
      fi
      {{- end }}

      sed "s/HELM_DB_PASSWORD/$(cat /etc/database-secret/db-password)/g" < /etc/gitea/app.ini > /datatmp/gitea/conf/app.ini
      sed -i "s/HELM_SECRET_KEY/$([ -f /etc/gitea-secret/secret-key ] && cat /etc/gitea-secret/secret-key || gitea generate secret SECRET_KEY)/g" /datatmp/gitea/conf/app.ini
      sed -i "s/HELM_JWT_SECRET/$([ -f /etc/gitea-secret/jwt-secret ] && cat /etc/gitea-secret/jwt-secret || gitea generate secret JWT_SECRET)/g" /datatmp/gitea/conf/app.ini
      sed -i "s/HELM_LFS_JWT_SECRET/$([ -f /etc/gitea-secret/lfs-jwt-secret ] && cat /etc/gitea-secret/lfs-jwt-secret || gitea generate secret LFS_JWT_SECRET)/g" /datatmp/gitea/conf/app.ini

      {{- if .Values.config.immutableConfig }}
      chmod a-w /datatmp/gitea/conf/app.ini
      {{- end }}
  command: ["/bin/sh",'-c', *script]
  volumeMounts:
  - name: gitea-data
    mountPath: /datatmp
  - name: gitea-config
    mountPath: /etc/gitea
    readOnly: true
  - name: database-secret
    mountPath: /etc/database-secret
    readOnly: true
  - name: gitea-secret
    mountPath: /etc/gitea-secret
    readOnly: true
{{- end }}
