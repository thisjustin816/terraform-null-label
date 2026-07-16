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
	go test -v -timeout 20m -run '^(TestExamplesResourceAware|TestLabelOrderValidation)$$' .

.PHONY : clean
## Clean up files
clean:
	rm -rf ../../examples/resource-aware/.terraform ../../examples/resource-aware/.terraform.lock.hcl ../../test/fixtures/label-order-validation/.terraform ../../test/fixtures/label-order-validation/.terraform.lock.hcl
