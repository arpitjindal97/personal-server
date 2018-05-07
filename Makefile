env ?= devel


PACKR := $(GOPATH)/bin/packr

$(PACKR):
	@echo "Installing packr"
	go get -u github.com/gobuffalo/packr/...

clean:
	@echo "Cleaning the output directory"
	rm -rf output

build: $(PACKR) clean
ifeq ($(env),prod)
	@echo "Making Production build"
	packr
	GOOS=linux GOARCH=amd64 go build -tags prod -o output/flair-prod-linux-amd64
	packr clean
	docker-compose -f prod-compose.yml build
else
	@echo "Making Development build"
	packr
	GOOS=linux GOARCH=amd64 go build -tags devel -o output/flair-devel-linux-amd64
	packr clean
	docker-compose -f devel-compose.yml build
endif


run: build
ifeq ($(env),prod)
	@echo "Running Production images"
	docker-compose -f prod-compose.yml up
else
	@echo "Running Development images"
	docker-compose -f devel-compose.yml up
endif
