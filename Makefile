APP=$(shell basename $(shell git remote get-url origin))
# REGISTRY=gcr.io/devops-intensive-w3
# REGISTRY=styre79
REGISTRY=ghcr.io/styre79
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=$(shell uname | tr '[:upper:]' '[:lower:]')# | tr -d '[:space:]') #linux darwin windows
TARGETARCH=$(shell dpkg --print-architecture) #| tr -d '[:space:]') #amd64 #arm64
TAG=${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

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
	@echo ${TAG}
	docker build . -t ${TAG}


push:
	docker push ${TAG}

clean:
	rm -rf skbot
	docker rmi -f $(shell docker images -q ${REGISTRY}/${APP})