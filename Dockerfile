FROM mhart/alpine-node:4
MAINTAINER Jens Mittag <kontakt@jensmittag.de>

# Container User
ARG CONTAINER_USER=bitcore
ARG CONTAINER_UID=1000
ARG CONTAINER_GROUP=bitcore
ARG CONTAINER_GID=1000

# Create user
RUN addgroup -g $CONTAINER_GID -S $CONTAINER_GROUP && \
    adduser -u $CONTAINER_UID -S $CONTAINER_USER

# First install Python
RUN apk add --update \
    python \
    python-dev \
    build-base \
    bash \
    coreutils \
    binutils \
    findutils \
  && rm -rf /var/cache/apk/*

# Then install bitcore wallet service via NPM
WORKDIR /bws
RUN npm install bitcore-wallet-service@1.17.0
RUN ln -sf /bws/node_modules/bitcore-wallet-service /bws/bitcore-wallet-service
WORKDIR /bws/bitcore-wallet-service

# Finally remove unnecessary packages again
RUN apk del \
    python \
    python-dev \
    build-base

# Clean up build-time packages
RUN apk del --purge ${BUILD_DEPS} \

# Clean up anything else
 && rm -fr \
    /etc/nginx/*.default \
    /tmp/* \
    /var/tmp/* \
/var/cache/apk/*

# Specify how to start BWS
CMD npm start && \
    sleep 2 && \
    tail -f logs/bcmonitor.log && \
    tail -f logs/bws.log && \
    tail -f logs/emailservice.log && \
    tail -f logs/fiatrateservice.log && \
    tail -f logs/locker.log && \
    tail -f logs/messagebroker.log && \
    tail -f logs/pushnotificationsservice.log