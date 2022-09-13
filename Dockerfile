########
# base #
########
FROM ubuntu:jammy AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    bash-completion \
    sudo \
    python3 \
    libpython3-dev \
    python3-pip \
    python3-setuptools \
    git \
    build-essential \
    software-properties-common \
    locales-all locales \
    libudev-dev \
    gpg-agent \
    vim \
    less \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ethereum/ethereum && \
    apt-get update && apt-get install -y --no-install-recommends \
    ethereum \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - && sudo apt-get install -y --no-install-recommends nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN npm install --global yarn

###########
# echidna #
###########
FROM base AS echidna

COPY --from=trailofbits/echidna:latest /usr/local/bin/echidna-test /usr/local/bin/echidna-test

RUN update-locale LANG=en_US.UTF-8 && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

###########
# slither #
###########
FROM echidna AS slither

RUN pip3 --no-cache-dir install solc-select
RUN solc-select install all && SOLC_VERSION=0.8.0 solc-select versions | head -n1 | xargs solc-select use

RUN apt-get update && apt-get install -y libasound2
RUN pip3 --no-cache-dir install slither-analyzer pyevmasm pygame

# #############
# # manticore #
# #############
# FROM slither AS manticore

# RUN pip3 --no-cache-dir install --upgrade manticore

# ###########
# # foundry #
# ###########
# FROM slither AS foundry

# RUN curl -L https://foundry.paradigm.xyz | bash
# RUN . /root/.bashrc && foundryup

ENTRYPOINT ["/bin/bash"]