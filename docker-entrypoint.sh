#!/bin/bash

set -o errexit

BITCOIND_DATA_DIR="/home/node/bitcoind"
BITCOIND_PID="${BITCOIND_DATA_DIR}/bitcoind.pid"
BITCOIND_CONFIG="${BITCOIND_DATA_DIR}/bitcoin.conf"
BITCORE_NODE_CONFIG="/home/node/bitcore/bitcore-node.json"
BITCORE_WALLET_CONFIG="/home/node/bitcore/node_modules/bitcore-wallet-service/config.js"

# Generate default bitcoin.conf if none is yet existing
if [ ! -f ${BITCOIND_CONFIG} ]; then
    echo "server=1" >> ${BITCOIND_CONFIG}
    echo "whitelist=127.0.0.1" >> ${BITCOIND_CONFIG}
    echo "txindex=1" >> ${BITCOIND_CONFIG}
    echo "addressindex=1" >> ${BITCOIND_CONFIG}
    echo "timestampindex=1" >> ${BITCOIND_CONFIG}
    echo "upnp=0" >> ${BITCOIND_CONFIG}
    echo "spentindex=1" >> ${BITCOIND_CONFIG}
    echo "zmqpubrawtx=tcp://127.0.0.1:28332" >> ${BITCOIND_CONFIG}
    echo "zmqpubhashblock=tcp://127.0.0.1:28332" >> ${BITCOIND_CONFIG}
    echo "rpcallowip=127.0.0.1" >> ${BITCOIND_CONFIG}
    echo "rpcuser=bitcoin" >> ${BITCOIND_CONFIG}
    echo "rpcpassword=local321" >> ${BITCOIND_CONFIG}
    echo "rpcworkqueue=128" >> ${BITCOIND_CONFIG}
    echo "maxuploadtarget=${BITCOIND_MAX_UPLOAD_TARGET}" >> ${BITCOIND_CONFIG}
    echo "uacomment=bitcore" >> ${BITCOIND_CONFIG}

    echo "Created initial bitcoin.conf in directory '${BITCOIND_DATA_DIR}'"
fi

# Generate default bitcore-node.json configuration if none is yet existing
if [ ! -f ${BITCORE_NODE_CONFIG} ]; then
    echo "{" >> ${BITCORE_NODE_CONFIG}
    echo "  \"network\": \"livenet\"," >> ${BITCORE_NODE_CONFIG}
    echo "  \"port\": 3001," >> ${BITCORE_NODE_CONFIG}
    echo "  \"services\": [" >> ${BITCORE_NODE_CONFIG}
    echo "    \"web\"," >> ${BITCORE_NODE_CONFIG}
    echo "    \"bitcoind\"," >> ${BITCORE_NODE_CONFIG}
    echo "    \"bitcore-wallet-service\"," >> ${BITCORE_NODE_CONFIG}
    echo "    \"insight-api\"" >> ${BITCORE_NODE_CONFIG}
    echo "  ]," >> ${BITCORE_NODE_CONFIG}
    echo "  \"servicesConfig\": {" >> ${BITCORE_NODE_CONFIG}
    echo "    \"bitcoind\": {" >> ${BITCORE_NODE_CONFIG}
    echo "      \"spawn\": {" >> ${BITCORE_NODE_CONFIG}
    echo "        \"datadir\": \"${BITCOIND_DATA_DIR}\"," >> ${BITCORE_NODE_CONFIG}
    echo "        \"exec\": \"/home/node/bitcore/node_modules/bitcore-node/bin/bitcoind\"" >> ${BITCORE_NODE_CONFIG}
    echo "      }" >> ${BITCORE_NODE_CONFIG}
    echo "    }," >> ${BITCORE_NODE_CONFIG}
    echo "    \"web\": {" >> ${BITCORE_NODE_CONFIG}
    echo "      \"jsonRequestLimit\": \"200kb\"" >> ${BITCORE_NODE_CONFIG}
    echo "    }," >> ${BITCORE_NODE_CONFIG}
    echo "    \"insight-api\": {" >> ${BITCORE_NODE_CONFIG}
    echo "      \"disableRateLimiter\": true," >> ${BITCORE_NODE_CONFIG}
    echo "      \"rateLimiterOptions\": {"  >> ${BITCORE_NODE_CONFIG}
    echo "        \"whitelist\": [\"::ffff:127.0.0.1\"]" >> ${BITCORE_NODE_CONFIG}
    echo "      }", >> ${BITCORE_NODE_CONFIG}
    echo "      \"routePrefix\": \"insight-api\"," >> ${BITCORE_NODE_CONFIG}
    echo "      \"enableCache\": true" >> ${BITCORE_NODE_CONFIG}
    echo "    }" >> ${BITCORE_NODE_CONFIG}
    echo "  }" >> ${BITCORE_NODE_CONFIG}
    echo "}" >> ${BITCORE_NODE_CONFIG}

    echo "Created initial bitcore-node.json in directory '/home/node/bitcore'"
