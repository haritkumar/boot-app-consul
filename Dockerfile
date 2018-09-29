FROM alpine:3.7
LABEL MAINTAINER="Harit Kumar <harit_kumar@optum.com>" 

ENV CONSUL_VERSION=1.2.3
ENV HASHICORP_RELEASES=https://releases.hashicorp.com

RUN addgroup consul && \
    adduser -S -G consul consul

# Set up certificates, base tools, and Consul.
RUN set -eux && \
    apk add --no-cache ca-certificates curl dumb-init gnupg libcap openssl su-exec iputils && \
    gpg --keyserver pgp.mit.edu --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    apkArch="$(apk --print-arch)" && \
    case "${apkArch}" in \
        aarch64) consulArch='arm64' ;; \
        armhf) consulArch='arm' ;; \
        x86) consulArch='386' ;; \
        x86_64) consulArch='amd64' ;; \
        *) echo >&2 "error: unsupported architecture: ${apkArch} (see ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/)" && exit 1 ;; \
    esac && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    grep consul_${CONSUL_VERSION}_linux_${consulArch}.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg && \
# tiny smoke test to ensure the binary we downloaded runs
    consul version

# The /consul/data dir is used by Consul to store state. 
# The agent will be started with /consul/config as the configuration directory
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul


# set up nsswitch.conf for Go's "netgo" implementation which is used by Consul,
# otherwise DNS supercedes the container's hosts file, which we don't want.
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf    
VOLUME /consul/data

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
EXPOSE 8301 8301/udp 8302 8302/udp

# HTTP and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
EXPOSE 8600 8600/udp

# NGINX
ENV HTPASSWD='foo:$apr1$odHl5EJN$KbxMfo86Qdve2FH4owePn.' \
    FORWARD_PORT=8500 \
    FORWARD_HOST=127.0.0.1

RUN apk add nginx && \
    apk add --no-cache gettext && \
    apk add bash curl nmap ca-certificates logrotate tzdata && \
    rm -rf /var/cache/apk/* /tmp/*

COPY nginx/auth.conf nginx/auth.htpasswd nginx/launch.sh ./
RUN mkdir -p /run/nginx 
RUN adduser -S -G consul www-data  
# NGINX

RUN chown -R consul:consul /var/lib /var/tmp /var/log /usr/local  && \
    chmod -R 766 /var/lib /var/tmp /var/log /usr/local /etc/nginx /run/nginx && \
    chmod u+s /sbin/su-exec

RUN chown -R consul:www-data /etc/nginx /run/nginx /var/log/nginx 

COPY consul/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER consul

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-dev", "-client", "0.0.0.0"]