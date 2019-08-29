FROM debian:8-slim as builder

LABEL maintainer="Ernesto Serrano <ernesto@exolever.com>"

WORKDIR /app

RUN apt-get update && apt-get install -y \
        libminiupnpc-dev \
        build-essential \
        libdb++-dev \
        libcrypto++-dev \
        libboost-all-dev \
        libssl-dev \
        gpw \
        pwgen

# Copying rest of files
COPY . .

RUN cd src/ && make -f makefile.unix USE_UPNP=1 STATIC=1

FROM debian:8-slim as rutaniod

WORKDIR /app

COPY --from=builder /app/src/rutaniod /usr/bin/

RUN apt-get update && apt-get install -y \
        libminiupnpc10 \
        gpw \
        pwgen \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.rutanio/ && \
    echo "rpcuser=rutaniorpc" > /root/.rutanio/rutanio.conf && \
    echo "rpcpassword=$(pwgen -s 32 1)" >> /root/.rutanio/rutanio.conf


EXPOSE 6781

ENTRYPOINT ["exosd", "-upnp"]

CMD ["exosd", "getinfo"]

