# syntax=docker/dockerfile:1

# ---- Build the Go app ----
FROM golang:1.22 AS build
WORKDIR /app

# Download dependencies first (faster builds)
COPY go.mod ./
RUN go mod download

# Copy the rest of the source and build the binary
COPY . .
# If your app's main.go is at the repo root, this works as-is.
# (If it's in cmd/server or another folder, tell me and I’ll adjust this line.)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server .

# ---- Minimal runtime image ----
FROM gcr.io/distroless/static-debian12
# Default port the app will listen on (we can change in Azure later)
EXPOSE 8080
COPY --from=build /app/server /server

# Start the API/server by default.
# (We’ll override this in Azure when we run migrations, e.g. with --migrations)
ENTRYPOINT ["/server","--server"]
