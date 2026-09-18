upstream backend {
    ip_hash;
    server 127.0.0.1:8005;
}

log_format with_host '$http_host | $remote_addr - $upstream_http_x_kobonaut [$time_local] '
    '"$request" $status ($body_bytes_sent bytes)"$http_referer" '
    '"$http_user_agent"';
    
server {

    client_max_body_size 100M;
    large_client_header_buffers 8 16k;
    access_log  /var/log/nginx/access.log with_host;

    {{ if .Values.kpi.nginx.large_headers.enabled -}}
    # Proxy buffer settings to handle large headers
    proxy_buffer_size {{ .Values.kpi.nginx.large_headers.proxy_buffer_size | default "32k" }};
    proxy_buffers {{ .Values.kpi.nginx.large_headers.proxy_buffers | default "8 32k" }};
    proxy_busy_buffers_size {{ .Values.kpi.nginx.large_headers.proxy_busy_buffers_size | default "64k" }};
    proxy_temp_file_write_size {{ .Values.kpi.nginx.large_headers.proxy_temp_file_write_size | default "64k" }};
    proxy_max_temp_file_size {{ .Values.kpi.nginx.large_headers.proxy_max_temp_file_size | default "1024m" }};
    proxy_buffering {{ .Values.kpi.nginx.large_headers.proxy_buffering | default "on" }};
    {{- end }}

    {{ $timeout := .Values.kpi.nginx.timeout | default (.Values.global.timeout | default 120) -}}
    # Set timeout values from Helm values
    proxy_read_timeout {{ $timeout }};
    proxy_send_timeout {{ $timeout }};
    {{- if .Values.kpi.nginx.timeout }}
    proxy_connect_timeout {{ .Values.kpi.nginx.timeout }};
    send_timeout {{ .Values.kpi.nginx.timeout }};
    {{- end }}

    gzip on;
    gzip_disable "msie6";
    gzip_comp_level 6;
    gzip_min_length 1100;
    gzip_buffers 16 8k;
    gzip_proxied any;
    gzip_types
        text/plain
        text/css
        text/js
        text/xml
        text/javascript
        application/javascript
        application/x-javascript
        application/json
        application/xml
        application/xml+rss
        image/svg+xml;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_hide_header Strict-Transport-Security; # Must be removed to not duplicate the header
        add_header Strict-Transport-Security "max-age={{ .Values.kpi.nginx.hsts_max_age }}" always;
        proxy_pass http://backend;
    }

    {{- if .Values.kpi.nginx.ssl.enabled }}
    listen 443 ssl default_server;
    ssl_certificate /etc/nginx/ssl/tls.crt;
    ssl_certificate_key /etc/nginx/ssl/tls.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    {{- else }}
    listen 80;
    {{- end }}
    server_tokens off;
}
