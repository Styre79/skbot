APP=$(shell basename $(shell git remote get-url origin))
# REGISTRY=gcr.io/devops-intensive-w3
REGISTRY=styre79
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=$(shell uname | tr '[:upper:]' '[:lower:]') #linux darwin windows
TARGETARCH=$(shell dpkg --print-architecture) #amd64 #arm64

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: get format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o skbot -ldflags "-X="github.com/Styre79/skbot/cmd.appVersion=${VERSION}

linux: format get 
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o skbot -ldflags "-X="github.com/Styre79/skbot/cmd.appVersion=${VERSION}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o skbot -ldflags "-X="github.com/Styre79/skbot/cmd.appVersion=${VERSION}

mac: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o skbot -ldflags "-X="github.com/Styre79/skbot/cmd.appVersion=${VERSION}

arm: format get
	CGO_ENABLED=0 GOOS=${shell uname | tr '[:upper:]' '[:lower:]'} GOARCH=arm64 go build -v -o skbot -ldflags "-X="github.com/Styre79/skbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf skbot
	docker rmi -f $(shell docker images -q ${REGISTRY}/${APP})