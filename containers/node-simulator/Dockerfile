FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 go build -o node-simulator .

FROM alpine:3.21
WORKDIR /app
COPY --from=builder /app/node-simulator .
EXPOSE 8080
ENTRYPOINT ["./node-simulator"]
