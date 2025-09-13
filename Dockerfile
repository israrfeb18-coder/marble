# syntax=docker/dockerfile:1

# ---- Build the Go app in ./api (this repo uses a submodule there) ----
FROM golang:1.22 AS build
WORKDIR /app

# Copy ONLY the api folder (where go.mod and main.go live)
COPY api/ ./api/

# Build
WORKDIR /app/api
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /server .

# ---- Minimal runtime image ----
FROM gcr.io/distroless/static-debian12
EXPOSE 8080
COPY --from=build /server /server

# Start the API by default (we can override with flags for migrations later)
ENTRYPOINT ["/server","--server"]
