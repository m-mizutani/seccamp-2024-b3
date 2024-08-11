ARG GO_VERSION=1.22.4
ARG BUILDPLATFORM=linux/amd64

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS base
WORKDIR /src

RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download -x

FROM --platform=$BUILDPLATFORM base AS build

ARG GOARCH=amd64
ARG GOOS=linux

RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=. \
    CGO_ENABLED=0 GOARCH=$GOARCH go build -o /detector

FROM gcr.io/distroless/base:nonroot AS release

COPY --chown=nonroot:nonroot --from=build /detector /detector
USER nonroot

EXPOSE 8080

ENTRYPOINT [ "/detector" ]
