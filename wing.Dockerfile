# Stage 1 (Build)
FROM golang:1.20.12-alpine

WORKDIR /etc/pterodactyl
RUN apk add curl

RUN curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
RUN chmod u+x /usr/local/bin/wings
