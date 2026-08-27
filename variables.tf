variable "context" {
  type        = string
  description = "A context to append to. Base64 encoded json is expected."
  default     = "e30=" # base64ecode(jsonencode({}))
}

variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources"
}

variable "resource_codes" {
  type        = map(string)
  default     = null
  description = "Resource type code overrides and additions used by logical resource labels."
}

variable "resource_label_rules" {
  type = map(object({
    code_position        = optional(string)
    label_groups         = optional(list(list(string)))
    component_delimiter  = optional(string)
    group_delimiter      = optional(string)
    regex_replace_chars  = optional(string)
    label_value_case     = optional(string)
    trim_chars           = optional(string)
    collapse_regex       = optional(string)
    collapse_replacement = optional(string)
    required_prefix      = optional(string)
    required_suffix      = optional(string)
    min_length           = optional(number)
    max_length           = optional(number)
    validation_regex     = optional(string)
    forbidden_regexes    = optional(list(string))
    hash_policy          = optional(string)
    hash_length          = optional(number)
  }))
  default     = null
  description = <<-EOT
    Partial physical-name rule overrides keyed by resource type. Null attributes inherit defaults. Empty strings,
    empty lists, and zero are explicit values.
    EOT

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.code_position == null ? true : contains(["prefix", "suffix", "none"], rule.code_position)
    ])
    error_message = "Invalid code_position for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.code_position == null ? false : !contains(["prefix", "suffix", "none"], rule.code_position)
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], rule.label_value_case)
    ])
    error_message = "Invalid label_value_case for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.label_value_case == null ? false : !contains(["lower", "title", "upper", "none"], rule.label_value_case)
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.hash_policy == null ? true : contains(["never", "when_needed", "always"], rule.hash_policy)
    ])
    error_message = "Invalid hash_policy for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.hash_policy == null ? false : !contains(["never", "when_needed", "always"], rule.hash_policy)
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules : rule.label_groups == null ? true : alltrue([
        for group in rule.label_groups : length(setsubtract(
          toset(group),
          toset([
            "namespace",
            "application",
            "region",
            "region_code",
            "environment",
            "environment_code",
            "attributes",
          ])
        )) == 0
      ])
    ])
    error_message = "Unsupported label_groups elements for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.label_groups == null ? false : !alltrue([
        for group in rule.label_groups : length(setsubtract(
          toset(group),
          toset([
            "namespace",
            "application",
            "region",
            "region_code",
            "environment",
            "environment_code",
            "attributes",
          ])
        )) == 0
      ])
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.regex_replace_chars == null || rule.regex_replace_chars == "" ? true : (
        can(regex("^/.*/$", rule.regex_replace_chars)) &&
        can(replace("probe", rule.regex_replace_chars, ""))
      )
    ])
    error_message = "Invalid regex_replace_chars for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.regex_replace_chars == null || rule.regex_replace_chars == "" ? false : !(
        can(regex("^/.*/$", rule.regex_replace_chars)) &&
        can(replace("probe", rule.regex_replace_chars, ""))
      )
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.collapse_regex == null || rule.collapse_regex == "" ? true : (
        can(regex("^/.*/$", rule.collapse_regex)) &&
        can(replace("probe", rule.collapse_regex, ""))
      )
    ])
    error_message = "Invalid collapse_regex for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.collapse_regex == null || rule.collapse_regex == "" ? false : !(
        can(regex("^/.*/$", rule.collapse_regex)) &&
        can(replace("probe", rule.collapse_regex, ""))
      )
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.validation_regex == null ? true : (
        can(regex("^\\^.*\\$$", rule.validation_regex)) &&
        can(regexall(rule.validation_regex, ""))
      )
    ])
    error_message = "Invalid validation_regex for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.validation_regex == null ? false : !(
        can(regex("^\\^.*\\$$", rule.validation_regex)) &&
        can(regexall(rule.validation_regex, ""))
      )
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules : rule.forbidden_regexes == null ? true : alltrue([
        for pattern in rule.forbidden_regexes : can(regexall(pattern, ""))
      ])
    ])
    error_message = "Invalid forbidden_regexes for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.forbidden_regexes == null ? false : !alltrue([
        for pattern in rule.forbidden_regexes : can(regexall(pattern, ""))
      ])
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.min_length == null ? true : rule.min_length >= 0 && floor(rule.min_length) == rule.min_length
    ])
    error_message = "Invalid min_length for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.min_length == null ? false : rule.min_length < 0 || floor(rule.min_length) != rule.min_length
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.max_length == null ? true : rule.max_length >= 1 && floor(rule.max_length) == rule.max_length
    ])
    error_message = "Invalid max_length for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.max_length == null ? false : rule.max_length < 1 || floor(rule.max_length) != rule.max_length
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.hash_length == null ? true : rule.hash_length >= 4 && rule.hash_length <= 32 && floor(rule.hash_length) == rule.hash_length
    ])
    error_message = "Invalid hash_length for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.hash_length == null ? false : rule.hash_length < 4 || rule.hash_length > 32 || floor(rule.hash_length) != rule.hash_length
    ]))}."
  }

  validation {
    condition = var.resource_label_rules == null ? true : alltrue([
      for _, rule in var.resource_label_rules :
      rule.min_length == null || rule.max_length == null ? true : rule.min_length <= rule.max_length
    ])
    error_message = "min_length exceeds max_length for resource_label_rules keys: ${join(", ", sort([
      for key, rule in coalesce(var.resource_label_rules, {}) : key
      if rule.min_length == null || rule.max_length == null ? false : rule.min_length > rule.max_length
    ]))}."
  }
}

