module "parent" {
  source = "../v1-module"

  namespace   = "Eg.Name"
  application = "Orders.API"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["API_Gateway"]

  resource_codes = {
    storage_account = "legacy-storage"
  }

  resource_label_rules = {
    aws_lambda_function = {
      delimiter      = "_"
      include_region = true
    }
  }
}

module "bridge" {
  source = "../../.."

  context = module.parent.context
}

module "descendant" {
  source = "../../.."

  context = module.bridge.context
}

module "legacy_descendant" {
  source = "../v1-module"

  context = module.descendant.context
}

output "parent_context" {
  value = module.parent.normalized_context
}

output "bridge_context" {
  value = module.bridge.normalized_context
}

output "descendant_context" {
  value = module.descendant.normalized_context
}

output "descendant_resource_codes" {
  value = module.descendant.resource_codes
}

output "parent_id" {
  value = module.parent.id
}

output "bridge_id" {
  value = module.bridge.id
}

output "descendant_id" {
  value = module.descendant.id
}

output "parent_id_resource" {
  value = module.parent.id_resource
}

output "legacy_descendant_id_resource" {
  value = module.legacy_descendant.id_resource
}
