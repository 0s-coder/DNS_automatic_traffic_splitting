BINARY_NAME=doh-autoproxy
BUILD_DIR=build
LDFLAGS=-ldflags "-s -w"

.PHONY: all clean windows linux-amd64 linux-arm64

all: windows linux-amd64 linux-arm64

clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete."

windows:
	@echo "Building for Windows x64..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe cmd/doh-autoproxy/main.go

linux-amd64:
	@echo "Building for Linux AMD64..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 cmd/doh-autoproxy/main.go

linux-arm64:
	@echo "Building for Linux ARM64..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 cmd/doh-autoproxy/main.go