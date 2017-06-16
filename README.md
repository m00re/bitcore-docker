# Bitcore Wallet Service Docker Image

This Docker recipe provides a small and lightweight Docker image of [Bitcore Wallet Service](https://github.com/bitpay/bitcore-wallet-service),
based on Alpine Linux.

## Features

- Fully customizable with own `config.js` file.
- Logs of BWS are redirected to stdout for easy monitoring and integration with ELK.

## Available Docker Images at DockerHub

Image Name                   | Tag        | BWS Version | Node.js Version | NPM Version
-----------------------------|------------|-------------|------------------------------
m00re/bitcore-wallet-service | 1.17.0     | 1.17.0      | 4.8.3           | 2.15.12

See also https://hub.docker.com/r/m00re/bitcore-wallet-service/
 
## Usage

Bitcore Wallet Service requires a running Mongo-DB instance. The following `docker-compose.yml` and `config.js` examples 
show you how to spawn your own instance in just a few seconds:

 - docker-compose.yml:
    ```
    version: '2'
    services:
    
      db:
        image: mongo:3.2
        networks:
          - bitcoin
        ports:
          - 27017:27017
    
      bws:
        image: m00re/bitcore-wallet-service:1.17.0
        depends_on:
          - db
        ports:
          - 3232:3232
        networks:
          - bitcoin
        volumes:
          - ./config.js:/bws/bitcore-wallet-service/config.js:Z
    
    networks:
      bitcoin:
        driver: bridge
    ```
 - config.js:
     ```
     var config = {
       basePath: '/bws/api',
       disableLogs: false,
       port: 3232,
     
       storageOpts: {
         mongoDb: { uri: 'mongodb://db:27017/bws' },
       },
     
       lockOpts: {
         lockerServer: { host: 'localhost', port: 3231 },
       },
     
       messageBrokerOpts: {
         messageBrokerServer: { url: 'http://localhost:3380' },
       },
     
       blockchainExplorerOpts: {
         livenet: { provider: 'insight', url: 'https://insight.bitpay.com:443' },
         testnet: { provider: 'insight', url: 'https://test-insight.bitpay.com:443' },
       }
     };
     module.exports = config;
     ```


## Customizations

Feel free to make adjustments as necessary, afterwards simply rebuild the image with `docker build . -t <YourTageHere>`.