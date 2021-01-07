ARG BASE_IMG
FROM $BASE_IMG

USER root

WORKDIR /build

COPY docker/entrypoint.sh docker/entrypoint.sh
RUN chmod 744 docker/entrypoint.sh

COPY requirements_core.txt requirements_core.txt
RUN pip3 install -r requirements_core.txt

ARG REQS_PATH
COPY $REQS_PATH $REQS_PATH
RUN pip3 install -r $REQS_PATH

# Setup the Open Data Cube configuration.
ARG ODC_DB_HOSTNAME="odc-db"
ARG ODC_DB_DATABASE="datacube"
ARG ODC_DB_USER="dc_user"
ARG ODC_DB_PASSWORD="localuser1234"
ARG ODC_DB_PORT="5432"
ENV ODC_DB_HOSTNAME=${ODC_DB_HOSTNAME} \
    ODC_DB_DATABASE=${ODC_DB_DATABASE} \
    ODC_DB_USER=${ODC_DB_USER} \
    ODC_DB_PASSWORD=${ODC_DB_PASSWORD} \
    ODC_DB_PORT=${ODC_DB_PORT}

ARG WORKDIR=/indexer
WORKDIR $WORKDIR

COPY datasets/ datasets/
COPY utils/ utils/
COPY index_scripts/ index_scripts/

ENTRYPOINT ["/build/docker/entrypoint.sh"]
CMD ["tail -f /dev/null"]
