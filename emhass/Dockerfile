ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install requirements for add-on
RUN \
  apk add --no-cache \
    python3 \
    py3-pip \
    git \
  && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Clone and install EMHASS-EV from your repository
ARG EMHASS_VERSION=main
RUN \
  git clone --branch ${EMHASS_VERSION} --depth 1 \
    https://github.com/tomvanacker85/emhass-ev.git /tmp/emhass \
  && cd /tmp/emhass \
  && pip3 install --no-cache-dir -e . \
  && rm -rf /tmp/emhass/.git

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