variable "required_resource_names" {
  type        = set(string)
  default     = []
  description = "Resource-name keys that must produce valid normal and hashed physical names."
}

variable "resource_hash_length" {
  type        = number
  default     = null
  description = "Number of characters to use from the deterministic resource hash suffix."

  validation {
    condition = var.resource_hash_length == null ? true : (
      var.resource_hash_length >= 4 &&
      var.resource_hash_length <= 32 &&
      floor(var.resource_hash_length) == var.resource_hash_length
    )
    error_message = "The resource_hash_length must be a whole number between 4 and 32 characters when supplied."
  }
}

variable "resource_hash_values" {
  type        = list(string)
  default     = null
  description = "Additional stable values included in the deterministic resource hash seed."
}

variable "aws_resource_types" {
  type        = set(string)
  default     = null
  description = <<-EOT
    Additional AWS Terraform resource type names to include in resource-code outputs.
    Values can include or omit the aws_ prefix, for example aws_s3_bucket or s3_bucket.
    EOT

  validation {
    condition = var.aws_resource_types == null ? true : !contains([
      for resource_type in var.aws_resource_types : can(regex("^(aws_)?[a-z0-9_]+$", resource_type))
    ], false)
    error_message = "Each aws_resource_types value must be a Terraform-style AWS resource type such as aws_s3_bucket or s3_bucket."
  }
}

variable "region_codes" {
  type        = map(string)
  default     = null
  description = "Region-to-code map used by the `region_code` label element."
}

variable "environment_codes" {
  type        = map(string)
  default     = null
  description = "Environment-to-code map used by the `environment_code` label element."
}

variable "namespace" {
  type        = string
  default     = null
  description = "ID element. Usually an abbreviation of your namespace name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
}

variable "application" {
  type        = string
  default     = null
  description = <<-EOT
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
    The `application` value is included in `id` and, when `application` is one of
    `labels_as_tags`, is also set as the `Application` tag. The full `id` string is
    additionally exposed as the `Id` tag.
    EOT
}

variable "region" {
  type        = string
  default     = null
  description = "ID element. Used for cloud region, e.g. 'eastus', 'us-west-2', or 'northeurope'."
}
variable "environment" {
  type        = string
  default     = null
  description = "ID element. Used for environment, e.g. 'prod', 'staging', 'dev', or 'test'."
}

variable "delimiter" {
  type        = string
  default     = null
  description = <<-EOT
    Delimiter to be used between ID elements.
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.
  EOT
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = <<-EOT
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,
    in the order they appear in the list. New attributes are appended to the
    end of the list. The elements of the list are joined by the `delimiter`
    and treated as a single ID element.
    EOT
}

variable "labels_as_tags" {
  type        = set(string)
  default     = ["default"]
  description = <<-EOT
    Set of labels (ID elements) to include as tags in the `tags` output.
    Default is to include all labels.
    Tags with empty values will not be included in the `tags` output.
    Set to `[]` to suppress all generated tags.
    **Notes:**
      The `application` tag, if included, is the `application` value; the full `id`
      string is exposed separately as the `Id` tag.
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be
      changed in later chained modules. Attempts to change it will be silently ignored.
    EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
}

variable "additional_tag_map" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.
    This is for some rare cases where resources want additional configuration of tags
    and therefore take a list of maps with tag key, value, and additional configuration.
    EOT
}

variable "label_order" {
  type        = list(string)
  default     = null
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "application", "region_code", "environment_code", "attributes"].
    Supported label elements are `namespace`, `application`, `region`, `region_code`,
    `environment`, `environment_code`, and `attributes`.
    EOT

  validation {
    condition = var.label_order == null ? true : (
      length(var.label_order) == length(distinct(var.label_order)) &&
      length(setsubtract(
        toset(var.label_order),
        toset([
          "namespace",
          "application",
          "region",
          "region_code",
          "environment",
          "environment_code",
          "attributes",
        ])
      )) == 0
    )
    error_message = "The label_order may contain only supported labels, without duplicates: namespace, application, region, region_code, environment, environment_code, and attributes."
  }
}

variable "regex_replace_chars" {
  type        = string
  default     = null
  description = <<-EOT
    Terraform regular expression (regex) string.
    Characters matching the regex will be removed from the ID elements.
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
  EOT
}

variable "id_length_limit" {
  type        = number
  default     = null
  description = <<-EOT
    Limit `id` to this many characters (minimum 6).
    Set to `0` for unlimited length.
    Set to `null` for keep the existing setting, which defaults to `0`.
    Does not affect `id_full`.
  EOT
  validation {
    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}

variable "label_key_case" {
  type        = string
  default     = null
  description = <<-EOT
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
    Does not affect keys of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper`.
    Default value: `title`.
  EOT

  validation {
    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  type        = string
  default     = null
  description = <<-EOT
    Controls the letter case of ID elements (labels) as included in `id`,
    set as tag values, and output by this module individually.
    Does not affect values of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.
    Default value: `lower`.
  EOT

  validation {
    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "descriptor_formats" {
  type        = any
  default     = {}
  description = <<-EOT
    Describe additional descriptors to be output in the `descriptors` output map.
    Map of maps. Keys are names of descriptors. Values are maps of the form
    `{
       format = string
       labels = list(string)
    }`
    (Type is `any` so the map values can later be enhanced to provide additional options.)
    `format` is a Terraform format string to be passed to the `format()` function.
    `labels` is a list of labels, in order, to pass to `format()` function.
    Label values will be normalized before being passed to `format()` so they will be
    identical to how they appear in `id`.
    Default is `{}` (`descriptors` output will be empty).
    EOT
}
