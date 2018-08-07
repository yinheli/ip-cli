CMD = ip-cli
GIT_TAG := $(shell (git describe --abbrev=0 --tags 2> /dev/null || echo v0.0.0) | head -n1)
GIT_HASH := $(shell (git show-ref --head --hash=8 2> /dev/null || echo 00000000) | head -n1)
SRC_DIR := $(shell ls -d */|grep -vE 'vendor')

PLATFORMS := linux/amd64 darwin/amd64
temp = $(subst /, ,$@)
os = $(word 1, $(temp))
arch = $(word 2, $(temp))
TARGET = dist/$(CMD)-$(os)-$(arch)

.PHONY: all
all: clean $(PLATFORMS)

.PHONY: fmt
fmt:
	# gofmt code
	@gofmt -s -l -w $(SRC_DIR) *.go
	@go tool vet $(SRC_DIR)
	@go tool vet *.go

.PHONY: $(CMD)
$(CMD):
	# go build
	go build -o $(TARGET)/$@ \
		-ldflags='-X "main.Build=$(GIT_TAG)-$(GIT_HASH)"' \
		./main.go

PHONY: $(PLATFORMS)
$(PLATFORMS):
	GOOS=$(os) GOARCH=$(arch) go build \
	-o $(TARGET)/$(CMD) \
	-ldflags='-X "main.Build=$(GIT_TAG)-$(GIT_HASH)"' \
	./main.go
	@cp 17monipdb.datx $(TARGET)
	@tar -czf $(TARGET)-$(os)-$(arch).tar.gz -C $(TARGET) .

.PHONY: clean
clean:
	@rm -rf ./dist
