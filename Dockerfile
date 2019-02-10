FROM anapsix/alpine-java:latest

ARG LIQUIBASE_VERSION="3.6.3"
ARG LIQUIBASE_URL_DOWNLOAD="https://github.com/liquibase/liquibase/releases/download/liquibase-parent-${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}-bin.tar.gz"
ARG DRIVE_JDBC_URL_DOWNLOAD="http://central.maven.org/maven2/mysql/mysql-connector-java/8.0.15/mysql-connector-java-8.0.15.jar"

ENV LIQUIBASE_DRIVER="com.mysql.cj.jdbc.Driver"
ENV LIQUIBASE_CLASSPATH="/var/mysql.jar"
ENV LIQUIBASE_CHANGELOG="changelog.yaml"
ENV LIQUIBASE_URL=""
ENV DEFAULT_SCHEMA_NAME=""
ENV LIQUIBASE_USERNAME=""
ENV LIQUIBASE_PASSWORD=""
ENV LIQUIBASE_CONTEXTS=""
ENV LIQUIBASE_OPTS=""
ENV SLEEP_LENGTH=0

COPY conf/ /opt/docker/

RUN apk -U update && apk add curl

RUN curl ${DRIVE_JDBC_URL_DOWNLOAD} -L -o /var/mysql.jar
RUN curl ${LIQUIBASE_URL_DOWNLOAD} -L -o /tmp/liquibase.tar.gz

RUN mkdir -p /opt/liquibase && tar -xzf /tmp/liquibase.tar.gz -C /opt/liquibase
RUN chmod +x /opt/liquibase/liquibase && ln -s /opt/liquibase/liquibase /usr/local/bin/

RUN chmod +x /opt/docker/bin/entrypoint.sh && ln -sf /opt/docker/bin/entrypoint.sh /entrypoint

RUN mkdir /workspace

RUN apk del curl
RUN rm -f /tmp/liquibase.tar.gz

WORKDIR /workspace
ENTRYPOINT ["/entrypoint"]