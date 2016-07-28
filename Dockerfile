FROM node:0.12
MAINTAINER Brian Olsen <bro@lisberg.dk>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y zip && \
    apt-get clean && \
    mkdir -p /usr/src/app /usr/src/builder && \
    useradd --user-group --system --home-dir /usr/src/app app && \
    chown -R app:app /usr/src/app && \
    curl -L --silent -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod a+x /usr/local/bin/jq && \
    wget https://github.com/Yelp/dumb-init/releases/download/v1.1.2/dumb-init_1.1.2_amd64.deb && \
    dpkg --install dumb-init_*.deb
WORKDIR /usr/src/app
COPY entrypoint.bash /usr/src/builder/entrypoint.bash
ENTRYPOINT ["/usr/src/builder/entrypoint.bash"]
CMD [ "start" ]

