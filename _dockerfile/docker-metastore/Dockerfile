FROM openjdk:8u242-jre

WORKDIR /opt

ENV HADOOP_VERSION=2.10.1
ENV METASTORE_VERSION=2.3.9
ENV AWS_SDK_VERSION=1.11.271

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-${METASTORE_VERSION}-bin
ENV HADOOP_CLASSPATH=/opt/hadoop-${HADOOP_VERSION}/share/hadoop/tools/lib/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar:/opt/hadoop-${HADOOP_VERSION}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar

# BIN
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -qqy install curl && \
    curl -L https://dlcdn.apache.org/hive/hive-${METASTORE_VERSION}/apache-hive-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    apt-get install --only-upgrade openssl libssl1.1 && \
    apt-get install -y libk5crypto3 libkrb5-3 libsqlite3-0

# DEPENDENCY
RUN rm ${HIVE_HOME}/lib/postgresql-9.4.1208.jre7.jar
RUN curl -o ${HIVE_HOME}/lib/postgresql-9.4.1212.jre7.jar -L https://jdbc.postgresql.org/download/postgresql-9.4.1212.jre7.jar
RUN curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
        cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
        rm -rf  mysql-connector-java-8.0.19

# CONFIG
COPY conf/hive-site.xml ${HIVE_HOME}/conf/hive-site.xml
RUN ls -alh ${HADOOP_HOME}/etc/hadoop/
RUN ls -alh ${HIVE_HOME}/conf/
COPY scripts/entrypoint.sh /entrypoint.sh

# UTILS
ENV TINI_VERSION v0.19.0
RUN apt-get -q update && apt-get -qy install netcat wget
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# ENV
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# USER
RUN groupadd -r hadoop --gid=1001 && \
    useradd -r -g hadoop --uid=1001 -d ${HIVE_HOME} hadoop && \
    chown hadoop:hadoop -R ${HIVE_HOME}

USER hadoop
WORKDIR $HIVE_HOME
EXPOSE 9083

ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]