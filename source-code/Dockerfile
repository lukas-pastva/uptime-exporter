FROM golang:1.16-buster AS builder
WORKDIR /app
COPY ./source-code/go.* ./
RUN go mod download
COPY ./source-code/*.go ./
RUN go build -o /uptime-exporter
FROM debian:bullseye-slim

WORKDIR /usr/local/bin

RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends -o=Dpkg::Use-Pty=0 \
    apt-transport-https \
    bc \
    ca-certificates \
    curl \
    jq \
    vim \
    libzip-dev \
    procps \
    unzip \
    zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# yq
RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq

COPY --from=builder /uptime-exporter /usr/local/bin/uptime-exporter
COPY ./source-code/bin /usr/local/bin
RUN chmod -R +x /usr/local/bin

EXPOSE 9199
RUN useradd -ms /bin/bash nonrootuser

USER root

USER nonrootuser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]