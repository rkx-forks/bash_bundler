build:
	mkdir -p build
	go build -o build/bash_bundler

lint:
	go run github.com/golangci/golangci-lint/cmd/golangci-lint run ./...

test:
	go test ./pkg/bundler/ -v

clean:
	rm -rf build