fi

# Always generate default config.js for bitcore-wallet-service, if none is yet existing
echo "var config = {" > ${BITCORE_WALLET_CONFIG}
echo "  basePath: '/'," >> ${BITCORE_WALLET_CONFIG}
echo "  disableLogs: false," >> ${BITCORE_WALLET_CONFIG}
echo "  port: 3232," >> ${BITCORE_WALLET_CONFIG}
echo "  storageOpts: {" >> ${BITCORE_WALLET_CONFIG}
echo "    mongoDb: {" >> ${BITCORE_WALLET_CONFIG}
echo "      uri: 'mongodb://${MONGO_DB_HOSTNAME}:${MONGO_DB_PORT}/bws'," >> ${BITCORE_WALLET_CONFIG}
echo "    }," >> ${BITCORE_WALLET_CONFIG}
echo "  }," >> ${BITCORE_WALLET_CONFIG}
echo "  lockOpts: {" >> ${BITCORE_WALLET_CONFIG}
echo "    lockerServer: {" >> ${BITCORE_WALLET_CONFIG}
echo "      host: 'localhost'," >> ${BITCORE_WALLET_CONFIG}
echo "      port: 3231," >> ${BITCORE_WALLET_CONFIG}
echo "    }," >> ${BITCORE_WALLET_CONFIG}
echo "  }," >> ${BITCORE_WALLET_CONFIG}
echo "  messageBrokerOpts: {" >> ${BITCORE_WALLET_CONFIG}
echo "    messageBrokerServer: {" >> ${BITCORE_WALLET_CONFIG}
echo "      url: 'http://localhost:3380'," >> ${BITCORE_WALLET_CONFIG}
echo "    }," >> ${BITCORE_WALLET_CONFIG}
echo "  }," >> ${BITCORE_WALLET_CONFIG}
echo "  blockchainExplorersOpts: {" >> ${BITCORE_WALLET_CONFIG}
echo "    livenet: {" >> ${BITCORE_WALLET_CONFIG}
echo "      provider: 'insight'," >> ${BITCORE_WALLET_CONFIG}
echo "      url: 'http://127.0.0.1:3001'" >> ${BITCORE_WALLET_CONFIG}
echo "    }," >> ${BITCORE_WALLET_CONFIG}
echo "    testnet: {" >> ${BITCORE_WALLET_CONFIG}
echo "      provider: 'insight'," >> ${BITCORE_WALLET_CONFIG}
echo "      url: 'http://127.0.0.1:3001'" >> ${BITCORE_WALLET_CONFIG}
echo "    }" >> ${BITCORE_WALLET_CONFIG}
echo "  }" >> ${BITCORE_WALLET_CONFIG}
echo "};" >> ${BITCORE_WALLET_CONFIG}
echo "module.exports = config;" >> ${BITCORE_WALLET_CONFIG}

echo "Created initial config.js in directory '/home/node/bitcore/node_modules/bitcore-wallet-service'"

# Check if a PID file of a previously started bitcoind instance is still existing
if [ -f ${BITCOIND_PID} ]; then
    rm -f ${BITCOIND_PID}
    echo "Deleted still existing file '${BITCOIND_PID}'"
fi

# Starting bitcore node
./node_modules/.bin/bitcore-node start