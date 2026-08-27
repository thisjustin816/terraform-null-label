module "parent" {
  source = "../../.."

  namespace   = "Eg"
  application = "Orders.API"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["API_Gateway"]

  resource_codes = {
    aws_elasticache_replication_group = "redis"
    custom_service                    = "svc"
    custom_widget                     = "parent"
  }

  resource_label_rules = {
    custom_service = {
      component_delimiter = ""
      forbidden_regexes   = []
      min_length          = 0
      max_length          = 63
      trim_chars          = null
      validation_regex    = "^.*$"
    }
  }
}

module "child" {
  source = "../../.."

  context     = module.parent.context
  application = "Child.API"

  resource_codes = {
    custom_service = ""
    custom_widget  = "child"
  }

  resource_label_rules = {
    custom_service = {
      group_delimiter = ""
      max_length      = 64
    }
  }
}

module "empty" {
  source = "../../.."
}

output "parent_context" {
  value = module.parent.normalized_context
}

output "child_context" {
  value = module.child.normalized_context
}

output "empty_context" {
  value = module.empty.normalized_context
}

output "parent_id" {
  value = module.parent.id
}

output "child_id" {
  value = module.child.id
}

output "empty_id" {
  value = module.empty.id
}
