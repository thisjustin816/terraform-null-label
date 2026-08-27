locals {
  aws_resource_rule_base = {
    code_position        = "suffix"
    label_groups         = [["namespace", "application", "environment_code", "attributes"]]
    component_delimiter  = "-"
    group_delimiter      = "-"
    regex_replace_chars  = "/[^A-Za-z0-9-]/"
    label_value_case     = "none"
    trim_chars           = "-"
    collapse_regex       = "/-{2,}/"
    collapse_replacement = "-"
    required_prefix      = ""
    required_suffix      = ""
    min_length           = 1
    max_length           = null
    validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
    forbidden_regexes    = []
    hash_policy          = "when_needed"
    hash_length          = null
  }

  aws_resource_rule_h = local.aws_resource_rule_base

  aws_resource_rule_hu = merge(local.aws_resource_rule_base, {
    regex_replace_chars = "/[^A-Za-z0-9_-]/"
    validation_regex    = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])$"
  })

  aws_resource_rule_hufirst = merge(local.aws_resource_rule_hu, {
    validation_regex = "^([A-Za-z][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z])$"
  })

  aws_resource_rule_dhu = merge(local.aws_resource_rule_base, {
    regex_replace_chars = "/[^A-Za-z0-9._-]/"
    trim_chars          = ".-"
    validation_regex    = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
  })

  aws_resource_rule_lh = merge(local.aws_resource_rule_base, {
    regex_replace_chars = "/[^a-z0-9-]/"
    label_value_case    = "lower"
    validation_regex    = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
  })

  aws_resource_rule_llh = merge(local.aws_resource_rule_lh, {
    validation_regex  = "^([a-z][a-z0-9-]*[a-z0-9]|[a-z])$"
    forbidden_regexes = ["--"]
  })

  aws_resource_rule_iam = merge(local.aws_resource_rule_base, {
    regex_replace_chars  = "/[^A-Za-z0-9+=,.@_-]/"
    trim_chars           = ""
    collapse_regex       = ""
    collapse_replacement = ""
    validation_regex     = "^[A-Za-z0-9+=,.@_-]+$"
  })

  aws_resource_rule_log = merge(local.aws_resource_rule_base, {
    regex_replace_chars  = "/[^A-Za-z0-9_./#-]/"
    trim_chars           = ""
    collapse_regex       = ""
    collapse_replacement = ""
    validation_regex     = "^[A-Za-z0-9_./#-]+$"
    forbidden_regexes    = ["^aws/"]
  })

  aws_resource_rule_secret = merge(local.aws_resource_rule_base, {
    regex_replace_chars  = "/[^A-Za-z0-9_+=.@-]/"
    trim_chars           = ""
    collapse_regex       = ""
    collapse_replacement = ""
    validation_regex     = "^[A-Za-z0-9_+=.@-]+$"
  })

  aws_resource_rule_ecr = merge(local.aws_resource_rule_base, {
    code_position        = "none"
    label_groups         = [["namespace"], ["application", "attributes"]]
    group_delimiter      = "/"
    regex_replace_chars  = "/[^a-z0-9._-]/"
    label_value_case     = "lower"
    trim_chars           = ".-_/"
    collapse_regex       = ""
    collapse_replacement = ""
    min_length           = 2
    max_length           = 256
    validation_regex     = "^[a-z0-9]+((\\.|_|__|-+)[a-z0-9]+)*(\\/[a-z0-9]+((\\.|_|__|-+)[a-z0-9]+)*)*$"
  })

  aws_resource_rule_kms_alias = merge(local.aws_resource_rule_hu, {
    regex_replace_chars = "/[^A-Za-z0-9/_-]/"
    required_prefix     = "alias/"
    min_length          = 7
    max_length          = 256
    validation_regex    = "^alias/[a-zA-Z0-9/_-]+$"
    forbidden_regexes   = ["^alias/aws/"]
  })

  aws_resource_rule_s3 = merge(local.aws_resource_rule_llh, {
    hash_policy      = "always"
    min_length       = 3
    max_length       = 63
    validation_regex = "^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$"
    forbidden_regexes = [
      "^xn--",
      "^sthree-",
      "^amzn-s3-demo-",
      "-s3alias$",
      "--ol-s3$",
      "\\.mrap$",
      "--x-s3$",
      "--table-s3$",
      "-an$",
      "\\.\\.",
      "^[0-9]{1,3}(\\.[0-9]{1,3}){3}$",
    ]
  })

  aws_resource_rule_hu_fifo = merge(local.aws_resource_rule_hu, {
    required_suffix  = ".fifo"
    validation_regex = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])\\.fifo$"
  })

  aws_resource_label_rules = {
    aws_api_gateway_stage = merge(local.aws_resource_rule_hu, {
      max_length = 128
    })
    aws_apigatewayv2_api = merge(local.aws_resource_rule_h, {
      max_length = 128
    })
    aws_apigatewayv2_stage = merge(local.aws_resource_rule_hu, {
      max_length = 128
    })
    aws_appautoscaling_policy = merge(local.aws_resource_rule_h, {
      max_length = 256
    })
    aws_autoscaling_group = merge(local.aws_resource_rule_h, {
      max_length = 255
    })
    aws_cloudwatch_dashboard = merge(local.aws_resource_rule_hu, {
      max_length = 255
    })
    aws_cloudwatch_event_bus = merge(local.aws_resource_rule_dhu, {
      max_length = 256
    })
    aws_cloudwatch_event_rule = merge(local.aws_resource_rule_dhu, {
      max_length = 64
    })
    aws_cloudwatch_log_group = merge(local.aws_resource_rule_log, {
      max_length = 512
    })
    aws_cloudwatch_metric_alarm = merge(local.aws_resource_rule_h, {
      max_length = 255
    })
    aws_cognito_user_pool = merge(local.aws_resource_rule_h, {
      max_length = 128
    })
    aws_db_instance = merge(local.aws_resource_rule_llh, {
      code_position = "prefix"
      max_length    = 63
    })
    aws_db_parameter_group = merge(local.aws_resource_rule_llh, {
      code_position = "prefix"
      max_length    = 255
    })
    aws_db_subnet_group = merge(local.aws_resource_rule_llh, {
      code_position     = "prefix"
      max_length        = 255
      forbidden_regexes = concat(local.aws_resource_rule_llh.forbidden_regexes, ["^default$"])
    })
    aws_dynamodb_table = merge(local.aws_resource_rule_dhu, {
      min_length = 3
      max_length = 255
    })
    aws_ecr_repository = local.aws_resource_rule_ecr
    aws_ecs_cluster = merge(local.aws_resource_rule_hu, {
      max_length = 255
    })
    aws_ecs_service = merge(local.aws_resource_rule_hu, {
      max_length = 255
    })
    aws_ecs_task_definition = merge(local.aws_resource_rule_hu, {
      max_length = 255
    })
    aws_eks_cluster = merge(local.aws_resource_rule_hufirst, {
      code_position = "prefix"
      max_length    = 100
    })
    aws_eks_node_group = merge(local.aws_resource_rule_hufirst, {
      code_position = "prefix"
      max_length    = 63
    })
    aws_elb = merge(local.aws_resource_rule_lh, {
      code_position = "prefix"
      max_length    = 32
    })
    aws_elasticache_cluster = merge(local.aws_resource_rule_llh, {
      code_position = "prefix"
      max_length    = 50
    })
    aws_elasticache_replication_group = merge(local.aws_resource_rule_llh, {
      code_position = "prefix"
      max_length    = 40
    })
    aws_elasticache_subnet_group = merge(local.aws_resource_rule_lh, {
      max_length = 255
    })
    aws_elastic_beanstalk_application = merge(local.aws_resource_rule_h, {
      max_length = 100
    })
    aws_elastic_beanstalk_environment = merge(local.aws_resource_rule_h, {
      min_length = 4
      max_length = 40
    })
    aws_glue_catalog_database = merge(local.aws_resource_rule_lh, {
      max_length = 255
    })
    aws_glue_crawler = merge(local.aws_resource_rule_h, {
      max_length = 255
    })
    aws_glue_job = merge(local.aws_resource_rule_h, {
      max_length = 255
    })
    aws_iam_group = merge(local.aws_resource_rule_iam, {
      max_length = 128
    })
    aws_iam_instance_profile = merge(local.aws_resource_rule_iam, {
      max_length = 128
    })
    aws_iam_policy = merge(local.aws_resource_rule_iam, {
      max_length = 128
    })
    aws_iam_role = merge(local.aws_resource_rule_iam, {
      max_length = 64
    })
    aws_iam_user = merge(local.aws_resource_rule_iam, {
      max_length = 64
    })
    aws_kinesis_firehose_delivery_stream = merge(local.aws_resource_rule_dhu, {
      max_length = 64
    })
    aws_kinesis_stream = merge(local.aws_resource_rule_dhu, {
      max_length = 128
    })
    aws_kms_alias = local.aws_resource_rule_kms_alias
    aws_lambda_function = merge(local.aws_resource_rule_hu, {
      max_length = 64
    })
    aws_lambda_layer_version = merge(local.aws_resource_rule_hu, {
      max_length = 140
    })
    aws_launch_template = merge(local.aws_resource_rule_h, {
      min_length = 3
      max_length = 125
    })
    aws_lb = merge(local.aws_resource_rule_lh, {
      code_position     = "prefix"
      max_length        = 32
      forbidden_regexes = ["^internal-"]
    })
    aws_lb_target_group = merge(local.aws_resource_rule_lh, {
      max_length = 32
    })
    aws_rds_cluster = merge(local.aws_resource_rule_llh, {
      code_position = "prefix"
      max_length    = 52
    })
    aws_rds_cluster_parameter_group = merge(local.aws_resource_rule_llh, {
      code_position = "prefix"
      max_length    = 255
    })
    aws_s3_bucket = merge(local.aws_resource_rule_s3, {
      code_position = "prefix"
    })
    aws_secretsmanager_secret = merge(local.aws_resource_rule_secret, {
      max_length = 512
    })
    aws_security_group = merge(local.aws_resource_rule_h, {
      max_length        = 255
      forbidden_regexes = ["(?i)^sg-"]
    })
    aws_sfn_state_machine = merge(local.aws_resource_rule_hu, {
      max_length = 80
    })
    aws_sns_fifo_topic = merge(local.aws_resource_rule_hu_fifo, {
      max_length = 256
    })
    aws_sns_topic = merge(local.aws_resource_rule_hu, {
      max_length = 256
    })
    aws_sqs_fifo_queue = merge(local.aws_resource_rule_hu_fifo, {
      max_length = 80
    })
    aws_sqs_queue = merge(local.aws_resource_rule_hu, {
      max_length = 80
    })
  }
}
