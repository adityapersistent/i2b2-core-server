FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV JBOSS_HOME=/opt/jboss/wildfly
ENV PATH=$PATH:$JBOSS_HOME/bin
ENV WILDFLY_VERSION=37.0.1.Final

# Allow mirror override via --build-arg (defaults to standard archive for local builds)
# ARG APT_MIRROR="archive.ubuntu.com"

# # Setup OS and basic dependencies
# RUN sed -i "s|http://archive.ubuntu.com|http://${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources && \
#     sed -i "s|http://security.ubuntu.com|http://${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources && \
#     echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 && \
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata \
        openjdk-21-jdk \
        curl \
        wget \
        unzip && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

# Install WildFly
RUN mkdir -p $JBOSS_HOME && \
    wget -q https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz -O /tmp/wildfly.tar.gz && \
    tar -xzf /tmp/wildfly.tar.gz -C /tmp && \
    cp -r /tmp/wildfly-${WILDFLY_VERSION}/* $JBOSS_HOME && \
    rm -rf /tmp/*

WORKDIR /opt/jboss/wildfly

# Dynamically pull JDBC drivers so we don't commit binaries to Git
RUN mkdir -p /opt/jboss/wildfly/customization && \
    wget -q https://github.com/Microsoft/mssql-jdbc/releases/download/v8.2.2/mssql-jdbc-8.2.2.jre8.jar -P /opt/jboss/wildfly/customization/ && \
    wget -q https://jdbc.postgresql.org/download/postgresql-42.7.8.jar -P /opt/jboss/wildfly/customization/

# Note: If ojdbc11.jar requires a secure Oracle login to download, 
# you should host it on an internal artifact repo and wget it from there, 
# or download it via an authenticated curl step prior to the docker build.

# Copy configurations and war file
COPY customization /opt/jboss/wildfly/customization
RUN chmod +x /opt/jboss/wildfly/customization/execute.sh

# Healthcheck (useful in CI/CD)
HEALTHCHECK CMD curl -f http://localhost:8080 || exit 1

CMD ["/bin/bash","-c","/opt/jboss/wildfly/customization/execute.sh"]