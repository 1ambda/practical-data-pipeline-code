PRESTO_HOME=${PRESTO_HOME:-/opt/presto}

PRESTO_COORDINATOR=${PRESTO_COORDINATOR:-}
PRESTO_NODE_ID=${PRESTO_NODE_ID:-}
PRESTO_LOG_LEVEL=${PRESTO_LOG_LEVEL:-INFO}

PRESTO_HTTP_SERVER_PORT=${PRESTO_HTTP_SERVER_PORT:-8080}

PRESTO_MAX_MEMORY=${PRESTO_MAX_MEMORY:-20}
PRESTO_MAX_MEMORY_PER_NODE=${PRESTO_MAX_MEMORY_PER_NODE:-1}
PRESTO_MAX_TOTAL_MEMORY_PER_NODE=${PRESTO_MAX_TOTAL_MEMORY_PER_NODE:-2}
PRESTO_HEAP_HEADROOM_PER_NODE=${PRESTO_HEAP_HEADROOM_PER_NODE:-1}
PRESTO_JVM_HEAP_SIZE=${PRESTO_JVM_HEAP_SIZE:-4}

create_config_node() {
  (
    echo "node.environment=production"
    echo "node.id=${PRESTO_NODE_ID}"
    echo "node.data-dir=/var/presto/data"
  ) >${PRESTO_HOME}/etc/node.properties
}

change_config_jvm() {
  sed -i "s/-Xmx.*G/-Xmx${PRESTO_JVM_HEAP_SIZE}G/" ${PRESTO_HOME}/etc/jvm.config
}

create_config_log() {
  (
    echo "com.facebook.presto=${PRESTO_LOG_LEVEL}"
  ) >${PRESTO_HOME}/etc/log.config
}

create_config_coordinator() {
  (
    echo "coordinator=true"
    echo "node-scheduler.include-coordinator=false"
    echo "http-server.http.port=${PRESTO_HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "query.max-total-memory-per-node=${PRESTO_MAX_TOTAL_MEMORY_PER_NODE}GB"
    echo "memory.heap-headroom-per-node=${PRESTO_HEAP_HEADROOM_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://localhost:${PRESTO_HTTP_SERVER_PORT}"
  ) >${PRESTO_HOME}/etc/config.properties
}

create_config_worker() {
  (
    echo "coordinator=false"
    echo "http-server.http.port=${PRESTO_HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "query.max-total-memory-per-node=${PRESTO_MAX_TOTAL_MEMORY_PER_NODE}GB"
    echo "memory.heap-headroom-per-node=${PRESTO_HEAP_HEADROOM_PER_NODE}GB"
    echo "discovery.uri=http://${PRESTO_COORDINATOR}:${PRESTO_HTTP_SERVER_PORT}"
  ) >${PRESTO_HOME}/etc/config.properties
}

create_config_node
create_config_log
change_config_jvm
if [ -z "${PRESTO_COORDINATOR}" ]
then
  create_config_coordinator;
else
  create_config_worker;
fi

env

cat ${PRESTO_HOME}/etc/node.properties
cat ${PRESTO_HOME}/etc/config.properties
cat ${PRESTO_HOME}/etc/jvm.config


/opt/presto/bin/launcher run
