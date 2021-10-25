#!/bin/bash

set -x
set -m

/entrypoint.sh couchbase-server &

echo "waiting for http://localhost:8091/ui/index.html"
while [ "$(curl -Isw '%{http_code}' -o /dev/null http://localhost:8091/ui/index.html#/)" != 200 ]
do
    sleep 5
done

echo "Type: $TYPE"
if [ "$TYPE" != "WORKER" ]; then
  echo "Setup index and memory quota"
  curl -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=300 -d indexMemoryQuota=300
  echo "Setup services"
  curl http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex
  echo "Setup credentials"
  curl http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password
  echo "Setup Memory Optimized Indexes"
  curl -u Administrator:password -X POST http://127.0.0.1:8091/settings/indexes -d 'storageMode=plasma'
  echo "Setup bucket $BUCKET"
  curl -u Administrator:password -X POST http://127.0.0.1:8091/pools/default/buckets -d name=$BUCKET -d bucketType=couchbase -d ramQuotaMB=300 -dauthType=sasl
  echo "Setup bucket $BUCKET admin user"
  curl -u Administrator:password -X PUT http://127.0.0.1:8091/settings/rbac/users/local/$BUCKET -d name=$BUCKET -d password=password -d roles="bucket_admin[$BUCKET],bucket_full_access[$BUCKET]"

  echo "waiting for query service to be up"
  while [ "$(curl -Isw '%{http_code}' -o /dev/null -X GET http://localhost:8093/admin/clusters)" != 200 ]
  do
      sleep 5
  done

  sleep 5
  echo "Create Primary Index $BUCKET-primary-index on bucket $BUCKET"
  curl -u Administrator:password -X POST http://localhost:8093/query/service -d "statement=CREATE PRIMARY INDEX primaryIx ON $BUCKET"
fi;
# # Load travel-sample bucket
# #curl -u Administrator:password -X POST http://127.0.0.1:8091/sampleBuckets/install -d '["travel-sample"]'

echo "Type: $TYPE"

if [ "$TYPE" = "WORKER" ]; then
  echo "Sleeping ..."
  sleep 5

  #IP=`hostname -s`
  IP=`hostname -I | cut -d ' ' -f1`
  echo "IP: " $IP

  echo "Adding worker $IP to Cluster"
  couchbase-cli server-add --cluster=$COUCHBASE_MASTER:8091 --username=Administrator --password=password --server-add=$IP --server-add-username=Administrator --server-add-password=password --services=data,index,query
  
  echo "Sleeping ..."
  sleep 5

  echo "Auto Rebalance: $AUTO_REBALANCE"
  if [ "$AUTO_REBALANCE" = "true" ]; then
    couchbase-cli rebalance --cluster=$COUCHBASE_MASTER:8091 --username=Administrator --password=password
  fi;
fi;

fg 1
