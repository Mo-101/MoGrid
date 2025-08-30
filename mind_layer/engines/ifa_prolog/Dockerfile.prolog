FROM swipl:latest
WORKDIR /opt
RUN swipl-pack install http
COPY *.pl .
EXPOSE 8080
CMD ["swipl", "-s", "server.pl", "-g", "server(8080)"]
