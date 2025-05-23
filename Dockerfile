# https://github.com/nodesource/distributions?tab=readme-ov-file#debian-and-ubuntu-based-distributions
# docker build -t vault:test .
FROM ubuntu:24.04 AS build

ARG GO_VER=1.23
ARG VAULT_VER=1.19.2

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -y \
    && apt-get install --no-install-recommends -y vim make gawk wget curl ca-certificates golang-${GO_VER} git man sudo \
    && curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
    && bash /tmp/nodesource_setup.sh \
    && apt-get install -y nodejs \
    && npm install --global yarn \
    && export PATH=$PATH:/usr/lib/go-${GO_VER}/bin; export GOBIN=/usr/local/bin; \
       git clone --depth=1 --branch v${VAULT_VER} https://github.com/hashicorp/vault.git /tmp/vault \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV PATH=$PATH:/usr/lib/go-${GO_VER}/bin
ENV GOBIN=/usr/local/bin
RUN make -C /tmp/vault bootstrap && make -C /tmp/vault static-dist dev-ui \
    && rm -rf /tmp/*

FROM ubuntu:24.04
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -y \
    && apt-get install --no-install-recommends -y vim make gawk wget curl ca-certificates git man sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local/bin/vault /usr/local/bin/vault
RUN useradd -M -r -d /opt/vault --uid 999 vault \
    && mkdir -vp /etc/vault/tls \
    && chown -vR vault:vault /etc/vault \
    && mkdir -vp /opt/vault/data \
    && chown -vR vault:vault /opt/vault
COPY --chmod=755 entrypoint.sh /
COPY --chown=vault certs/ /etc/vault/tls/
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 8200
