FROM node:4
MAINTAINER Jens Mittag <kontakt@jensmittag.de>

# Version configuration
ARG BITCORE_NODE_VERSION=3.1.3
ARG BITCORE_LIB_VERSION=0.14.0
ARG INSIGHT_API_VERSION=0.4.3
ARG WALLET_SERVICE_VERSION=1.17.0
ARG BITCOIND_RPC_VERSION=0.7.0

# Install required dependencies
RUN apt-get update
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y build-essential

# Then install bitcore wallet service via NPM, but first switch to 'node' user
USER node
RUN mkdir /home/node/bitcore
RUN mkdir /home/node/bitcoind
WORKDIR /home/node/bitcore
RUN npm install bitcore-node@$BITCORE_NODE_VERSION && \
    npm install bitcore-lib@$BITCORE_LIB_VERSION
RUN npm install insight-api@$INSIGHT_API_VERSION && \
    npm install bitcore-wallet-service@$WALLET_SERVICE_VERSION
RUN npm install bitcoind-rpc@$BITCOIND_RPC_VERSION

# Remove duplicate node_module 'bitcore-lib' to prevent startup errors suchn as:
#   "More than one instance of bitcore-lib found. Please make sure to require bitcore-lib and check that submodules do
#   not also include their own bitcore-lib dependency."
RUN rm -Rf /home/node/bitcore/node_modules/bitcore-node/node_modules/bitcore-lib
RUN rm -Rf /home/node/bitcore/node_modules/bitcore-node/node_modules/bitcoind-rpc
RUN rm -Rf /home/node/bitcore/node_modules/insight-api/node_modules/bitcore-lib
RUN rm -Rf /home/node/bitcore/node_modules/bitcore-wallet-service/node_modules/bitcore-lib

# Finally remove unnecessary packages again
USER root
RUN apt-get -y remove --purge build-essential && \
    apt-get -y autoremove && \
    apt-get -y clean
USER node

# Apply bugfixes
COPY patches/01-fix-insight-apiprefix.patch /home/node/bitcore/node_modules/bitcore-wallet-service/01-fix-insight-apiprefix.patch
RUN cd /home/node/bitcore/node_modules/bitcore-wallet-service && \
    patch -p1 < /home/node/bitcore/node_modules/bitcore-wallet-service/01-fix-insight-apiprefix.patch && \
    rm -f /home/node/bitcore/node_modules/bitcore-wallet-service/01-fix-insight-apiprefix.patch
COPY patches/02-blockchainmonitor-no-testnet-log.patch /home/node/bitcore/node_modules/bitcore-wallet-service/02-blockchainmonitor-no-testnet-log.patch
RUN cd /home/node/bitcore/node_modules/bitcore-wallet-service && \
    patch -p1 < /home/node/bitcore/node_modules/bitcore-wallet-service/02-blockchainmonitor-no-testnet-log.patch && \
    rm -f /home/node/bitcore/node_modules/bitcore-wallet-service/02-blockchainmonitor-no-testnet-log.patch
COPY patches/03-bitcoind-rpc-queuing.patch /home/node/bitcore/node_modules/bitcoind-rpc/03-bitcoind-rpc-queuing.patch
RUN cd /home/node/bitcore/node_modules/bitcoind-rpc && \
    patch -p1 < /home/node/bitcore/node_modules/bitcoind-rpc/03-bitcoind-rpc-queuing.patch && \
    npm install && \
    rm -f /home/node/bitcore/node_modules/bitcoind-rpc/03-bitcoind-rpc-queuing.patch

# Define environment variables through which the container can be fine-tuned
ENV BITCOIND_DATA_DIR="/home/node/bitcoind" \
    BITCOIND_MAX_UPLOAD_TARGET=144 \
    MONGO_DB_HOSTNAME="db" \
    MONGO_DB_PORT=27017

# Specify how to start the bitcore node
COPY docker-entrypoint.sh /home/node/docker-entrypoint.sh
CMD ["/home/node/docker-entrypoint.sh"]