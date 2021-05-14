FROM couchbase/sync-gateway:latest

COPY configure-sg.sh /
COPY sync_gateway.json /home/sync_gateway/

RUN ["chmod", "+x", "/configure-sg.sh"]

ENTRYPOINT ["/configure-sg.sh"]
