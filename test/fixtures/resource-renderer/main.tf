variable "enabled" {
  type    = bool
  default = true
}

variable "namespace" {
  type    = string
  default = "Platform"
}

variable "application" {
  type    = string
  default = "Orders"
}

variable "attributes" {
  type    = list(string)
  default = ["API", "###"]
}

variable "required_resource_names" {
  type    = set(string)
  default = []
}

variable "resource_hash_length" {
  type    = number
  default = 8
}

variable "resource_hash_values" {
  type    = list(string)
  default = ["account-123"]
}

variable "region" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "region_codes" {
  type    = map(string)
  default = null
}

variable "environment_codes" {
  type    = map(string)
  default = null
}

variable "extra_resource_label_rules" {
  type    = any
  default = {}
}

locals {
  base_resource_rule = {
    code_position        = "none"
    label_groups         = [["namespace", "application", "attributes"]]
    component_delimiter  = "-"
    group_delimiter      = "-"
    regex_replace_chars  = "/[^a-z0-9-]/"
    label_value_case     = "lower"
    trim_chars           = "-"
    collapse_regex       = "/-{2,}/"
    collapse_replacement = "-"
    required_prefix      = ""
    required_suffix      = ""
    min_length           = 1
    max_length           = 128
    validation_regex     = "^([a-z0-9][a-z0-9/-]*[a-z0-9]|[a-z0-9])$"
    forbidden_regexes    = []
    hash_policy          = "never"
    hash_length          = 8
  }

  renderer_rules = {
    structured = merge(local.base_resource_rule, {
      label_groups      = [["environment"], ["namespace"], ["region"], ["application", "attributes"], ["environment"]]
      group_delimiter   = "/"
      forbidden_regexes = ["//", "^/", "/$"]
    })
    code_prefix = merge(local.base_resource_rule, {
      code_position = "prefix"
    })
    code_suffix = merge(local.base_resource_rule, {
      code_position = "suffix"
    })
    code_none = merge(local.base_resource_rule, {
      code_position = "none"
    })
    empty_delimiters = merge(local.base_resource_rule, {
      code_position        = "prefix"
      component_delimiter  = ""
      group_delimiter      = ""
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      validation_regex     = "^[a-z0-9]+$"
    })
    normalized_codes = merge(local.base_resource_rule, {
      label_groups = [["region_code", "environment_code"]]
    })
    alias_prefix = merge(local.base_resource_rule, {
      required_prefix  = "alias/"
      validation_regex = "^alias/[a-z0-9-]+$"
    })
    fifo_suffix = merge(local.base_resource_rule, {
      required_suffix  = ".fifo"
      validation_regex = "^[a-z0-9-]+\\.fifo$"
    })
    policy_never = local.base_resource_rule
    policy_when_needed = merge(local.base_resource_rule, {
      hash_policy = "when_needed"
    })
    policy_always = merge(local.base_resource_rule, {
      hash_policy = "always"
    })
    minimum_recovery = merge(local.base_resource_rule, {
      label_groups     = [["environment"]]
      hash_policy      = "when_needed"
      min_length       = 4
      max_length       = 20
      validation_regex = "^[a-f0-9]{4,20}$"
    })
    truncation_retrim = merge(local.base_resource_rule, {
      hash_policy = "when_needed"
      hash_length = 4
      max_length  = 14
    })
    hash_upper_filtered = merge(local.base_resource_rule, {
      label_groups        = [["environment"]]
      component_delimiter = ""
      regex_replace_chars = "/[^A-F]/"
      label_value_case    = "upper"
      trim_chars          = ""
      collapse_regex      = ""
      hash_policy         = "always"
      hash_length         = 32
      max_length          = 32
      validation_regex    = "^[A-F]+$"
    })
    hash_transformed_empty = merge(local.base_resource_rule, {
      label_groups        = [["environment"]]
      component_delimiter = ""
      regex_replace_chars = "/[^X]/"
      label_value_case    = "upper"
      trim_chars          = ""
      collapse_regex      = ""
      hash_policy         = "always"
      validation_regex    = "^X+$"
    })
    forbidden_fail = merge(local.base_resource_rule, {
      forbidden_regexes = ["^platform"]
    })
    final_regex_fail = merge(local.base_resource_rule, {
      validation_regex = "^z+$"
    })
    joint_omission = merge(local.base_resource_rule, {
      label_groups     = [["namespace"]]
      validation_regex = "^[a-z]+$"
    })
    hash_affix_conflict = merge(local.base_resource_rule, {
      label_groups     = [["environment"]]
      required_prefix  = "alias/"
      required_suffix  = ".fifo"
      hash_policy      = "always"
      max_length       = 16
      validation_regex = "^alias/[a-f0-9-]+\\.fifo$"
    })
    never_overflow = merge(local.base_resource_rule, {
      hash_policy = "never"
      hash_length = 4
      max_length  = 10
    })
    global_hash_fit = merge(local.base_resource_rule, {
      label_groups     = [["environment"]]
      hash_policy      = "always"
      hash_length      = null
      min_length       = 4
      max_length       = 12
      validation_regex = "^[a-f0-9]+$"
    })
    per_rule_hash_fit = merge(local.base_resource_rule, {
      label_groups     = [["environment"]]
      hash_policy      = "always"
      hash_length      = 4
      min_length       = 4
      max_length       = 12
      validation_regex = "^[a-f0-9]+$"
    })
    hash_seed_peer = merge(local.base_resource_rule, {
      code_position = "prefix"
      hash_policy   = "always"
    })
  }
}

module "label" {
  source = "../../.."

  enabled     = var.enabled
  namespace   = var.namespace
  application = var.application
  region      = var.region
  environment = var.environment
  attributes  = var.attributes

  region_codes      = var.region_codes
  environment_codes = var.environment_codes

  resource_codes = {
    alias_prefix           = ""
    code_none              = "ignored"
    code_prefix            = "S!V@C"
    code_suffix            = "S!V@C"
    custom_tag_only        = "tag"
    empty_delimiters       = "S!V@C"
    fifo_suffix            = ""
    final_regex_fail       = ""
    forbidden_fail         = ""
    global_hash_fit        = ""
    hash_affix_conflict    = ""
    hash_seed_peer         = "Other.Code"
    hash_transformed_empty = ""
    hash_upper_filtered    = ""
    incomplete_service     = "svc"
    joint_omission         = ""
    minimum_recovery       = ""
    never_overflow         = ""
    normalized_codes       = ""
    per_rule_hash_fit      = ""
    policy_always          = ""
    policy_never           = ""
    policy_when_needed     = ""
    structured             = ""
    truncation_retrim      = ""
  }
  resource_label_rules    = merge(local.renderer_rules, var.extra_resource_label_rules)
  required_resource_names = var.required_resource_names
  resource_hash_length    = var.resource_hash_length
  resource_hash_values    = var.resource_hash_values
}

output "base_id" {
  value = module.label.id
}

output "base_region_code" {
  value = module.label.normalized_context.region_code
}

output "base_environment_code" {
  value = module.label.normalized_context.environment_code
}

output "resource_hash" {
  value = module.label.resource_hash
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
