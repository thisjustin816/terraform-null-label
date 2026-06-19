module "label" {
  source = "../.."

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

output "azure_storage_account" {
  value = module.label.id_resource.storage_account
}

output "azure_key_vault" {
  value = module.label.id_resource.key_vault
}

output "aws_s3_bucket" {
  value = module.label.id_resource.aws_s3_bucket
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

output "aws_sqs_fifo_queue" {
  value = module.label.id_resource.aws_sqs_fifo_queue
}

output "aws_dynamic_resource" {
  value = module.label.id_resource.aws_bedrockagent_agent
}

output "resource_hash" {
  value = module.label.resource_hash
}

# Verifies that `resource_codes` extends the curated catalog rather than replacing it,
# and that an explicit code wins over both the catalog and an auto-generated code.
module "override" {
  source = "../.."

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

  resource_codes = {
    aws_bedrockagent_agent = "agent" # explicit code beats the auto-generated "bedrockagenta"
    aws_lambda_function    = "fn"    # explicit code beats the catalog "lambda"
  }
}

# Catalog entries that were not mentioned must still resolve.
output "override_s3_preserved" {
  value = module.override.id_resource.aws_s3_bucket
}

output "override_sqs_preserved" {
  value = module.override.id_resource.aws_sqs_fifo_queue
}

output "override_kv_preserved" {
  value = module.override.id_resource.key_vault
}

# Explicit override wins over the catalog code.
output "override_lambda" {
  value = module.override.id_resource.aws_lambda_function
}

# Explicit override wins over the auto-generated code.
output "override_agent" {
  value = module.override.id_resource.aws_bedrockagent_agent
}

# Verifies context chaining: the child re-derives codes from the inherited (extended)
# catalog, keeps the parent's explicit code override, chains the parent's explicit rule,
# and its own resource_codes override is not clobbered by inherited rules.
module "chain_parent" {
  source = "../.."

  namespace   = "eg"
  application = "orders"
  region      = "us-west-2"
  environment = "prod"

  resource_codes       = { aws_lambda_function = "fn" }
  resource_label_rules = { aws_cloudwatch_log_group = { include_region = true } }
}

module "chain_child" {
  source = "../.."

  context        = module.chain_parent.context
  attributes     = ["api"]
  resource_codes = { aws_sqs_queue = "q" }
}

# Parent's explicit code override survives the chain.
output "chain_child_lambda" {
  value = module.chain_child.id_resource.aws_lambda_function
}

# Child's own override is applied (not clobbered by inherited rules).
output "chain_child_sqs" {
  value = module.chain_child.id_resource.aws_sqs_queue
}

# Catalog propagates through the chain.
output "chain_child_s3" {
  value = module.chain_child.id_resource.aws_s3_bucket
}

# Parent's explicit resource_label_rules (include_region) chains.
output "chain_child_log" {
  value = module.chain_child.id_resource.aws_cloudwatch_log_group
}

module "chain_tag_child" {
  source = "../.."

  context     = module.chain_parent.context
  application = "billing"
  attributes  = ["api"]
}

output "chain_child_application_tag" {
  value = module.chain_tag_child.tags["Application"]
}

output "chain_child_id_tag" {
  value = module.chain_tag_child.tags["Id"]
}
