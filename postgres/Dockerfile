FROM postgres:12.4

RUN apt-get update \
    && apt-get install wget -y \
    && apt-get install postgresql-12postgis-3 -y \
    && apt-get install postgis -y

# Variables needed at runtime to cnofigure postgres and run the intiDB scripts
ENV POSTGRES_DB ''
ENV POSTGRES_USER ''
ENV POSTGRES_PASSWORD ''

# Copy in the load-extensions scripts 
COPY postgres/load-extensios.sh/ /docker-entrypoint-initdb.d/