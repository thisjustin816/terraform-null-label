locals {
  azure_v1_to_v2_resource_key_map = {
    ai_search                                 = "azure_ai_search"
    ai_video_indexer                          = "azure_ai_video_indexer"
    aks_cluster                               = "azure_aks_cluster"
    aks_system_node_pool                      = "azure_aks_system_node_pool"
    aks_user_node_pool                        = "azure_aks_user_node_pool"
    analysis_services_server                  = "azure_analysis_services_server"
    api_management                            = "azure_api_management"
    api_management_service                    = "azure_api_management_service"
    app_configuration                         = "azure_app_configuration"
    app_service_environment                   = "azure_app_service_environment"
    app_service_plan                          = "azure_app_service_plan"
    application_gateway                       = "azure_application_gateway"
    application_insights                      = "azure_application_insights"
    application_security_group                = "azure_application_security_group"
    arc_enabled_kubernetes_cluster            = "azure_arc_enabled_kubernetes_cluster"
    arc_enabled_server                        = "azure_arc_enabled_server"
    arc_gateway                               = "azure_arc_gateway"
    arc_private_link_scope                    = "azure_arc_private_link_scope"
    automation_account                        = "azure_automation_account"
    availability_set                          = "azure_availability_set"
    azure_managed_redis                       = "azure_managed_redis"
    azure_openai_service                      = "azure_openai_service"
    backup_resource_guard                     = "azure_backup_resource_guard"
    backup_vault                              = "azure_backup_vault"
    backup_vault_policy                       = "azure_backup_vault_policy"
    bastion_host                              = "azure_bastion_host"
    batch_account                             = "azure_batch_account"
    blueprint_assignment                      = "azure_blueprint_assignment"
    blueprint_definition                      = "azure_blueprint_definition"
    bot_service                               = "azure_bot_service"
    cdn_endpoint                              = "azure_cdn_endpoint"
    cdn_profile                               = "azure_cdn_profile"
    cloud_service                             = "azure_cloud_service"
    communication_services                    = "azure_communication_services"
    computer_vision                           = "azure_computer_vision"
    connection                                = "azure_connection"
    container_app                             = "azure_container_app"
    container_app_environment                 = "azure_container_app_environment"
    container_app_job                         = "azure_container_app_job"
    container_group                           = "azure_container_group"
    container_instance                        = "azure_container_instance"
    container_registry                        = "azure_container_registry"
    content_moderator                         = "azure_content_moderator"
    content_safety                            = "azure_content_safety"
    cosmosdb_account                          = "azure_cosmosdb_account"
    cosmosdb_cassandra_account                = "azure_cosmosdb_cassandra_account"
    cosmosdb_database                         = "azure_cosmosdb_database"
    cosmosdb_gremlin_account                  = "azure_cosmosdb_gremlin_account"
    cosmosdb_mongodb_account                  = "azure_cosmosdb_mongodb_account"
    cosmosdb_nosql_account                    = "azure_cosmosdb_nosql_account"
    cosmosdb_postgresql_cluster               = "azure_cosmosdb_postgresql_cluster"
    cosmosdb_table_account                    = "azure_cosmosdb_table_account"
    custom_vision_prediction                  = "azure_custom_vision_prediction"
    custom_vision_training                    = "azure_custom_vision_training"
    data_collection_endpoint                  = "azure_data_collection_endpoint"
    data_factory                              = "azure_data_factory"
    data_lake_store_account                   = "azure_data_lake_store_account"
    database_migration_project                = "azure_database_migration_project"
    database_migration_service                = "azure_database_migration_service"
    databricks_access_connector               = "azure_databricks_access_connector"
    databricks_workspace                      = "azure_databricks_workspace"
    deployment_script                         = "azure_deployment_script"
    digital_twin_instance                     = "azure_digital_twin_instance"
    disk_encryption_set                       = "azure_disk_encryption_set"
    dns_forwarding_ruleset                    = "azure_dns_forwarding_ruleset"
    dns_private_resolver                      = "azure_dns_private_resolver"
    dns_private_resolver_inbound_endpoint     = "azure_dns_private_resolver_inbound_endpoint"
    dns_private_resolver_outbound_endpoint    = "azure_dns_private_resolver_outbound_endpoint"
    dns_zone                                  = "azure_dns_zone"
    document_intelligence                     = "azure_document_intelligence"
    eventgrid_domain                          = "azure_eventgrid_domain"
    eventgrid_event_subscription              = "azure_eventgrid_event_subscription"
    eventgrid_namespace                       = "azure_eventgrid_namespace"
    eventgrid_system_topic                    = "azure_eventgrid_system_topic"
    eventgrid_topic                           = "azure_eventgrid_topic"
    eventhub                                  = "azure_eventhub"
    eventhub_namespace                        = "azure_eventhub_namespace"
    express_route_circuit                     = "azure_express_route_circuit"
    express_route_direct                      = "azure_express_route_direct"
    express_route_gateway                     = "azure_express_route_gateway"
    fabric_capacity                           = "azure_fabric_capacity"
    face_api                                  = "azure_face_api"
    file_share                                = "azure_file_share"
    firewall                                  = "azure_firewall"
    firewall_policy                           = "azure_firewall_policy"
    firewall_policy_rule_collection_group     = "azure_firewall_policy_rule_collection_group"
    foundry_account                           = "azure_foundry_account"
    foundry_account_project                   = "azure_foundry_account_project"
    foundry_hub                               = "azure_foundry_hub"
    foundry_hub_project                       = "azure_foundry_hub_project"
    foundry_tools_multi_service               = "azure_foundry_tools_multi_service"
    frontdoor                                 = "azure_frontdoor"
    frontdoor_endpoint                        = "azure_frontdoor_endpoint"
    frontdoor_firewall_policy                 = "azure_frontdoor_firewall_policy"
    function_app                              = "azure_function_app"
    gallery                                   = "azure_gallery"
    hdinsight_hadoop_cluster                  = "azure_hdinsight_hadoop_cluster"
    hdinsight_hbase_cluster                   = "azure_hdinsight_hbase_cluster"
    hdinsight_kafka_cluster                   = "azure_hdinsight_kafka_cluster"
    hdinsight_ml_services_cluster             = "azure_hdinsight_ml_services_cluster"
    hdinsight_spark_cluster                   = "azure_hdinsight_spark_cluster"
    hdinsight_storm_cluster                   = "azure_hdinsight_storm_cluster"
    health_insights                           = "azure_health_insights"
    hosting_environment                       = "azure_hosting_environment"
    image_template                            = "azure_image_template"
    immersive_reader                          = "azure_immersive_reader"
    integration_account                       = "azure_integration_account"
    iothub                                    = "azure_iothub"
    ip_group                                  = "azure_ip_group"
    key_vault                                 = "azure_key_vault"
    key_vault_managed_hsm                     = "azure_key_vault_managed_hsm"
    kubernetes_cluster                        = "azure_kubernetes_cluster"
    kusto_cluster                             = "azure_kusto_cluster"
    kusto_database                            = "azure_kusto_database"
    language_service                          = "azure_language_service"
    lb_external                               = "azure_lb_external"
    lb_internal                               = "azure_lb_internal"
    lb_rule                                   = "azure_lb_rule"
    load_testing_instance                     = "azure_load_testing_instance"
    local_network_gateway                     = "azure_local_network_gateway"
    log_analytics_cluster                     = "azure_log_analytics_cluster"
    log_analytics_query_pack                  = "azure_log_analytics_query_pack"
    log_analytics_solution                    = "azure_log_analytics_solution"
    log_analytics_workspace                   = "azure_log_analytics_workspace"
    logic_app_integration_account             = "azure_logic_app_integration_account"
    logic_app_workflow                        = "azure_logic_app_workflow"
    machine_learning_workspace                = "azure_machine_learning_workspace"
    managed_devops_pool                       = "azure_managed_devops_pool"
    managed_disk_data                         = "azure_managed_disk_data"
    managed_disk_os                           = "azure_managed_disk_os"
    managed_grafana                           = "azure_managed_grafana"
    managed_identity                          = "azure_managed_identity"
    management_group                          = "azure_management_group"
    maps_account                              = "azure_maps_account"
    migrate_project                           = "azure_migrate_project"
    monitor_action_group                      = "azure_monitor_action_group"
    monitor_alert_processing_rule             = "azure_monitor_alert_processing_rule"
    monitor_data_collection_rule              = "azure_monitor_data_collection_rule"
    monitor_diagnostics_setting               = "azure_monitor_diagnostics_setting"
    monitor_metric_alert                      = "azure_monitor_metric_alert"
    mysql_database                            = "azure_mysql_database"
    mysql_server                              = "azure_mysql_server"
    nat_gateway                               = "azure_nat_gateway"
    network_ddos_protection_plan              = "azure_network_ddos_protection_plan"
    network_interface                         = "azure_network_interface"
    network_security_group                    = "azure_network_security_group"
    network_security_perimeter                = "azure_network_security_perimeter"
    network_security_rule                     = "azure_network_security_rule"
    network_watcher                           = "azure_network_watcher"
    notification_hub                          = "azure_notification_hub"
    notification_hub_namespace                = "azure_notification_hub_namespace"
    policy_definition                         = "azure_policy_definition"
    postgres_server                           = "azure_postgres_server"
    postgresql_database                       = "azure_postgresql_database"
    power_bi_embedded                         = "azure_power_bi_embedded"
    private_dns_zone                          = "azure_private_dns_zone"
    private_endpoint                          = "azure_private_endpoint"
    private_link_service                      = "azure_private_link_service"
    provisioning_service                      = "azure_provisioning_service"
    provisioning_service_certificate          = "azure_provisioning_service_certificate"
    proximity_placement_group                 = "azure_proximity_placement_group"
    public_ip                                 = "azure_public_ip"
    public_ip_prefix                          = "azure_public_ip_prefix"
    purview_account                           = "azure_purview_account"
    recovery_services_vault                   = "azure_recovery_services_vault"
    redis_cache                               = "azure_redis_cache"
    resource_group                            = "azure_resource_group"
    restore_point_collection                  = "azure_restore_point_collection"
    route                                     = "azure_route"
    route_filter                              = "azure_route_filter"
    route_server                              = "azure_route_server"
    route_table                               = "azure_route_table"
    service_endpoint                          = "azure_service_endpoint"
    service_endpoint_policy                   = "azure_service_endpoint_policy"
    service_fabric_cluster                    = "azure_service_fabric_cluster"
    service_fabric_managed_cluster            = "azure_service_fabric_managed_cluster"
    servicebus_namespace                      = "azure_servicebus_namespace"
    servicebus_queue                          = "azure_servicebus_queue"
    servicebus_topic                          = "azure_servicebus_topic"
    servicebus_topic_subscription             = "azure_servicebus_topic_subscription"
    shared_image_gallery                      = "azure_shared_image_gallery"
    signalr_service                           = "azure_signalr_service"
    snapshot                                  = "azure_snapshot"
    speech_service                            = "azure_speech_service"
    sql_database                              = "azure_sql_database"
    sql_elastic_job_agent                     = "azure_sql_elastic_job_agent"
    sql_elasticpool                           = "azure_sql_elasticpool"
    sql_managed_database                      = "azure_sql_managed_database"
    sql_managed_instance                      = "azure_sql_managed_instance"
    sql_server                                = "azure_sql_server"
    ssh_key                                   = "azure_ssh_key"
    static_site                               = "azure_static_site"
    storage_account                           = "azure_storage_account"
    storage_account_blob                      = "azure_storage_account_blob"
    storage_account_vm                        = "azure_storage_account_vm"
    storage_sync_service                      = "azure_storage_sync_service"
    stream_analytics                          = "azure_stream_analytics"
    subnet                                    = "azure_subnet"
    synapse_private_link_hub                  = "azure_synapse_private_link_hub"
    synapse_spark_pool                        = "azure_synapse_spark_pool"
    synapse_sql_pool                          = "azure_synapse_sql_pool"
    synapse_workspace                         = "azure_synapse_workspace"
    template_spec                             = "azure_template_spec"
    time_series_insights_environment          = "azure_time_series_insights_environment"
    traffic_manager_profile                   = "azure_traffic_manager_profile"
    translator                                = "azure_translator"
    user_assigned_identity                    = "azure_user_assigned_identity"
    virtual_desktop_application_group         = "azure_virtual_desktop_application_group"
    virtual_desktop_host_pool                 = "azure_virtual_desktop_host_pool"
    virtual_desktop_scaling_plan              = "azure_virtual_desktop_scaling_plan"
    virtual_desktop_workspace                 = "azure_virtual_desktop_workspace"
    virtual_hub                               = "azure_virtual_hub"
    virtual_machine                           = "azure_virtual_machine"
    virtual_machine_maintenance_configuration = "azure_virtual_machine_maintenance_configuration"
    virtual_machine_scale_set                 = "azure_virtual_machine_scale_set"
    virtual_network                           = "azure_virtual_network"
    virtual_network_gateway                   = "azure_virtual_network_gateway"
    virtual_network_manager                   = "azure_virtual_network_manager"
    virtual_network_peering                   = "azure_virtual_network_peering"
    virtual_wan                               = "azure_virtual_wan"
    vpn_gateway                               = "azure_vpn_gateway"
    vpn_gateway_connection                    = "azure_vpn_gateway_connection"
    vpn_site                                  = "azure_vpn_site"
    web_app                                   = "azure_web_app"
    web_application_firewall_policy           = "azure_web_application_firewall_policy"
    webpubsub                                 = "azure_webpubsub"
  }

}

