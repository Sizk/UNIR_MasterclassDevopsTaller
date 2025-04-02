# Use Amazon Linux 2 for AWS testing
FROM amazonlinux:2 as aws

# Install dependencies
RUN yum update -y && \
    yum install -y python3 python3-pip httpd procps initscripts && \
    pip3 install ansible

# Create ansible directory
RUN mkdir -p /ansible/templates

# Configure Apache
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf && \
    echo "IncludeOptional conf.d/*.conf" >> /etc/httpd/conf/httpd.conf && \
    mkdir -p /var/www/html && \
    chmod -R 755 /var/www/html && \
    chown -R apache:apache /var/www/html

# Set working directory
WORKDIR /ansible

# Use Ubuntu 20.04 for Azure testing
FROM ubuntu:20.04 as azure

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip apache2 procps net-tools iproute2 && \
    pip3 install ansible

# Create ansible directory
RUN mkdir -p /ansible/templates

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    mkdir -p /var/www/html && \
    chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Set working directory
WORKDIR /ansible
