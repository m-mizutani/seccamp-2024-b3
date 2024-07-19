FROM golang:1.22 AS build-go
ENV CGO_ENABLED=0
ARG BUILD_VERSION

WORKDIR /app
COPY go.* ./
RUN go mod download

COPY . /app
RUN go build -o detector

FROM gcr.io/distroless/base:nonroot
USER nonroot
COPY --from=build-go /app/detector /detector

WORKDIR /

ENTRYPOINT ["/detector"]
