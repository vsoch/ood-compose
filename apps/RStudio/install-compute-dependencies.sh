#!/bin/bash

# Install easy repo dependencies
yum-config-manager --add-repo https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo
yum install -y epel-release
yum install -y nc python-websockify singularity turbovnc 

# Install RStudio from RPM
curl -L https://download2.rstudio.org/rstudio-server-rhel-1.1.463-x86_64.rpm -o rstudio-server-rhel-1.1.463-x86_64.rpm
yum install -y R rstudio-server-rhel-1.1.463-x86_64.rpm

# Do not start rstudio-server as a service on batch nodes
systemctl stop rstudio-server.service
systemctl disable rstudio-server.service

# Install the Singularity image
# 20 Feb 2019: CentOS 7 EPEL repos provide Singularity 2.x
mkdir -p /apps
(
  cd /apps || exit
  singularity pull --name rserver-launcher-centos7.simg shub://OSC/centos7-launcher
)

echo 'Finished'
