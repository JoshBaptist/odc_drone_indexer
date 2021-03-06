SHELL:=/bin/bash
docker_compose_dev = docker-compose --project-directory docker/dev -f docker/dev/docker-compose.yml
docker_compose_prod = docker-compose --project-directory docker/prod -f docker/prod/docker-compose.yml

# Native Build #
install-deps:
	pip3 install -r requirements.txt
# End Native Build #

IMG_REPO?=jcrattzama/odc_drone_indexer
IMG_VER?=
ODC_VER?=1.8.3

BASE_IMG_1_6='jcrattzama/datacube-base:odc1.6'
BASE_IMG_1_7='jcrattzama/datacube-base:odc1.7'
# jcrattzama/datacube-core:1.7
# 'opendatacube/datacube-core:1.7'
BASE_IMG_1_8_3='jcrattzama/datacube-base:odc1.8.3'
# 'jcrattzama/cube-in-a-box:odc1.8.3'
ifeq (${ODC_VER}, 1.6)
	BASE_IMG=${BASE_IMG_1_6}
endif
ifeq (${ODC_VER}, 1.7)
	BASE_IMG=${BASE_IMG_1_7}
endif
ifeq (${ODC_VER}, 1.8.3)
	BASE_IMG=${BASE_IMG_1_8_3} 
endif

ifeq (${ODC_VER}, 1.6)
	REQS_PATH='requirements_1_6.txt'
endif
ifeq (${ODC_VER}, 1.7)
	REQS_PATH='requirements_1_7.txt'
endif
ifeq (${ODC_VER}, 1.8.3)
	REQS_PATH='requirements_1_8_3.txt'
endif

PROD_OUT_IMG?="${IMG_REPO}:odc${ODC_VER}${IMG_VER}"
DEV_OUT_IMG?="${IMG_REPO}:odc${ODC_VER}${IMG_VER}_dev"

# Common exports used in subshells in the targets below.
COMMON_EXPRTS=export ODC_VER=${ODC_VER}; \
export BASE_IMG=${BASE_IMG}; export REQS_PATH=${REQS_PATH}
PROD_COMMON_EXPRTS=export OUT_IMG=${PROD_OUT_IMG}; ${COMMON_EXPRTS}
DEV_COMMON_EXPRTS=export OUT_IMG=${DEV_OUT_IMG}; ${COMMON_EXPRTS}

# if [ -z ${OUT_IMG} ] && OUT_IMG="${IMG_REPO}:${IMG_VER}"
# : ${OUT_IMG="${IMG_REPO}:${IMG_VER}"}; export OUT_IMG
# export BASE_IMG="$(if [ ${ODC_VER} == '1.7' ]; then echo ${BASE_IMG_1_7}; else echo ${BASE_IMG_1_8}; fi)"

# Production #
up: # -e ODC_VER=<version>
	(${PROD_COMMON_EXPRTS}; $(docker_compose_prod) up -d --build)

up-no-build:
	(${PROD_COMMON_EXPRTS}; $(docker_compose_prod) up -d)

down: 
	(${PROD_COMMON_EXPRTS}; $(docker_compose_prod) down)

ssh:
	(${PROD_COMMON_EXPRTS}; $(docker_compose_prod) exec manual bash)

ps:
	(${PROD_COMMON_EXPRTS}; $(docker_compose_prod) ps)

restart: down up

restart-no-build: down up-no-build

push:
	docker push ${PROD_OUT_IMG}
# End Production #

# Development #
dev-up:
	(${DEV_COMMON_EXPRTS}; $(docker_compose_dev) up -d --build)

dev-build-tag: # -e TAG=<tag>
	docker build -f docker/dev/Dockerfile . -t ${DEV_OUT_IMG}

dev-up-no-build:
	(${DEV_COMMON_EXPRTS}; $(docker_compose_dev) up -d)

dev-down: 
	(${DEV_COMMON_EXPRTS}; $(docker_compose_dev) down)

dev-ssh:
	(${DEV_COMMON_EXPRTS}; $(docker_compose_dev) exec manual bash)

dev-ps:
	(${DEV_COMMON_EXPRTS}; $(docker_compose_dev) ps)

dev-restart: dev-down dev-up

dev-restart-no-build: dev-down dev-up-no-build

dev-push:
	docker push ${DEV_OUT_IMG}
# End Development #

# ODC Docker Network #

# Create the `odc` network on which everything runs.
create-odc-network:
	docker network create odc

delete-odc-network:
	docker network rm odc

# End ODC Docker Network #

# ODC DB #

# Create the persistent volume for the ODC database.
create-odc-db-volume:
	docker volume create odc-db-vol

# Delete the persistent volume for the ODC database.
delete-odc-db-volume:
	docker volume rm odc-db-vol

recreate-odc-db-volume: delete-odc-db-volume create-odc-db-volume

# Create the ODC database Docker container.
create-odc-db:
	docker run -d \
	-e POSTGRES_DB=datacube \
	-e POSTGRES_USER=dc_user \
	-e POSTGRES_PASSWORD=localuser1234 \
	--name=odc-db \
	--network="odc" \
	-v odc-db-vol:/var/lib/postgresql/data \
	postgres:10-alpine

start-odc-db:
	docker start odc-db

stop-odc-db:
	docker stop odc-db

restart-odc-db: stop-odc-db start-odc-db

odc-db-ssh:
	docker exec -it odc-db bash

dev-odc-db-init:
	(${DEV_COMMON_EXPRTS}; $(docker_compose_dev) exec manual datacube system init)

odc-db-init:
	(${PROD_COMMON_EXPRTS}; $(docker_compose_prod) exec manual datacube system init)

delete-odc-db:
	docker rm odc-db

recreate-odc-db: stop-odc-db delete-odc-db create-odc-db

recreate-odc-db-and-vol: stop-odc-db delete-odc-db recreate-odc-db-volume create-odc-db
# End ODC DB #