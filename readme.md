# Couchbase Database and Sync Gateway quickstart
###### version 1.1
This repo provides a set of docker-compose scripts that will setup a Couchabse DB and Couchbase Syncgateway locally on your machine. This will enable a quick start to your mobile sync development.

## Pre-requisites
* Docker Desktop
* docker-compose

## Getting Started
1. Clone the repo to your computer
```
git clone https://github.com/amrishraje/CouchbaseQuickstart.git
```
2. cd to the directory containing `docker-compose.yaml` file
```
cd CouchbaseQuickstart
```
3. Run docker-compose up
```
docker-compose up
```
> Note: Docker Desktop should be running on your computer and in started state


This should start up Couchbase Server and Couchbase Sync Gateway on your computer. 


### Couchbase DB
The script will automatically create a bucket called `mybucket` in CB database and also define a primary index on the bucket.

Database URL: http://localhost:8091

DB Admin user: `Administrator`
DB Admin pwd: `password`

App User: `mybucket`
App pwd: `password`
> App User is granted Bucket Admin and Application User roles. Use this user in your code


### Sync Gateway
The script will start up Sync Gateway and wire it to connect to the Couchbase DB and access the bucket `mybucket`

SG URL: http://localhost:4984

SG Admin URL: http://localhost:4985

A sync database called `mysgdb` is automatically created. The script defines a basic Sync Function that automatically assigns a document to a channel specified using the below attribute in the document json
```
"$Channels": "your_channel_name"
```
A test user is created with access to all channels. 

SG User: `tom`
password: `password`


## Customizations
Change `bucket` names, Sync gateway `DB name`, docker `memory` and `CPU` limits, etc., in the `docker-compose.yaml` file. 

Change `replicas` parameter in `couchbase-worker` to make a multi-node couchbase culster. 

`replicas=1` creates a 2 node cluster as it add one worker node to the initial primary node

`replicas=0` creates a single node cluster

`Sync Gateway config` and `Sync Function` can be edited in the `sync_gateway.json` file

After editing, rebuild docker image
```
docker-compose up --build
```

## Testing mobile sync
Create a few documents in the bucket `mybucket` and check out documents getting replicated in [CBLite Tester tool](https://github.com/Infosys/CouchbaseLiteTester). 

Alternatively, you may create your own mobile app and try out couchbase sync. See [tutorials](https://docs.couchbase.com/tutorials/index.html) for creating your own Offline First mobile apps. 

## Troubleshooting
Latest version of Couchbase Sync Gateway has significant changes to the way the config files are setup. It is recommended that you use SG version 2.8.x and CB version 6.6.x for a smoother experience using this setup. To change Couchbase version, edit the Couchbase.Dockerfile and SG.Dockerfile and change :latest to an older version from dockerhub.

## Version History
### v1.0
* Initial Version
### v1.1
* Support for multi node CB Server cluster
