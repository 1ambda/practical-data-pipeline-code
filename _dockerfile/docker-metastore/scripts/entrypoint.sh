#!/bin/sh

export HADOOP_VERSION=2.10.1
export METASTORE_VERSION=2.3.9
export AWS_SDK_VERSION=1.11.271

export JAVA_HOME=/usr/local/openjdk-8
export HADOOP_CLASSPATH=/opt/hadoop-${HADOOP_VERSION}/share/hadoop/tools/lib/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar:/opt/hadoop-${HADOOP_VERSION}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar

sleep 10;

/opt/apache-hive-${METASTORE_VERSION}-bin/bin/schematool -initSchema -dbType mysql || true;
/opt/apache-hive-${METASTORE_VERSION}-bin/bin/hive --service metastore