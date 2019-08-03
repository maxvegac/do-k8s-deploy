FROM alpine:3.8

RUN apk add --no-cache curl ca-certificates perl

WORKDIR /workspace

COPY entrypoint.sh /workspace/entrypoint.sh

ENV KUBECTL_VERSION=1.15.1

ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

ENV HOME=/config

RUN set -x && \
    chmod +x /usr/local/bin/kubectl && \
    \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    \
    # Basic check it works.
    kubectl version --client

ENV DOCTL_VERSION=1.23.1

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz  | tar xz

RUN mv doctl /usr/local/bin/doctl

ENTRYPOINT /workspace/entrypoint.sh
