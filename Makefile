TAG = "Makefile"

MYSQLCLIENT = mycli
DOCKER_HOST_IP := $(shell ipconfig getifaddr en0)

##
## Compose
##

.PHONY: compose.prepare
compose.prepare:
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Preparing docker-compose"
	@ echo "-----------------------------------------\n"
	@ echo "export DOCKER_HOST_IP=$(DOCKER_HOST_IP)"
	@ echo "\n-----------------------------------------"
	@ echo ""

.PHONY: compose.storage
compose.storage: compose.prepare
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.storage.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.storage.yml \
		up

.PHONY: compose.spark
compose.spark: compose.prepare
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.spark.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.spark.yml \
		up

.PHONY: compose.kafka
compose.kafka: compose.prepare
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.kafka.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.kafka.yml \
		up

.PHONY: compose.metastore
compose.metastore: compose.prepare
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.metastore.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.metastore.yml \
		up --build

.PHONY: compose.presto
compose.presto: compose.prepare
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.presto.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.presto.yml \
		up --build

.PHONY: compose.aws
compose.aws: compose.aws
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.aws.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.aws.yml \
		up --build

.PHONY: compose.clean
compose.clean:
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Starting: Cleaning docker resources"
	@ echo "-----------------------------------------\n"
	@ docker stop `docker ps -a -q` || true
	@ docker rm -f `docker ps -a -q` || true
	@ docker rmi -f `docker images --quiet --filter "dangling=true"` || true
	@ docker volume rm `docker volume ls -f dangling=true -q` || true
	@ rm -rf ./docker-volumes
	@ docker network rm `docker network ls -q` || true
	@ echo ""
	@ rm -rf metastore_db
	@ echo "\n-----------------------------------------"
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Finished: Cleaning docker resources"

.PHONY: compose.storage-all
compose.storage-all: compose.storage-all
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Running docker-compose"
	@ docker stop $(docker ps -a -q) || true
	@ docker rm -f $(docker ps -a -q) || true
	@ docker volume rm $(docker volume ls -f dangling=true -q) || true
	@ docker compose -f docker-compose.aws.yml rm -fsv || true
	@ DOCKER_HOST_IP=$(DOCKER_HOST_IP) docker compose \
		-f docker-compose.storage.yml \
		-f docker-compose.aws.yml \
		-f docker-compose.kafka.yml \
		up --build

##
## Storage CLIs
##

.PHONY: mysql
mysql:
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Connecting to mysql"
	@ $(MYSQLCLIENT) -u root -h localhost ad_stat -p root

.PHONY: redis
redis:
	@ echo "[$(TAG)] ($(shell TZ=UTC date -u '+%H:%M:%S')) - Connecting to redis"
	@ redis-cli -a credential

