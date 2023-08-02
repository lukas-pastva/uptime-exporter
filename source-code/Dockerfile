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
    cron \
    curl \
    containerd \
    docker.io \
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
USER root

RUN mkdir -p /var/log && touch /var/log/cron.log
RUN (crontab -l ; echo "*/15 * * * * /usr/local/bin/metrics.sh >/dev/null") | crontab
RUN echo "uptime_exporter_heart_beat $(date +%s)" > /tmp/metrics.log

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
