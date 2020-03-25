FROM golang:1.14 as build

COPY ./ /go/src/github.com/jetstack/cert-manager-venafi-demo/pingpong

WORKDIR /go/src/github.com/jetstack/cert-manager-venafi-demo/pingpong

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo ./

FROM alpine:3.11

COPY --from=build /go/src/github.com/jetstack/cert-manager-venafi-demo/pingpong/pingpong /usr/local/bin/

ENTRYPOINT /usr/local/bin/pingpong
