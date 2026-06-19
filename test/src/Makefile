.DEFAULT_GOAL : all
.PHONY: all

## Default target
all: test

.PHONY : init
## Initialize tests
init:
	@exit 0

.PHONY : test
## Run tests
test: init
	go mod download
	go test -v -timeout 20m -run '^TestExamplesResourceAware$$' .

.PHONY : clean
## Clean up files
clean:
	rm -rf ../../examples/resource-aware/.terraform ../../examples/resource-aware/.terraform.lock.hcl
