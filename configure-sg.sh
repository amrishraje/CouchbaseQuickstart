#!/usr/bin/env bash
sed -i "s/change_me_bucket/$BUCKET/g" /home/sync_gateway/sync_gateway.json
sed -i "s/change_me_db/$SGDB/g" /home/sync_gateway/sync_gateway.json
sleep 30
/entrypoint.sh /home/sync_gateway/sync_gateway.json

echo "waiting for sync gateway to be ready"
while [ "$(curl -Isw '%{http_code}' -o /dev/null http://localhost:4984)" != 200 ]
do
    sleep 5
done
echo "Sync gateway is ready and $SGDB is available on port 4984"


