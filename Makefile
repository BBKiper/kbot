APP=$(shell basename $(shell git remote get-url origin) |sed 's|\..*||')
REGISTRY=bbkiper
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux windows darwin
TARGETARCH=amd64 #amd64 arm64 etc

help:
	@echo "#### KBOT BINARY BUILD ####"
	@echo "run 'make linux' to build kbot for linux"
	@echo "run 'make windows' to build kbot for windows"
	@echo "run 'make macos' to build kbot for macos"
	@echo ""
	@echo "#### KBOT DOCKER IMAGE ####"
	@echo "firstly specify required OS and ARCH im Makefile"
	@echo ""
	@echo "change TARGETOS variable for OS"
	@echo "change TARGETARCH variable for ARCH"
	@echo ""
	@echo "run 'make image' to build an image with the parameters you specified earlier"
	@echo ""
	@echo "change REGISTRY variable to change docker registry to yours"
	@echo "run 'make push' to upload your image to the specified registry"
	@echo ""
	@echo "run 'make clean' to remove the binary file and container image"
	
format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/BBKiper/kbot/cmd.appVersion=${VERSION}

linux: 
	${MAKE} build TARGETOS=linux TARGETARCH=amd64

windows:
	${MAKE} build TARGETOS=windows TARGETARCH=amd64

macos:
	${MAKE} build TARGETOS=darwin TARGETARCH=arm64

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} --build-arg TARGETARCH=${TARGETARCH} --build-arg TARGETOS=${TARGETOS}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}