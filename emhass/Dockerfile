ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install requirements for add-on
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone and install EMHASS-EV from your repository
ARG EMHASS_VERSION=master
RUN \
  git clone --branch ${EMHASS_VERSION} --depth 1 \
    https://github.com/tomvanacker85/emhass-ev.git /app/emhass-source \
  && cd /app/emhass-source \
  && pip3 install --no-cache-dir --break-system-packages -e .

# Copy run script (cache buster: v3)
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
