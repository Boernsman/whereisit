# Use the official Go image to build the application
FROM golang:1.22 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to install dependencies
COPY go.mod go.sum ./

# Download all dependencies. They will be cached if the go.mod and go.sum files are not changed.
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN go build -o whereisit .

# Use a smaller image for deployment
FROM alpine:3.18

# Install certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create a folder for certificates (assuming you have your own SSL cert and key)
RUN mkdir -p /etc/ssl/certs && mkdir -p /etc/ssl/private

# Copy the SSL certificates (adjust paths as necessary)
COPY ./certs/server.crt /etc/ssl/certs/
COPY ./certs/server.key /etc/ssl/private/

# Copy the built Go binary from the builder
COPY --from=builder /app/main /app/main

# Expose HTTP on port 80 and HTTPS on port 443
EXPOSE 80 443

# Command to run the executable
CMD ["/app/whereisit"]
