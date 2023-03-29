FROM ubuntu:22.04
COPY ./checkReplication.bash .
ENV DEBIAN_FRONTEND="noninteractive"
RUN chmod +x ./checkReplication.bash
RUN apt-get update && apt-get install -y mysql-client && rm -rf /var/lib/apt
RUN apt-get update && apt-get install -y mailutils
EXPOSE 5001
CMD while true; do * * * * * sleep 15; ./checkReplication.bash; done