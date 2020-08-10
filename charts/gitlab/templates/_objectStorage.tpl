{{/*
Generates a templated object storage config.

Usage:
{{ include "gitlab.appConfig.objectStorage.configuration" ( \
     dict                                                   \
         "name" "STORAGE_NAME"                              \
         "config" .Values.path.to.objectstorage.config      \
         "context" $                                        \
     ) }}
*/}}
{{- define "gitlab.appConfig.objectStorage.configuration" -}}
object_store:
  enabled: {{ ne (default false .config.enabled) false }}
  remote_directory: {{ .config.bucket }}
  direct_upload: true
  background_upload: false
  proxy_download: {{ or (not (kindIs "bool" .config.proxy_download)) .config.proxy_download }}
  {{- if .config.connection }}
  connection: <%= YAML.load_file("/etc/gitlab/objectstorage/{{ .name }}").to_json() %>
  {{- else if .context.Values.global.minio.enabled }}
  {{- include "gitlab.appConfig.objectStorage.connection" . | nindent 2 }}
  {{- end -}}
{{- end -}}{{/* "gitlab.appConfig.objectStorage.configuration" */}}


{{- define "gitlab.appConfig.objectStorage.connection" -}}
connection:
  {{- if .context.Values.global.minio.enabled }}
  provider: AWS
  region: "us-east-1"
  host: {{ template "gitlab.minio.hostname" .context }}
  endpoint: {{ template "gitlab.minio.endpoint" .context }}
  path_style: true
  {{- else }}
  provider: {{ .context.Values.global.storage.connection.provider }}
  region: {{ .context.Values.global.storage.connetion.region }}

  {{- end }}
  aws_secret_access_key: "<%= File.read('/etc/gitlab/minio/secretkey').strip.dump[1..-2] %>"
  aws_access_key_id: "<%= File.read('/etc/gitlab/minio/accesskey').strip.dump[1..-2] %>"
{{- end }}


{{/*
Generates a templated object storage config.

Usage:
{{ include "gitlab.appConfig.objectStorage.mountSecrets" ( \
     dict                                                  \
         "name" "STORAGE_NAME"                             \
         "config" .Values.path.to.objectstorage.config     \
     ) }}
*/}}
{{- define "gitlab.appConfig.objectStorage.mountSecrets" -}}
# mount secret for {{ .name }}
{{- if .config.connection }}
- secret:
    name: {{ .config.connection.secret }}
    items:
      - key: {{ default "connection" .config.connection.key }}
        path: objectstorage/{{ .name }}
{{- end -}}
{{- end -}}{{/* "gitlab.appConfig.objectStorage.mountSecrets" */}}


{{/*
Generates a templated object storage config.

Usage:
{{ include "gitlab.appConfig.objectStorage.object" ( \
     dict                                                  \
         "name" "STORAGE_NAME"                             \
         "config" .Values.path.to.objectstorage.config     \
     ) }}
*/}}
{{- define "gitlab.appConfig.objectStorage.object" -}}
  {{- if .config.enabled -}}
{{ .name }}:
  bucket: {{ .config.bucket }}
  {{- end }}
{{- end }}
