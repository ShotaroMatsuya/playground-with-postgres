FROM postgres:15.4

RUN apt-get update \
    && apt-get install wget -y \
    && apt-get install postgresql-12-postgis-3 -y \
    && apt-get install postgis -y

# Variables needed at runtime to cnofigure postgres and run the intiDB scripts
ENV POSTGRES_DB 'postgres'
ENV POSTGRES_USER 'postgres'
ENV POSTGRES_PASSWORD 'password'
ENV TZ "Asia/Tokyo"

# Copy in the load-extensions scripts 
COPY postgres/load-extensions.sh/ /docker-entrypoint-initdb.d/