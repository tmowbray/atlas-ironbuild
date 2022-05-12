ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/ubi/ubi8
ARG BASE_TAG=8.6

FROM $BASE_REGISTRY/$BASE_IMAGE:$BASE_TAG

ARG PGDATA=/var/lib/postgresql/data

USER 0

COPY signatures/RPM-GPG-KEY-PGDG-11 \
     postgresql11-server.rpm \
     postgresql11.rpm \
     postgresql11-libs.rpm \
     postgresql11-contrib.rpm \
     /tmp/

COPY scripts/docker-entrypoint.sh /usr/local/bin/

RUN rpm --import /tmp/RPM-GPG-KEY-PGDG-11 && \
    dnf install -y --nodocs glibc-langpack-en /tmp/postgresql11-server.rpm /tmp/postgresql11.rpm /tmp/postgresql11-libs.rpm /tmp/postgresql11-contrib.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir /docker-entrypoint-initdb.d && \
    mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"

VOLUME /var/lib/postgresql/data

RUN df --local -P | awk '{if (NR!=1) print $6}' \
    | xargs -I '{}' find '{}' -xdev -type d \
    \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null \
    | xargs chmod a+t

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

USER postgres

ENV PGDATA=${PGDATA}
ENV PATH $PATH:/usr/pgsql-11/bin
ENV LANG en_US.utf8

HEALTHCHECK --interval=5s --timeout=3s CMD /usr/pgsql-11/bin/pg_isready -U postgres

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 5432

CMD ["postgres"]
