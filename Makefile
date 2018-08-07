CMD = ip-cli
TARGET = dist/$(CMD)
GIT_TAG := $(shell (git describe --abbrev=0 --tags 2> /dev/null || echo v0.0.0) | head -n1)
GIT_HASH := $(shell (git show-ref --head --hash=8 2> /dev/null || echo 00000000) | head -n1)
SRC_DIR := $(shell ls -d */|grep -vE 'vendor')

.PHONY: all
all: pack

.PHONY: fmt
fmt:
	# gofmt code
	@gofmt -s -l $(FMT_ARG) $(SRC_DIR) *.go
	@go tool vet $(SRC_DIR)
	@go tool vet *.go

.PHONY: $(CMD)
$(CMD):
	# go build
	go build -o $(TARGET)/$@ \
	   -ldflags='-X "$(PKG_NAME).Build=$(GIT_TAG)-$(GIT_HASH)"' \
	   ./main.go

.PHONY: pack
pack: $(CMD)
	@cp 17monipdb.datx $(TARGET)
	@tar -czf $(TARGET).tar.gz -C $(TARGET) .
	@echo "done"

.PHONY: clean
clean:
	@rm -rf ./$(TARGET)
