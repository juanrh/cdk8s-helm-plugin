.DEFAULT_GOAL := release

# https://es.wikipedia.org/wiki/Make
# NOTE: real tabs needed or we get "missing separator"!

OUTPUT_EXEC := dist/hello-cdk8s
OUTPUT_MANIFEST := dist/hello-cdk8s.k8s.yaml
PACKAGE_GOPATH_ROOT := $$(go env GOPATH)/src/github.com/juanrh/hello-cdk8s
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

build:
	go build -o $(OUTPUT_EXEC)

deps:
	ls $(PACKAGE_GOPATH_ROOT) || (mkdir -p $$(dirname $(PACKAGE_GOPATH_ROOT))  && ln -s $(ROOT_DIR) $(PACKAGE_GOPATH_ROOT))
	go get .

synth:
	cdk8s synth
	echo "Output k8s manifest available at $(OUTPUT_MANIFEST)"

import:
	cdk8s import

# https://cdk8s.io/docs/latest/getting-started/#importing-constructs-for-the-kubernetes-api
# When cdk8s init created your project it already executed cdk8s import for you, 
# so you should see an imports directory already there. You can either commit
# this directory to source-control or generate it as part of your build process.
clean:
	rm -rf imports
	rm -rf dist

release: clean import deps build
