# -----------------------------------------------------------
# Stage 1: Build stage
# -----------------------------------------------------------

# Use the official lightweight Go image to build the binary
FROM golang:1.22-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy all files from the current directory to the container
COPY . .

# Initialize a new Go module (if not already initialized)
RUN go mod init go-docker-app || true

# Build the Go application as a statically linked binary
# CGO_ENABLED=0 ensures compatibility with Alpine (musl libc)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# -----------------------------------------------------------
# Stage 2: Runtime stage
# -----------------------------------------------------------

# Use a small Alpine image to keep the final image size minimal
FROM alpine:latest

# Set working directory for the runtime container
WORKDIR /root/

# Copy the compiled binary from the build stage
COPY --from=build /app/main .

# Expose port 8080 to access the application
EXPOSE 8080

# Command to run the application
CMD ["./main"]
