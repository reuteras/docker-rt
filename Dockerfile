FROM debian:jessie
MAINTAINER Peter Reuterås <peter@reuteras.net>

## Install tools and libraries
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        build-essential \
        ca-certificates \
        cpanminus \
        curl \
        git \
        gpgv2 \
        graphviz \
        libexpat1-dev \
        libpq-dev \
        libgd-dev \
        libssl-dev \
        lighttpd \
        openssl \
        perl \
        postgresql-client \
        ssl-cert \
        supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

# Create user and group
RUN groupadd -r rt-service && \
    useradd -r -g rt-service -G www-data rt-service && \
    usermod -a -G rt-service www-data

# Perl settings -n to don't to tests
ENV RT_FIX_DEPS_CMD /usr/bin/cpanm
ENV PERL_CPANM_OPT -n

RUN mkdir -p --mode=750 /opt/rt4 && \
    mkdir -p /tmp/rt && \
    curl -SL https://download.bestpractical.com/pub/rt/release/rt.tar.gz | \
        tar -xzC /tmp/rt && \
    cd /tmp/rt/rt* && \
    echo "o conf init " | \
        perl -MCPAN -e shell && \
    ./configure \
        --enable-graphviz \
        --enable-gd \
        --enable-gpg \
        --with-web-handler=fastcgi \
        --with-bin-owner=rt-service \
        --with-libs-owner=rt-service \
        --with-libs-group=www-data \
        --with-db-type=Pg \
        --with-web-user=www-data \
        --with-web-group=www-data \
        --prefix=/opt/rt4 \
        --with-rt-group=rt-service && \
    make fixdeps && \
    make testdeps && \
    make config-install dirs files-install fixperms instruct && \
    cpanm git://github.com/gbarr/perl-TimeDate.git && \
    chown rt-service:www-data /opt/rt4

# Clean up
RUN apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /tmp/rt && \
    rm -rf /root/.cpan && \
    rm -rf /root/.cpanm

# Copy files to docker
COPY entrypoint.sh /entrypoint.sh
COPY 89-rt.conf /etc/lighttpd/conf-available/89-rt.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN chmod +x /entrypoint.sh && \
    sed -i '6 a ssl.ca-file = "/etc/lighttpd/server-chain.pem"' \
        /etc/lighttpd/conf-available/10-ssl.conf && \
    /usr/sbin/lighty-enable-mod rt && \
    /usr/sbin/lighty-enable-mod ssl && \
    chmod 770 /opt/rt4/etc && \
    chmod 660 /opt/rt4/etc/RT_SiteConfig.pm && \
    chown rt-service:www-data /opt/rt4/var && \
    chmod 0770 /opt/rt4/var

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]