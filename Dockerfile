FROM golang:1.20 as builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /go/src/app
COPY . .
RUN make build TARGETARCH=${TARGETARCH} TARGETOS=${TARGETOS}

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot" ]