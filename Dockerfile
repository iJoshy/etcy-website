FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

RUN chmod 0644 /etc/nginx/conf.d/default.conf /usr/share/nginx/html/index.html \
    && test -s /usr/share/nginx/html/index.html \
    && nginx -t

EXPOSE 8080
