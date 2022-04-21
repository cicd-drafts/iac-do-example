FROM golang:1.17.6 AS build
WORKDIR /
COPY main.go ./
RUN CGO_ENABLED=0 go build main.go

FROM gcr.io/distroless/static
WORKDIR /
COPY --from=build --chown=nonroot:nonroot /main /application
EXPOSE 11130
USER nonroot:nonroot
ENTRYPOINT ["/application"]
