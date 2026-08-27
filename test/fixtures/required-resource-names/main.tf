variable "required_resource_names" {
  type = set(string)
  default = [
    "aws_ecr_repository",
    "azure_storage_account",
    "custom_path",
  ]
}

module "label" {
  source = "../../.."

  namespace               = "Platform"
  application             = "Orders"
  region                  = ""
  environment             = ""
  attributes              = ["API", "###"]
  resource_hash_values    = ["account-123"]
  required_resource_names = var.required_resource_names

  resource_codes = {
    custom_invalid = ""
  }

  resource_label_rules = {
    custom_path = {
      code_position        = "none"
      label_groups         = [["namespace"], ["application", "attributes"]]
      component_delimiter  = "-"
      group_delimiter      = "/"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-+/"
      collapse_replacement = "-"
      required_prefix      = ""
      required_suffix      = ""
      min_length           = 1
      max_length           = 128
      validation_regex     = "^[a-z0-9]([a-z0-9/-]*[a-z0-9])?$"
      forbidden_regexes    = ["//"]
      hash_policy          = "never"
    }
    custom_invalid = {
      code_position        = "none"
      label_groups         = [["namespace", "application", "attributes"]]
      component_delimiter  = "-"
      group_delimiter      = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-+/"
      collapse_replacement = "-"
      required_prefix      = ""
      required_suffix      = ""
      min_length           = 1
      max_length           = 128
      validation_regex     = "^z+$"
      forbidden_regexes    = []
      hash_policy          = "never"
    }
  }
}

output "resource_name" {
  value = module.label.resource_name
}

output "resource_name_hashed" {
  value = module.label.resource_name_hashed
}
