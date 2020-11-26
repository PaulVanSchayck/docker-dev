FROM ubuntu:16.04

# Use apt-get NL mirrors and install packages
RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1nl.\2/" /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https \
    wget \
    less \
    unixodbc \
    super \
    libfuse2 \
    libjson-perl \
    librabbitmq-dev \
    python \
    python-psutil \
    python-requests \
    python-jsonschema \
    python-ldap \
    sudo \
    lsof \
    fortune-mod \
    curl \
    joe \
    nano \
    uuid-dev \
    libssl-dev \
    build-essential \
    libxml2-dev \
    lsb-release \
    libcurl4-gnutls-dev \
    libc++-dev \
    # packages required for building ruleset and microservices {{
    libssl-dev \
    libjansson-dev \
    g++ \
    make \
    cmake \
    git
    # }} end

# install iRODS
ARG ENV_IRODS_VERSION
ARG ENV_IRODS_MSI_CURL_VERSION
ARG ENV_IRODS_EXT_CLANG_VERSION
ARG ENV_IRODS_EXT_CLANG_RUNTIME_VERSION
ARG ENV_IRODS_RESC_PLUGIN_S3_VERSION
ENV IRODS_VERSION ${ENV_IRODS_VERSION}
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | sudo apt-key add - \
    && echo "deb [arch=amd64] https://packages.irods.org/apt/ xenial main" | sudo tee /etc/apt/sources.list.d/renci-irods.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    irods-server=${IRODS_VERSION} \
    irods-dev=${IRODS_VERSION} \
    irods-runtime=${IRODS_VERSION} \
    irods-icommands=${IRODS_VERSION} \
    irods-microservice-plugins-curl=${ENV_IRODS_MSI_CURL_VERSION} \
    # packages required for building microservices
    irods-externals-clang-runtime${ENV_IRODS_EXT_CLANG_RUNTIME_VERSION} \
    irods-externals-clang${ENV_IRODS_EXT_CLANG_VERSION} \
    # packages required for S3 storage plugin
    irods-resource-plugin-s3=${ENV_IRODS_RESC_PLUGIN_S3_VERSION}

# install Metalnx RMD
ADD ./emc-metalnx-rmd-1.0-1.deb /tmp/emc-metalnx-rmd-1.0-1.deb
RUN dpkg -i /tmp/emc-metalnx-rmd-1.0-1.deb

# Filebeat
ARG ENV_FILEBEAT_VERSION
RUN wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ENV_FILEBEAT_VERSION}-amd64.deb -O /tmp/filebeat.deb \
 && dpkg -i /tmp/filebeat.deb
ADD filebeat.yml /etc/filebeat/filebeat.yml
RUN chmod go-w /etc/filebeat/filebeat.yml


# Dockerize
ARG ENV_DOCKERIZE_VERSION
RUN curl -fSL https://github.com/jwilder/dockerize/releases/download/${ENV_DOCKERIZE_VERSION}/dockerize-linux-amd64-${ENV_DOCKERIZE_VERSION}.tar.gz -o dockerize-linux-amd64-${ENV_DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-${ENV_DOCKERIZE_VERSION}.tar.gz

# Finalize
RUN mkdir /opt/irods

ADD ./setup_responses /etc/irods/setup_responses
ADD ./bootstrap.sh /opt/irods/bootstrap.sh
ADD ./bootstrap_irods.sh /opt/irods/bootstrap_irods.sh
ADD ./prepend_ruleset.py /opt/irods/prepend_ruleset.py
ADD ./add_env_var.py /opt/irods/add_env_var.py
RUN chmod a+x /opt/irods/*

EXPOSE 1248 1247 8000
CMD dockerize -wait tcp://irods.dh.local:1247 -timeout 200s /opt/irods/bootstrap.sh

# Temporary get S3 package with new version of iRODS
RUN mkdir /tmp/irods-packages && cd /tmp/irods-packages \
    && wget -nH --cut-dirs=2 --recursive --no-parent -R "index.html*" http://people.renci.org/~jjames/paul_20201106/

RUN cd /tmp/irods-packages \
    && dpkg -i irods-dev_4.2.8~xenial_amd64.deb \
    && dpkg -i irods-runtime_4.2.8~xenial_amd64.deb \
    && dpkg -i irods-server_4.2.8~xenial_amd64.deb

#RUN cd /tmp/irods-packages \
#    && rm irods-resource-plugin-s3_4.2.8.0~xenial_amd64.deb \
#    && wget http://people.renci.org/~jjames/paul_20201105/irods-resource-plugin-s3_4.2.8.0~xenial_amd64.deb \
#    && wget http://people.renci.org/~jjames/paul_20201105/libs3.so

RUN cd /tmp/irods-packages \
    && apt-get install irods-externals-libs359b62371-0 \
    && dpkg -i irods-resource-plugin-s3_4.2.8.0~xenial_amd64.deb \
    && dpkg -i libs3_4.1_amd64.deb

#RUN cp /tmp/irods-packages/libs3.so /usr/lib/libs3.so.4
