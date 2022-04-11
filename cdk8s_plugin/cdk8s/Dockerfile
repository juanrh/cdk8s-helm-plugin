# https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image
FROM registry.access.redhat.com/ubi8/nodejs-14:latest
ARG chart_basename

USER root
RUN dnf -y install npm make golang
RUN npm i -g corepack && yarn global add cdk8s-cli

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

ADD src /go/src
RUN chown -R 1001 /go/src

USER 1001
WORKDIR /go/src/${chart_basename}
RUN make
