package test

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const v1ResourceAwareConfiguration = `
module "label" {
  source = "%s"

  namespace   = "eg"
  application = "orders"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["api"]

  aws_resource_types = ["bedrockagent_agent"]
  resource_hash_values = [
    "aws",
    "123456789012",
    "us-west-2",
  ]

  resource_label_rules = {
    aws_cloudwatch_log_group = {
      include_region = true
    }
  }
}

output "base_id" {
  value = module.label.id
}

output "resource_hash" {
  value = module.label.resource_hash
}

output "aws_lambda_function" {
  value = module.label.id_resource.aws_lambda_function
}

output "aws_lambda_function_unique" {
  value = module.label.id_resource_unique.aws_lambda_function
}

output "aws_cloudwatch_log_group" {
  value = module.label.id_resource.aws_cloudwatch_log_group
}

output "aws_s3_bucket" {
  value = module.label.id_resource.aws_s3_bucket
}

output "aws_sqs_fifo_queue" {
  value = module.label.id_resource.aws_sqs_fifo_queue
}

output "aws_dynamic_resource" {
  value = module.label.id_resource.aws_bedrockagent_agent
}

output "azure_key_vault" {
  value = module.label.id_resource.key_vault
}

output "azure_storage_account" {
  value = module.label.id_resource.storage_account
}

output "key_vault_alias" {
  value = module.label.id_for_keyvault
}

output "storage_account_alias" {
  value = module.label.id_for_storage_account
}
`

func TestV1ResourceAwareGolden(t *testing.T) {
	t.Parallel()

	testDirectory := t.TempDir()
	configuration := fmt.Sprintf(
		v1ResourceAwareConfiguration,
		filepath.ToSlash(v1FixtureDirectory(t)),
	)
	writeTestFile(t, testDirectory, "main.tf", []byte(configuration))

	terraformOptions := &terraform.Options{
		TerraformDir: testDirectory,
		NoColor:      true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	expected := readJSONFile[map[string]any](t, goldenFilePath(t, "v1-resource-aware.json"))
	actual := terraform.OutputAll(t, terraformOptions)
	assert.Equal(t, expected, actual)
}
