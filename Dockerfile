FROM alpine:3.8

RUN apk add --no-cache curl ca-certificates perl

COPY entrypoint.sh /workspace/entrypoint.sh

ENV KUBECTL_VERSION=1.15.1

ENV DOCTL_VERSION=1.23.1

ENV HELM_VERSION=2.14.3

ENV HOME=/config

ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN set -x && \
    chmod +x /usr/local/bin/kubectl && \
    \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    \
    # Basic check it works.
    kubectl version --client

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN (curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz  | tar xz) && mv doctl /usr/local/bin/doctl

RUN (curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xz) && (mv linux-amd64/helm /usr/local/bin/helm && mv linux-amd64/tiller /usr/local/bin/tiller)

ENTRYPOINT /workspace/entrypoint.sh
