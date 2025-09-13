# syntax=docker/dockerfile:1

# ---- Build the Go app that lives in ./api (submodule) ----
FROM golang:1.23 AS build
# Let Go auto-download the exact toolchain if needed
ENV GOTOOLCHAIN=auto
ENV GO111MODULE=on
ENV CGO_ENABLED=0

WORKDIR /app
# Copy ONLY the API submodule (where go.mod and main.go are)
COPY api/ ./api/

# Build the backend
WORKDIR /app/api
# Use the public Go proxy, then fall back direct
RUN go env -w GOPROXY=https://proxy.golang.org,direct
RUN go mod download
RUN GOOS=linux GOARCH=amd64 go build -o /server .

# ---- Minimal runtime image ----
FROM gcr.io/distroless/static-debian12
EXPOSE 8080
COPY --from=build /server /server
ENTRYPOINT ["/server","--server"]
