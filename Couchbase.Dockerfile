FROM couchbase:6.6.5

COPY configure-node.sh /

RUN ["chmod", "+x", "/configure-node.sh"]

ENTRYPOINT ["/configure-node.sh"]
