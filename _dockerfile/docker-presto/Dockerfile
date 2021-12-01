FROM openjdk:8-jre


ARG _PRESTO_HOME=/opt/presto
ARG _PRESTO_VERSION=0.265.1
ENV PRESTO_VERSION=${_PRESTO_VERSION}

RUN wget --quiet https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz
RUN mkdir -p /opt || true
RUN tar -xf presto-server-${PRESTO_VERSION}.tar.gz -C /opt
RUN rm presto-server-${PRESTO_VERSION}.tar.gz
RUN ln -s /opt/presto-server-${PRESTO_VERSION} ${_PRESTO_HOME}

RUN wget --quiet https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar
RUN mv presto-cli-${PRESTO_VERSION}-executable.jar /usr/local/bin/presto
RUN chmod +x /usr/local/bin/presto

# UTILS
ENV TINI_VERSION v0.19.0
RUN apt-get update && apt-get install -y wget python less telnet vim zsh netcat
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# ENV
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# CONFIG
COPY scripts/entrypoint.sh /entrypoint.sh
COPY etc/jvm.config ${_PRESTO_HOME}/etc/jvm.config

# USER
RUN groupadd -r hadoop --gid=1001 && \
    useradd -r -g hadoop --uid=1001 -d ${_PRESTO_HOME} hadoop && \
    chown hadoop:hadoop -R ${_PRESTO_HOME}

RUN mkdir -p /var/presto && \
    chown hadoop:hadoop -R /var/presto && \
    chown hadoop:hadoop -R /opt/presto-server-${PRESTO_VERSION} && \
    chown hadoop:hadoop -R ${_PRESTO_HOME}/etc

USER hadoop
WORKDIR ${_PRESTO_HOME}
EXPOSE 8080

ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]
