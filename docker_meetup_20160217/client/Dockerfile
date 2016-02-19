# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang

ENV GOBIN /go/bin

# Copy the local package files to the container's workspace.
ADD client.go /go/src/client/client.go

# Build the outyet command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN go get github.com/gocql/gocql
RUN go install /go/src/client/client.go

# Run the outyet command by default when the container starts.
ENTRYPOINT /go/bin/client

