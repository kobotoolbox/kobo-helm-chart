upstream backend {
    ip_hash;
    server 127.0.0.1:8000;
}

server {

    client_max_body_size 100M;
    large_client_header_buffers 8 16k;

    # Set timeout values from Helm values
    proxy_read_timeout {{ .Values.global.timeout | default 120 }};
    proxy_send_timeout {{ .Values.global.timeout | default 120 }};
    
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


    location ~ ^/protected-s3/(.*)$ {
        # Allow internal requests only, i.e. return a 404 to any client who
        # tries to access this location directly
        internal;
        # Name resolution won't work at all without specifying a resolver here.
        # Configuring a validity period is useful for overriding Amazon's very
        # short (5-second?) TTLs.
        resolver 8.8.8.8 8.8.4.4 valid=300s;
        resolver_timeout 10s;
        # Everything that S3 needs is in the URL; don't pass any headers or
        # body content that the client may have sent
        proxy_pass_request_body off;
        proxy_pass_request_headers off;

        # Stream the response to the client instead of trying to read it all at
        # once, which would potentially use disk space
        proxy_buffering off;

        # Don't leak S3 headers to the client. List retrieved from:
        # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html
        proxy_hide_header x-amz-delete-marker;
        proxy_hide_header x-amz-id-2;
        proxy_hide_header x-amz-request-id;
        proxy_hide_header x-amz-version-id;

        # S3 will complain if `$1` contains non-encoded special characters.
        # KoBoCAT must encode twice to make sure `$1` is still encoded after
        # NGINX's automatic URL decoding.
        proxy_pass $1;
    }

    location /static {
        alias /static;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://backend;
    }
    listen 80;
    server_tokens off;
}
