module "parent" {
  source = "../../.."

  namespace   = "Eg"
  application = "Orders.API"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["API_Gateway"]

  resource_codes = {
    custom_widget = "widget"
  }

  resource_label_rules = {
    custom_widget = {
      code_position        = "prefix"
      label_groups         = [["namespace"], ["application", "attributes"]]
      component_delimiter  = "-"
      group_delimiter      = "/"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      required_prefix      = ""
      required_suffix      = ""
      min_length           = 1
      max_length           = 64
      validation_regex     = "^[A-Za-z][A-Za-z0-9/-]{0,63}$"
      forbidden_regexes    = []
      hash_policy          = "never"
      hash_length          = 8
    }
  }
}

module "child" {
  source = "../v1-module"

  context = module.parent.context
}

module "baseline" {
  source = "../v1-module"

  namespace   = "Eg"
  application = "Orders.API"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["API_Gateway"]
}

output "parent_context" {
  value = module.parent.normalized_context
}

output "child_context" {
  value = module.child.normalized_context
}

output "baseline_context" {
  value = module.baseline.normalized_context
}

output "parent_id" {
  value = module.parent.id
}

output "child_id" {
  value = module.child.id
}

output "child_id_resource" {
  value = module.child.id_resource
}

output "baseline_id_resource" {
  value = module.baseline.id_resource
}
