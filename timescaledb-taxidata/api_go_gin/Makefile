# @ means command won't be printed
build:
	@go build -o bin/go_cron

# Call build first
run: build
	@./bin/go_cron

test:
	@go test -v ./...

image_build:
	@docker build -t go-cron .

image_run:
	@docker run --rm go-cron
