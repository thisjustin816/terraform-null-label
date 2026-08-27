variable "legacy_resource_codes" {
  type    = map(string)
  default = {}
}

module "parent" {
  source = "../v1-module"

  namespace   = "Eg.Name"
  application = "Orders.API"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["API_Gateway"]

  resource_codes = var.legacy_resource_codes
  resource_label_rules = {
    aws_lambda_function = {
      delimiter       = "_"
      globally_unique = true
      include_region  = true
    }
    storage_account = {
      delimiter       = ""
      globally_unique = true
    }
  }
}

module "child" {
  source = "../../.."

  context = module.parent.context
}

module "legacy_child" {
  source = "../v1-module"

  context = module.child.context
}

output "parent_context" {
  value = module.parent.normalized_context
}

output "child_context" {
  value = module.child.normalized_context
}

output "legacy_child_context" {
  value = module.legacy_child.normalized_context
}

output "child_resource_codes" {
  value = module.child.resource_codes
}

output "child_resource_rules" {
  value = module.child.resource_label_rules
}

output "parent_id" {
  value = module.parent.id
}

output "child_id" {
  value = module.child.id
}

output "parent_id_resource" {
  value = module.parent.id_resource
}

output "legacy_child_id_resource" {
  value = module.legacy_child.id_resource
}
