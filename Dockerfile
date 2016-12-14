FROM nginx:1.10

MAINTAINER Stan Angeloff <stanimir@psp-webtech.co.uk>

# Install the Nginx Uploads module.
#
# The source is downloaded from GitHub as the officially published 2.2 archive is not compatible with Nginx 1.10.
# At the time of writing this, the latest commit is aba1e3f made on 5 Dec 2014.
#
RUN cd /tmp && mkdir nginx && cd nginx && \
	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests curl && \
	curl -O https://nginx.org/keys/nginx_signing.key && apt-key add ./nginx_signing.key && \
	echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests dpkg-dev && \
	apt-get source nginx=$NGINX_VERSION && \
	apt-get build-dep -y nginx && \
	apt-get install -y libgd2-xpm-dev libgeoip-dev libperl-dev libxslt1-dev && \
	curl -LO https://github.com/vkholodkov/nginx-upload-module/archive/2.2.tar.gz && tar zxvf 2.2.tar.gz && \
	awk 'BEGIN { m=0 } /^COMMON_CONFIGURE_ARGS/ { if (m==0) { m=1 ; print ; print "\t--add-module=/tmp/nginx/nginx-upload-module-2.2 \\" ; next } } { print }' "nginx-${NGINX_VERSION%%-*}"/debian/rules > rules && mv rules "nginx-${NGINX_VERSION%%-*}"/debian/rules && \
	cd "nginx-${NGINX_VERSION%%-*}" && \
	dpkg-buildpackage -b && \
	dpkg -i ../"nginx_${NGINX_VERSION%%-*}"*.deb ../nginx-module-*.deb && \
	cd /tmp/ && rm -R nginx && \
	apt-get purge -y curl dpkg-dev libgd2-xpm-dev libgeoip-dev libperl-dev libxslt1-dev && \
	apt-get autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*
