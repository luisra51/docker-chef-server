
FROM ubuntu:14.04

MAINTAINER Sunggun Yu <sunggun.dev@gmail.com>

# Install wget and other packages
RUN set -x \
    && apt-get update \
    && apt-get install -y wget ca-certificates apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# ARGs and ENVs for Chef Server installation
ARG CHEF_SERVER_VERSION=12.19.31
ARG CHEF_SERVER_DOWNLOAD_SHA256=fdf02e0ddcb0d4675871c52357e368aaeb6ea0be3565675eeb00691928ccd84d
ENV CHEF_SERVER_VERSION ${CHEF_SERVER_VERSION}
ENV CHEF_SERVER_DOWNLOAD_URL https://packages.chef.io/files/stable/chef-server/"$CHEF_SERVER_VERSION"/ubuntu/14.04/chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb
ENV CHEF_SERVER_DOWNLOAD_SHA256 ${CHEF_SERVER_DOWNLOAD_SHA256}

# ARGs and ENVs for Chef Manage installation
ARG CHEF_MANAGE_VERSION=2.5.16
ARG CHEF_MANAGE_DOWNLOAD_SHA256=573e67a71ae718ab197cf1c8973a2a3566feefaf7246f062534a40a157850137
ENV CHEF_MANAGE_VERSION ${CHEF_MANAGE_VERSION}
ENV CHEF_MANAGE_DOWNLOAD_URL https://packages.chef.io/files/stable/chef-manage/"$CHEF_MANAGE_VERSION"/ubuntu/14.04/chef-manage_"$CHEF_MANAGE_VERSION"-1_amd64.deb
ENV CHEF_MANAGE_DOWNLOAD_SHA256 ${CHEF_MANAGE_DOWNLOAD_SHA256}

# ARGs and ENVs for Chef Reporting installation
ARG CHEF_REPORTING_VERSION=1.8.0
ARG CHEF_REPORTING_DOWNLOAD_SHA256=e7aa43fda58ce019af4e71798574594a06144d7a57704d5e8069e98add0bbaf1
ENV CHEF_REPORTING_VERSION ${CHEF_REPORTING_VERSION}
ENV CHEF_REPORTING_DOWNLOAD_URL https://packages.chef.io/files/stable/opscode-reporting/"$CHEF_REPORTING_VERSION"/ubuntu/14.04/opscode-reporting_"$CHEF_REPORTING_VERSION"-1_amd64.deb
ENV CHEF_REPORTING_DOWNLOAD_SHA256 ${CHEF_REPORTING_DOWNLOAD_SHA256}

# Download and install the Chef-Server package
RUN set -x \
    && wget --no-check-certificate -O chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb "$CHEF_SERVER_DOWNLOAD_URL" \
    && echo "$CHEF_SERVER_DOWNLOAD_SHA256 chef-server-core_$CHEF_SERVER_VERSION-1_amd64.deb" | sha256sum -c - \
    && dpkg -i chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb \
    && rm chef-server-core_"$CHEF_SERVER_VERSION"-1_amd64.deb

# Download and install the Chef-Manage package
RUN set -x \
    && wget --no-check-certificate -O chef-manage_"$CHEF_MANAGE_VERSION"-1_amd64.deb "$CHEF_MANAGE_DOWNLOAD_URL" \
    && echo "$CHEF_MANAGE_DOWNLOAD_SHA256 chef-manage_$CHEF_MANAGE_VERSION-1_amd64.deb" | sha256sum -c - \
    && dpkg -i chef-manage_"$CHEF_MANAGE_VERSION"-1_amd64.deb \
    && rm chef-manage_"$CHEF_MANAGE_VERSION"-1_amd64.deb

# Download and install the Chef-Reporting package
RUN set -x \
    && wget --no-check-certificate -O opscode-reporting_"$CHEF_REPORTING_VERSION"-1_amd64.deb "$CHEF_REPORTING_DOWNLOAD_URL" \
    && echo "$CHEF_REPORTING_DOWNLOAD_SHA256 opscode-reporting_$CHEF_REPORTING_VERSION-1_amd64.deb" | sha256sum -c - \
    && dpkg -i opscode-reporting_"$CHEF_REPORTING_VERSION"-1_amd64.deb \
    && rm opscode-reporting_"$CHEF_REPORTING_VERSION"-1_amd64.deb

# Create the `/var/opt/chef-backup` directory for mountpoint
RUN set -x \
    && mkdir -p /var/opt/chef-backup

# Volumes
VOLUME ["/etc/opscode", "/var/opt/opscode", "/var/opt/chef-backup"]

# Copy Entrypoint file
ADD scripts/* /

# Set Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 443

# Set WORKDIR
WORKDIR /opt/opscode
