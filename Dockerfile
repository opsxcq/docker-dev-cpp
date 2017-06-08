FROM debian:jessie

LABEL maintainer "opsxcq@thestorm.com.br"

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

