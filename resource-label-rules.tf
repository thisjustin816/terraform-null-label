locals {
  default_resource_label_rules = merge(local.default_azure_resource_label_rules, local.default_aws_resource_label_rules)

  lower_alnum_rule = {
    delimiter           = ""
    regex_replace_chars = "/[^a-z0-9]/"
    label_value_case    = "lower"
    trim_chars          = ""
  }

  lower_alnum_hyphen_rule = {
    delimiter            = "-"
    regex_replace_chars  = "/[^a-z0-9-]/"
    label_value_case     = "lower"
    trim_chars           = "-"
    collapse_regex       = "/-{2,}/"
    collapse_replacement = "-"
  }

  alnum_hyphen_rule = {
    delimiter            = "-"
    regex_replace_chars  = "/[^A-Za-z0-9-]/"
    trim_chars           = "-"
    collapse_regex       = "/-{2,}/"
    collapse_replacement = "-"
  }

  alnum_hyphen_underscore_rule = {
    delimiter           = "-"
    regex_replace_chars = "/[^A-Za-z0-9_-]/"
    trim_chars          = "-"
  }

  azure_global_lower_alnum_rule = merge(local.lower_alnum_rule, {
    globally_unique = true
  })

  azure_global_lower_alnum_hyphen_rule = merge(local.lower_alnum_hyphen_rule, {
    globally_unique = true
  })

  azure_global_alnum_hyphen_rule = merge(local.alnum_hyphen_rule, {
    globally_unique = true
  })

  default_azure_resource_label_rules = {
    ai_search                  = merge(local.alnum_hyphen_rule, { id_length_limit = 60 })
    analysis_services_server   = merge(local.azure_global_lower_alnum_rule, { id_length_limit = 63 })
    api_management             = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 50 })
    api_management_service     = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 50 })
    app_configuration          = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 50 })
    app_service_environment    = merge(local.alnum_hyphen_rule, { id_length_limit = 36 })
    app_service_plan           = merge(local.alnum_hyphen_rule, { id_length_limit = 40 })
    automation_account         = merge(local.alnum_hyphen_rule, { id_length_limit = 50 })
    azure_managed_redis        = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 63 })
    batch_account              = merge(local.lower_alnum_rule, { id_length_limit = 24 })
    communication_services     = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 63 })
    container_app              = merge(local.lower_alnum_hyphen_rule, { id_length_limit = 32 })
    container_group            = merge(local.lower_alnum_hyphen_rule, { id_length_limit = 63 })
    container_instance         = merge(local.lower_alnum_hyphen_rule, { id_length_limit = 63 })
    container_registry         = merge(local.azure_global_lower_alnum_rule, { id_length_limit = 50 })
    cosmosdb_account           = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 44 })
    cosmosdb_cassandra_account = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 44 })
    cosmosdb_gremlin_account   = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 44 })
    cosmosdb_mongodb_account   = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 44 })
    cosmosdb_nosql_account     = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 44 })
    cosmosdb_table_account     = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 44 })
    data_factory               = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 63 })
    eventhub_namespace         = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 50 })
    function_app               = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 60 })
    key_vault                  = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 24 })
    key_vault_managed_hsm      = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 24 })
    kusto_cluster              = merge(local.azure_global_lower_alnum_rule, { id_length_limit = 22 })
    log_analytics_workspace    = merge(local.alnum_hyphen_rule, { id_length_limit = 63 })
    managed_grafana            = merge(local.alnum_hyphen_rule, { id_length_limit = 23 })
    managed_identity           = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 128 })
    mysql_server               = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 63 })
    postgres_server            = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 63 })
    redis_cache                = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 63 })
    servicebus_namespace       = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 50 })
    signalr_service            = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 63 })
    sql_managed_instance       = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 63 })
    sql_server                 = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 63 })
    static_site                = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 40 })
    storage_account            = merge(local.azure_global_lower_alnum_rule, { id_length_limit = 24 })
    storage_account_vm         = merge(local.azure_global_lower_alnum_rule, { id_length_limit = 24 })
    synapse_workspace          = merge(local.azure_global_lower_alnum_hyphen_rule, { id_length_limit = 50 })
    traffic_manager_profile    = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 63 })
    user_assigned_identity     = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 128 })
    virtual_machine            = merge(local.lower_alnum_hyphen_rule, { id_length_limit = 64 })
    virtual_machine_scale_set  = merge(local.lower_alnum_hyphen_rule, { id_length_limit = 64 })
    web_app                    = merge(local.azure_global_alnum_hyphen_rule, { id_length_limit = 60 })
  }

  default_aws_resource_label_rules = {
    aws_cloudwatch_log_group = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 512, regex_replace_chars = "/[^A-Za-z0-9_\\.\\/#-]/" })
    aws_db_instance          = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 63 })
    aws_db_parameter_group   = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 255 })
    aws_db_subnet_group      = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 255 })
    aws_dynamodb_table       = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 255, regex_replace_chars = "/[^A-Za-z0-9_.-]/" })
    aws_ecr_repository       = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 256, regex_replace_chars = "/[^a-z0-9._\\/-]/" })
    aws_elb                  = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 32 })
    aws_iam_instance_profile = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 128, regex_replace_chars = "/[^A-Za-z0-9+=,.@_-]/" })
    aws_iam_policy           = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 128, regex_replace_chars = "/[^A-Za-z0-9+=,.@_-]/" })
    aws_iam_role             = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 64, regex_replace_chars = "/[^A-Za-z0-9+=,.@_-]/" })
    aws_iam_user             = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 64, regex_replace_chars = "/[^A-Za-z0-9+=,.@_-]/" })
    aws_lambda_function      = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 64 })
    aws_lb                   = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 32 })
    aws_lb_target_group      = merge(local.lower_alnum_hyphen_rule, { id_length_limit = 32 })
    aws_rds_cluster          = merge(local.lower_alnum_hyphen_rule, { code_position = "prefix", id_length_limit = 52 })
    aws_rds_cluster_parameter_group = merge(local.lower_alnum_hyphen_rule, {
      code_position   = "prefix"
      id_length_limit = 255
    })
    aws_s3_bucket = merge(local.lower_alnum_hyphen_rule, {
      code_position   = "prefix"
      globally_unique = true
      id_length_limit = 63
    })
    aws_sns_topic      = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 256 })
    aws_sns_fifo_topic = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 256, regex_replace_chars = "/[^A-Za-z0-9_.-]/", required_suffix = ".fifo" })
    aws_sqs_queue      = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 80 })
    aws_sqs_fifo_queue = merge(local.alnum_hyphen_underscore_rule, { id_length_limit = 80, regex_replace_chars = "/[^A-Za-z0-9_.-]/", required_suffix = ".fifo" })
  }
}
