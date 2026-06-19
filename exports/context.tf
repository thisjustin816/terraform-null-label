#
# ONLY EDIT THIS FILE IN github.com/thisjustin816/terraform-null-label
# All other instances of this file should be a copy of that one
#
# Copy this file into your Terraform module to get this fork's standard
# label, tag, and resource-naming inputs, suitable for composing names and
# passing context to other modules built on this fork.
#
# Modules should access the whole context as `module.this.context`
# (a base64-encoded string) and pass it on with `context = module.this.context`.
# Access individual final values as `module.this.<var>`, for example
# `module.this.id` or `module.this.id_resource["aws_s3_bucket"]`.
#
# For example, when using defaults, `module.this.context` decodes to the
# default context and `module.this.delimiter` will be `-` (hyphen).
#

module "this" {
  # This fork is not published to the Terraform Registry. Pin to a release tag
  # for stable consumers instead of `main`, for example ?ref=v1.0.0
  source = "git::https://github.com/thisjustin816/terraform-null-label.git?ref=main"

  enabled              = var.enabled
  namespace            = var.namespace
  application          = var.application
  region               = var.region
  environment          = var.environment
  delimiter            = var.delimiter
  attributes           = var.attributes
  tags                 = var.tags
  additional_tag_map   = var.additional_tag_map
  label_order          = var.label_order
  regex_replace_chars  = var.regex_replace_chars
  id_length_limit      = var.id_length_limit
  label_key_case       = var.label_key_case
  label_value_case     = var.label_value_case
  descriptor_formats   = var.descriptor_formats
  labels_as_tags       = var.labels_as_tags
  resource_codes       = var.resource_codes
  resource_label_rules = var.resource_label_rules
  resource_hash_length = var.resource_hash_length
  resource_hash_values = var.resource_hash_values
  aws_resource_types   = var.aws_resource_types
  region_codes         = var.region_codes
  environment_codes    = var.environment_codes

  context = var.context
}

# Copy contents of this fork's variables.tf here

variable "context" {
  type        = string
  description = "A context to append to. Base64 encoded json is expected."
  default     = "e30=" # base64encode(jsonencode({}))
}

variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources"
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

variable "resource_codes" {
  type        = map(string)
  default     = null
  description = "Resource type code overrides and additions used by `id_resource` outputs."
}

variable "resource_label_rules" {
  type        = any
  default     = null
  description = <<-EOT
    Resource-specific naming rules keyed by resource type. Each rule can override the generated resource code,
    code position (`prefix`, `suffix`, or `none`), delimiter, regular expression for invalid characters, length
    limit, casing, hash length, whether to include region, required suffix, and whether the resource name should
    include the deterministic global uniqueness hash.
    EOT
}

variable "resource_hash_length" {
  type        = number
  default     = null
  description = "Number of characters to use from the deterministic resource hash suffix."

  validation {
    condition     = var.resource_hash_length == null ? true : var.resource_hash_length >= 4 && var.resource_hash_length <= 32
    error_message = "The resource_hash_length must be between 4 and 32 characters when supplied."
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

#### End of copy of this fork's variables.tf
