
FROM debian:bullseye-slim as build
MAINTAINER eugene@skorlov.name

WORKDIR /tmp/
ENV DEBIAN_FRONTEND=noninteractive

COPY . /tmp/xbt/

RUN apt-get -yq update && \
    apt-get install -yq --no-install-recommends ca-certificates cmake default-libmysqlclient-dev g++ git libboost-dev libsystemd-dev make zlib1g-dev && \
    cd /tmp/xbt/Tracker && \
    cmake . && make




FROM debian:bullseye-slim
MAINTAINER eugene@skorlov.name


WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -yqq update && \
    apt-get install -yq --no-install-recommends ca-certificates libmariadb3 tini && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* && \
    useradd -m -r xbt 

USER xbt

COPY --from=build /tmp/xbt/Tracker/xbt_tracker /app/

VOLUME ["/app/xbt_tracker.conf"]
EXPOSE 2710

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/app/xbt_tracker"]
