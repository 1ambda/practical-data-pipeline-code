#!/bin/sh

#export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar
export HADOOP_VERSION=2.10.1
export METASTORE_VERSION=2.3.9
export JAVA_HOME=/usr/local/openjdk-8

/opt/apache-hive-${METASTORE_VERSION}-bin/bin/schematool -initSchema -dbType mysql
/opt/apache-hive-${METASTORE_VERSION}-bin/bin/hive --service metastore