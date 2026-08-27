module "label" {
  source = "../../.."

  namespace            = "Platform"
  application          = "Orders"
  region               = ""
  environment          = ""
  attributes           = ["API", "###"]
  resource_hash_values = ["account-123"]

  required_resource_names = [
    "aws_ecr_repository",
    "azure_storage_account",
    "custom_path",
  ]

  resource_codes = {
    aws_lambda_function = "fn"
    custom_compact      = "S!V@C"
    custom_path         = ""
    custom_tag_only     = "tag"
  }

  resource_label_rules = {
    azure_key_vault = {
      hash_policy = "never"
    }
    azure_storage_account = {
      hash_policy = "never"
    }
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
    custom_compact = {
      code_position        = "prefix"
      label_groups         = [["namespace", "application", "attributes"]]
      component_delimiter  = ""
      group_delimiter      = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      required_prefix      = ""
      required_suffix      = ""
      min_length           = 1
      max_length           = 63
      validation_regex     = "^[a-z][a-z0-9]*$"
      forbidden_regexes    = []
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

module "legacy" {
  source = "../v1-module"

  namespace            = "Platform"
  application          = "Orders"
  region               = ""
  environment          = ""
  attributes           = ["API", "###"]
  resource_hash_values = ["account-123"]
}

output "contract" {
  value = {
    base_id = module.label.id
    hash    = module.label.resource_hash
    physical_name_key_sets_equal = (
      sort(keys(module.label.resource_name)) ==
      sort(keys(module.label.resource_name_hashed))
    )
    codes = {
      for key in [
        "aws_ecr_repository",
        "aws_elasticache_replication_group",
        "aws_lambda_function",
        "azure_postgresql_flexible_server",
        "azure_storage_account",
        "custom_compact",
        "custom_path",
        "custom_tag_only",
      ] : key => module.label.resource_codes[key]
    }
    logical = {
      for key in [
        "aws_ecr_repository",
        "aws_lambda_function",
        "azure_storage_account",
        "custom_path",
        "custom_tag_only",
      ] : key => module.label.id_with_resource_code[key]
    }
    normal = {
      for key in [
        "aws_ecr_repository",
        "aws_elasticache_replication_group",
        "aws_kms_alias",
        "aws_lambda_function",
        "aws_s3_bucket",
        "aws_sqs_fifo_queue",
        "azure_ai_search",
        "azure_analysis_services_server",
        "azure_app_service_plan",
        "azure_gallery",
        "azure_key_vault",
        "azure_postgresql_flexible_server",
        "azure_storage_account",
        "custom_compact",
        "custom_path",
      ] : key => module.label.resource_name[key]
    }
    hashed = {
      for key in [
        "aws_ecr_repository",
        "aws_elasticache_replication_group",
        "aws_kms_alias",
        "aws_lambda_function",
        "aws_s3_bucket",
        "aws_sqs_fifo_queue",
        "azure_ai_search",
        "azure_analysis_services_server",
        "azure_app_service_plan",
        "azure_gallery",
        "azure_key_vault",
        "azure_postgresql_flexible_server",
        "azure_storage_account",
        "custom_compact",
        "custom_path",
      ] : key => module.label.resource_name_hashed[key]
    }
    errors = module.label.resource_name_errors
    rules = {
      for key in [
        "aws_lambda_function",
        "custom_compact",
        "custom_path",
        ] : key => {
        code          = module.label.resource_label_rules[key].code
        code_position = module.label.resource_label_rules[key].code_position
        hash_policy   = module.label.resource_label_rules[key].hash_policy
      }
    }
    absent_from_physical_names = {
      for key in [
        "aws_api_gateway_domain_name",
        "aws_vpc",
        "azure_blueprint_definition",
        "azure_enclave",
        "azure_managed_redis",
        "azure_private_dns_zone",
        "custom_invalid",
        "custom_tag_only",
        ] : key => (
        !contains(keys(module.label.resource_name), key) &&
        !contains(keys(module.label.resource_name_hashed), key)
      )
    }
    aliases = {
      key_vault       = module.label.id_for_keyvault
      storage_account = module.label.id_for_storage_account
    }
    legacy = {
      base_id = module.legacy.id
      hash    = module.legacy.resource_hash
      aliases = {
        key_vault       = module.legacy.id_for_keyvault
        storage_account = module.legacy.id_for_storage_account
      }
    }
  }
}
