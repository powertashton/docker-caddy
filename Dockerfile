FROM alpine:latest
LABEL maintainer="dev@jpillora.com"
# webproc release settings
ENV WEBPROC_VERSION 0.4.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz
ENV CADDY_VERSION 2.10.2
ENV CADDY_URL https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_amd64.tar.gz
# fetch caddy and webproc binary (rely on ca root certs signing github.com for security)
RUN set -e && set -x
RUN apk update \
	&& apk add ca-certificates \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& curl -sL $CADDY_URL | gzip -d - | tar -xv -C /tmp -f - \
	&& mv /tmp/caddy /usr/local/bin/caddy \
	&& apk del .build-deps \
	&& rm -rf /tmp/* /var/cache/apk/*
#configure caddy
COPY Caddyfile /etc/Caddyfile
#run!
ENTRYPOINT ["webproc","-c","/etc/Caddyfile","--","caddy"]
CMD ["-agree", "-conf", "/etc/Caddyfile"]
