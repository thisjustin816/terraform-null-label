variable "resource_codes" {
  type    = map(string)
  default = {}
}

variable "resource_label_rules" {
  type    = any
  default = {}
}

variable "aws_resource_types" {
  type    = set(string)
  default = []
}

module "label" {
  source = "../../.."

  namespace   = "eg"
  application = "orders"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["api"]

  resource_codes       = var.resource_codes
  resource_label_rules = var.resource_label_rules
  aws_resource_types   = var.aws_resource_types

  descriptor_formats = {
    short = {
      format = "%s-%s"
      labels = ["namespace", "application"]
    }
  }
}

module "precedence_builtin" {
  source = "../../.."
}

module "precedence_generated" {
  source = "../../.."

  aws_resource_types = ["lambda_function"]
}

module "precedence_explicit" {
  source = "../../.."

  aws_resource_types = ["lambda_function"]
  resource_codes = {
    aws_lambda_function = "fn"
  }
}

output "base_id" {
  value = module.label.id
}

output "tags" {
  value = module.label.tags
}

output "descriptors" {
  value = module.label.descriptors
}

output "resource_codes" {
  value = module.label.resource_codes
}

output "id_with_resource_code" {
  value = module.label.id_with_resource_code
}

output "resource_name" {
  value = module.label.resource_name
}

output "resource_name_hashed" {
  value = module.label.resource_name_hashed
}

output "resource_name_errors" {
  value = module.label.resource_name_errors
}

output "resource_label_rules" {
  value = module.label.resource_label_rules
}

output "key_vault_alias" {
  value = module.label.id_for_keyvault
}

output "storage_account_alias" {
  value = module.label.id_for_storage_account
}

output "precedence" {
  value = {
    builtin   = module.precedence_builtin.resource_codes["aws_lambda_function"]
    generated = module.precedence_generated.resource_codes["aws_lambda_function"]
    explicit  = module.precedence_explicit.resource_codes["aws_lambda_function"]
  }
}
