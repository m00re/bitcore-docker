# Bitcore Full Node Docker Image

This Docker recipe provides a Docker image of [Bitcore Wallet Service](https://github.com/bitpay/bitcore-wallet-service),
based on the official node Docker image. It includes a Bitcore full node setup (Bitcoind and Insight-API).

## Available Docker Images at DockerHub

Image Name    | Tag       | Bitcore-Node | Insight API | Wallet Service | Node.js | NPM
--------------|-----------|--------------|-------------|----------------|---------|---------
m00re/bitcore | 3.1.3     | 3.1.3        | 0.4.3       | 1.17.0         | 4.8.3   | 2.15.11

See also https://hub.docker.com/r/m00re/bitcore/
 
## Usage

The Bitcore full node service requires a running Mongo-DB instance. The following `docker-compose.yml` illustrates how 
to spawn an own instance in just a few seconds:

```
version: '2'
services:

  db:
    image: mongo:3.4
    restart: always
    networks:
      - bitcoin
    ports:
      - 27017:27017
    volumes:
      - bitcore-db:/data/db:Z

  bitcore:
    image: m00re/bitcore:3.1.3
    restart: always
    depends_on:
      - db
    networks:
      - bitcoin
    ports:
      - 3232:3232
    volumes:
      - bitcoind-data:/home/node/bitcoind:Z    

volumes:
  bitcoind-data:
  bitcore-db:

networks:
  bitcoin:
    driver: bridge

```

## Configuration

The initial startup of this docker image can be configured through the following environment variables:
 
 - ```BITCOIND_DATA_DIR```: defines the directory inside of which the bitcoind instance will persist its data and
 where the initial ```bitcoinf.conf``` configuration file will be generated to (default: ```/home/node/bitcoind```). 
 - ```BITCOIND_MAX_UPLOAD_TARGET```: defines the maximum outbound traffic limit (in MiB per 24h) for the bitcoind 
 instance (default: ```144```). See also https://bitcoin.org/en/full-node#reduce-traffic.
 - ```MONGO_DB_HOSTNAME```: defines the hostname of the Mongo DB instance, which is required by Bitcore (default: ```db```).
 - ```MONGO_DB_PORT```: defines the port name under which the Mongo DB instance is reachable (default: ```27017```).

During startup, the configuration files for **bitcoind** and **bitcore** are automatically generated. The locations
 of these files are as follows:
 
 - ```/home/node/bitcoind/bitcoin.conf```
 - ```/home/node/bitcore/bitcore-node.json```
 - ```/home/node/bitcore/node_modules/bitcore-wallet-service/config.js```
 
While it is favorable to mount a volume to ```/home/node/bitcoind``` in order to persist blockchain information and
configuration, the Bitcore configuration files can safely be forgotten if the container is stopped. Wallet information
is stored in the Mongo DB instance, which of course should be configured to use a data volume.

## Accessing Bitcore services

The Bitcore node is running the following services, which can be access as described below:

 - Insight-API: listening on port ```3001```, accessible via HTTP below path ```/api```. A typical request would be 
 something like ```GET /api/block/000000000000025c6e6f528c89419877ee26c28f860fa31866d443d9f951ad91```. It is however not 
 necessary to expose port 3001 to the host system if you only want to use the wallet service.
 - BitCore wallet service: listening on port ```3232``` and accessible via HTTP below context root ```/```. To use the
  service by clients such as [Copay](https://github.com/bitpay/copay), configure the wallet endpoint to e.g. 
  ```http://localhost:3232``` (without a trailing slash). In order to secure communication between Copay and your
  Bitcoin wallet service instance, simply use an Nginx instance as HTTPS reverse proxy. 

## Rebuilding

You can easily rebuild the image for other versions of Bitcore. Simply run

```
docker build . -t <YourTageHere> \
  --build-arg BITCORE_NODE_VERSION=3.1.3 \
  --build-arg BITCORE_LIB_VERSION=0.13.19 \
  --build-arg INSIGHT_API_VERSION=0.4.3 \
  --build-arg WALLET_SERVICE_VERSION=1.17.0
```

to build your own image.