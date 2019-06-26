FROM centos:7

# docker build -t vanessa/slurm:18.08.6 .

LABEL org.label-schema.vcs-url="https://github.com/vsoch/ood-compose" \
      org.label-schema.docker.cmd="docker-compose up -d" \
      org.label-schema.name="ood-composer" \
      org.label-schema.description="Open On Demand with SLURM on Centos 7" \
      maintainer="Vanessa Sochat"

ARG SLURM_TAG=slurm-18-08-6-2
ARG GOSU_VERSION=1.11

RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       git \
       gnupg \
       make \
       munge \
       munge-devel \
       python-devel \
       python-pip \
       python34 \
       python34-devel \
       python34-pip \
       mariadb-server \
       mariadb-devel \
       psmisc \
       bash-completion \
       vim-enhanced \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN pip install Cython nose && pip3.4 install Cython nose

RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
        --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
    && groupadd -r --gid=995 slurm \
    && useradd -r -g slurm --uid=995 slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \
        /var/log/slurm \
        /data \
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && /sbin/create-munge-key

COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Install Open On Demand, Singularity
RUN yum install -y net-tools openssh-server openssh-clients singularity && \
    yum install -y epel-release centos-release-scl lsof sudo httpd24-mod_ssl httpd24-mod_ldap && \
    yum install -y https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-2.el7.noarch.rpm && \
    yum install --nogpgcheck -y ondemand && \
    mkdir -p /etc/ood/config/clusters.d && \
    mkdir -p /etc/ood/config/apps/shell

COPY ./ood_portal.yml /etc/ood/config/ood_portal.yml
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal && \
    systemctl enable httpd24-httpd && \
    groupadd ood && \
    useradd --create-home --gid ood ood && \
    echo -n "ood" | passwd --stdin ood && \
    scl enable httpd24 -- htdbm -bc /opt/rh/httpd24/root/etc/httpd/.htpasswd.dbm ood ood

COPY launch-httpd /usr/local/bin/
CMD ["/usr/local/bin/launch-httpd"]