locals {
  azure_resource_profiles = {
    aks = {
      resource_keys = [
        "azure_aks_cluster",
        "azure_kubernetes_cluster",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9_-]/"
      label_value_case     = "none"
      trim_chars           = "-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 63
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    analysis = {
      resource_keys = [
        "azure_analysis_services_server",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 3
      max_length           = 63
      validation_regex     = "^[a-z][a-z0-9]*$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    apim = {
      resource_keys = [
        "azure_api_management",
        "azure_api_management_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    app_plan = {
      resource_keys = [
        "azure_app_service_plan",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 60
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    appconfig = {
      resource_keys = [
        "azure_app_configuration",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 5
      max_length           = 50
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
        "---",
      ]
      hash_policy = "always"
    }
    automation = {
      resource_keys = [
        "azure_automation_account",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 6
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    backup_policy = {
      resource_keys = [
        "azure_backup_vault_policy",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 75
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    backup_vault = {
      resource_keys = [
        "azure_backup_vault",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    batch = {
      resource_keys = [
        "azure_batch_account",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 3
      max_length           = 24
      validation_regex     = "^[a-z0-9]+$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    bot = {
      resource_keys = [
        "azure_bot_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    cdn_endpoint = {
      resource_keys = [
        "azure_cdn_endpoint",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 50
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    cdn_profile = {
      resource_keys = [
        "azure_cdn_profile",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 260
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    cloud = {
      resource_keys = [
        "azure_cloud_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 15
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    cognitive = {
      resource_keys = [
        "azure_computer_vision",
        "azure_content_moderator",
        "azure_content_safety",
        "azure_custom_vision_prediction",
        "azure_custom_vision_training",
        "azure_document_intelligence",
        "azure_face_api",
        "azure_foundry_account",
        "azure_foundry_tools_multi_service",
        "azure_immersive_reader",
        "azure_language_service",
        "azure_openai_service",
        "azure_speech_service",
        "azure_translator",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    common80dot = {
      resource_keys = [
        "azure_availability_set",
        "azure_snapshot",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 80
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    common80under = {
      resource_keys = [
        "azure_disk_encryption_set",
        "azure_managed_disk_data",
        "azure_managed_disk_os",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9_-]/"
      label_value_case     = "none"
      trim_chars           = "-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 80
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    communication = {
      resource_keys = [
        "azure_communication_services",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 63
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    container_app = {
      resource_keys = [
        "azure_container_app",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 32
      validation_regex     = "^([a-z][a-z0-9-]*[a-z0-9]|[a-z])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "when_needed"
    }
    container_env = {
      resource_keys = [
        "azure_container_app_environment",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 60
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    container_group = {
      resource_keys = [
        "azure_container_group",
        "azure_container_instance",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 63
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "when_needed"
    }
    container_job = {
      resource_keys = [
        "azure_container_app_job",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 32
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "when_needed"
    }
    cosmos = {
      resource_keys = [
        "azure_cosmosdb_account",
        "azure_cosmosdb_cassandra_account",
        "azure_cosmosdb_gremlin_account",
        "azure_cosmosdb_mongodb_account",
        "azure_cosmosdb_nosql_account",
        "azure_cosmosdb_table_account",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 44
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    data_factory = {
      resource_keys = [
        "azure_data_factory",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 63
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    eventgrid_50 = {
      resource_keys = [
        "azure_eventgrid_domain",
        "azure_eventgrid_topic",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 50
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    eventgrid_64 = {
      resource_keys = [
        "azure_eventgrid_event_subscription",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    eventhub_entity = {
      resource_keys = [
        "azure_eventhub",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 256
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    eventhub_ns = {
      resource_keys = [
        "azure_eventhub_namespace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 6
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    file_share = {
      resource_keys = [
        "azure_file_share",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 63
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "when_needed"
    }
    frontdoor_waf = {
      resource_keys = [
        "azure_frontdoor_firewall_policy",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^A-Za-z0-9]/"
      label_value_case     = "none"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 1
      max_length           = 128
      validation_regex     = "^[A-Za-z][A-Za-z0-9]*$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    gallery = {
      resource_keys = [
        "azure_gallery",
        "azure_shared_image_gallery",
      ]
      component_delimiter  = "_"
      regex_replace_chars  = "/[^A-Za-z0-9._]/"
      label_value_case     = "none"
      trim_chars           = "._"
      collapse_regex       = "/[._]{2,}/"
      collapse_replacement = "_"
      min_length           = 1
      max_length           = 80
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    grafana = {
      resource_keys = [
        "azure_managed_grafana",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 23
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    hdinsight = {
      resource_keys = [
        "azure_hdinsight_hadoop_cluster",
        "azure_hdinsight_hbase_cluster",
        "azure_hdinsight_kafka_cluster",
        "azure_hdinsight_ml_services_cluster",
        "azure_hdinsight_spark_cluster",
        "azure_hdinsight_storm_cluster",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 59
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    identity = {
      resource_keys = [
        "azure_managed_identity",
        "azure_user_assigned_identity",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9_-]/"
      label_value_case     = "none"
      trim_chars           = "-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 128
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    insights = {
      resource_keys = [
        "azure_application_insights",
        "azure_monitor_action_group",
        "azure_monitor_metric_alert",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 260
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    iothub = {
      resource_keys = [
        "azure_iothub",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 50
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    keyvault = {
      resource_keys = [
        "azure_key_vault",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 24
      validation_regex     = "^([a-z][a-z0-9-]*[a-z0-9]|[a-z])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "always"
    }
    kusto_cluster = {
      resource_keys = [
        "azure_kusto_cluster",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 4
      max_length           = 22
      validation_regex     = "^[a-z][a-z0-9]*$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    kusto_database = {
      resource_keys = [
        "azure_kusto_database",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 260
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    load_test = {
      resource_keys = [
        "azure_load_testing_instance",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 64
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    loganalytics = {
      resource_keys = [
        "azure_log_analytics_cluster",
        "azure_log_analytics_workspace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 4
      max_length           = 63
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    logic43 = {
      resource_keys = [
        "azure_logic_app_workflow",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 43
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    logic80 = {
      resource_keys = [
        "azure_integration_account",
        "azure_logic_app_integration_account",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 80
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    migration_project = {
      resource_keys = [
        "azure_database_migration_project",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 57
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    migration_service = {
      resource_keys = [
        "azure_database_migration_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 62
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    ml_workspace = {
      resource_keys = [
        "azure_foundry_hub",
        "azure_foundry_hub_project",
        "azure_machine_learning_workspace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9_-]/"
      label_value_case     = "none"
      trim_chars           = "-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 33
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    network80 = {
      resource_keys = [
        "azure_application_gateway",
        "azure_application_security_group",
        "azure_bastion_host",
        "azure_connection",
        "azure_express_route_circuit",
        "azure_express_route_gateway",
        "azure_firewall",
        "azure_firewall_policy",
        "azure_firewall_policy_rule_collection_group",
        "azure_lb_external",
        "azure_lb_internal",
        "azure_lb_rule",
        "azure_local_network_gateway",
        "azure_network_interface",
        "azure_network_security_group",
        "azure_network_security_rule",
        "azure_network_watcher",
        "azure_public_ip",
        "azure_public_ip_prefix",
        "azure_route",
        "azure_route_filter",
        "azure_route_table",
        "azure_service_endpoint_policy",
        "azure_subnet",
        "azure_virtual_network_gateway",
        "azure_virtual_network_peering",
        "azure_virtual_wan",
        "azure_vpn_gateway",
        "azure_vpn_gateway_connection",
        "azure_vpn_site",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 80
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    network80under = {
      resource_keys = [
        "azure_dns_forwarding_ruleset",
        "azure_dns_private_resolver",
        "azure_dns_private_resolver_inbound_endpoint",
        "azure_dns_private_resolver_outbound_endpoint",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9_-]/"
      label_value_case     = "none"
      trim_chars           = "-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 80
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9_-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    notification_hub = {
      resource_keys = [
        "azure_notification_hub",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 260
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    notification_ns = {
      resource_keys = [
        "azure_notification_hub_namespace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 6
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    pg = {
      resource_keys = [
        "azure_postgresql_flexible_server",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 63
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "always"
    }
    powerbi = {
      resource_keys = [
        "azure_power_bi_embedded",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 3
      max_length           = 63
      validation_regex     = "^[a-z][a-z0-9]*$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    private64 = {
      resource_keys = [
        "azure_private_endpoint",
        "azure_private_link_service",
        "azure_virtual_network",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    provisioning = {
      resource_keys = [
        "azure_provisioning_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    provisioning_cert = {
      resource_keys = [
        "azure_provisioning_service_certificate",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    recovery = {
      resource_keys = [
        "azure_recovery_services_vault",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    redis = {
      resource_keys = [
        "azure_redis_cache",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 63
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "always"
    }
    registry = {
      resource_keys = [
        "azure_container_registry",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 5
      max_length           = 50
      validation_regex     = "^[a-z0-9]+$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    resource_group = {
      resource_keys = [
        "azure_resource_group",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 90
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    sb_entity = {
      resource_keys = [
        "azure_servicebus_queue",
        "azure_servicebus_topic",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 260
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    sb_ns = {
      resource_keys = [
        "azure_servicebus_namespace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 6
      max_length           = 50
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    sb_sub = {
      resource_keys = [
        "azure_servicebus_topic_subscription",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 50
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    search = {
      resource_keys = [
        "azure_ai_search",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 60
      validation_regex     = "^[a-z0-9]{2}([a-z0-9-]*[a-z0-9])?$"
      forbidden_regexes = [
        "--",
      ]
      hash_policy = "always"
    }
    service_fabric = {
      resource_keys = [
        "azure_service_fabric_cluster",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 4
      max_length           = 23
      validation_regex     = "^([a-z][a-z0-9-]*[a-z0-9]|[a-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    signalr = {
      resource_keys = [
        "azure_signalr_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 63
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    sql_child = {
      resource_keys = [
        "azure_sql_database",
        "azure_sql_elasticpool",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 128
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    sql_global = {
      resource_keys = [
        "azure_sql_managed_instance",
        "azure_sql_server",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 63
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    static_site = {
      resource_keys = [
        "azure_static_site",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 60
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    storage = {
      resource_keys = [
        "azure_storage_account",
        "azure_storage_account_vm",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 3
      max_length           = 24
      validation_regex     = "^[a-z0-9]+$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    storage_sync = {
      resource_keys = [
        "azure_storage_sync_service",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 260
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    synapse_plh = {
      resource_keys = [
        "azure_synapse_private_link_hub",
      ]
      component_delimiter  = ""
      regex_replace_chars  = "/[^a-z0-9]/"
      label_value_case     = "lower"
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      min_length           = 1
      max_length           = 45
      validation_regex     = "^[a-z0-9]+$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    synapse_workspace = {
      resource_keys = [
        "azure_synapse_workspace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^a-z0-9-]/"
      label_value_case     = "lower"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 50
      validation_regex     = "^([a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9])$"
      forbidden_regexes = [
        "-ondemand",
      ]
      hash_policy = "always"
    }
    template = {
      resource_keys = [
        "azure_template_spec",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 90
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    traffic = {
      resource_keys = [
        "azure_traffic_manager_profile",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 1
      max_length           = 63
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    vdi = {
      resource_keys = [
        "azure_virtual_desktop_application_group",
        "azure_virtual_desktop_host_pool",
        "azure_virtual_desktop_workspace",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9._-]/"
      label_value_case     = "none"
      trim_chars           = ".-_"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 64
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "when_needed"
    }
    web_site = {
      resource_keys = [
        "azure_function_app",
        "azure_web_app",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 2
      max_length           = 60
      validation_regex     = "^([A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z0-9])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
    webpubsub = {
      resource_keys = [
        "azure_webpubsub",
      ]
      component_delimiter  = "-"
      regex_replace_chars  = "/[^A-Za-z0-9-]/"
      label_value_case     = "none"
      trim_chars           = "-"
      collapse_regex       = "/-{2,}/"
      collapse_replacement = "-"
      min_length           = 3
      max_length           = 63
      validation_regex     = "^([A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]|[A-Za-z])$"
      forbidden_regexes = [
      ]
      hash_policy = "always"
    }
  }

  azure_resource_profile_by_key = merge([
    for profile_name, profile in local.azure_resource_profiles : {
      for resource_type in profile.resource_keys : resource_type => profile_name
    }
  ]...)

  azure_resource_label_rules = {
    for resource_type, profile_name in local.azure_resource_profile_by_key :
    resource_type => {
      code_position        = "prefix"
      label_groups         = [["namespace", "application", "region_code", "environment_code", "attributes"]]
      component_delimiter  = local.azure_resource_profiles[profile_name].component_delimiter
      group_delimiter      = ""
      regex_replace_chars  = local.azure_resource_profiles[profile_name].regex_replace_chars
      label_value_case     = local.azure_resource_profiles[profile_name].label_value_case
      trim_chars           = local.azure_resource_profiles[profile_name].trim_chars
      collapse_regex       = local.azure_resource_profiles[profile_name].collapse_regex
      collapse_replacement = local.azure_resource_profiles[profile_name].collapse_replacement
      required_prefix      = ""
      required_suffix      = ""
      min_length           = local.azure_resource_profiles[profile_name].min_length
      max_length           = local.azure_resource_profiles[profile_name].max_length
      validation_regex     = local.azure_resource_profiles[profile_name].validation_regex
      forbidden_regexes    = local.azure_resource_profiles[profile_name].forbidden_regexes
      hash_policy          = local.azure_resource_profiles[profile_name].hash_policy
      hash_length          = null
    }
  }
}
