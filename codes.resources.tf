locals {
  default_resource_codes = {
    #General
    api_management         = "apim"   # API Management service instance
    management_group       = "mg"     # Azure Management Group
    user_assigned_identity = "id"     # Managed identity
    policy_definition      = "policy" # Azure Policy Definition
    resource_group         = "rg"     # Azure resource group

    #Networking
    application_gateway                   = "agw"   # Application gateway
    application_security_group            = "asg"   # Application security group
    bastion_host                          = "bas"   # Azure Bastion Host
    cdn_profile                           = "cdnp"  # Azure CDN profile
    cdn_endpoint                          = "cdne"  # Azure CDN endpoint
    connection                            = "con"   # Azure Connection (Express Route, Network, BGP, Gateway)
    dns_zone                              = "dnsz"  # Azure DNS zone
    private_dns_zone                      = "pdnsz" # Azure Private DNS zone
    firewall                              = "afw"   # Azure Firewall
    firewall_policy                       = "afwp"  # Azure Firewall Policy
    express_route_circuit                 = "erc"   # Azure Express Route Circuit
    frontdoor                             = "afd"   # Azure Front Door
    frontdoor_firewall_policy             = "fdfp"  # Azure Front Door Firewall Policy
    lb_internal                           = "lbi"   # Azure load balancer (Internal)
    lb_external                           = "lbe"   # Azure load balancer (External)
    lb_rule                               = "rule"  # Azure load balancer inbound NAT rule
    local_network_gateway                 = "lgw"   # Azure Local Network Gateway
    nat_gateway                           = "ng"    # Azure NAT Gateway
    network_ddos_protection_plan          = "dosp"  # DDoS protection plan
    network_interface                     = "nic"   # network interface
    network_security_group                = "nsg"   # Azure network security group
    network_security_rule                 = "nsgsr" # Azure network security rule
    network_watcher                       = "nw"    # Azure network watcher
    private_link_service                  = "pl"    # Azure Private Link Service
    private_endpoint                      = "pep"   # Azure Private Endpoint
    public_ip                             = "pip"   # Public IP
    public_ip_prefix                      = "ippre" # Public IP Prefix
    route_filter                          = "rf"    # Azure Route Filter
    route_table                           = "rt"    # Azure routing table
    service_endpoint                      = "se"    # Azure Service Endpoint
    traffic_manager_profile               = "traf"  # Azure Traffic Manager Profile
    route                                 = "udr"   # Azure User Defined Route
    virtual_network                       = "vnet"  # Azure vnet
    virtual_network_peering               = "peer"  # Azure vnet peering
    subnet                                = "snet"  # Azure subnet
    virtual_wan                           = "vwan"  # Azure Virtual WAN
    virtual_hub                           = "vhub"  # Azure Virtual Hub
    vpn_gateway                           = "vpng"  # Azure VPN Gateway
    vpn_gateway_connection                = "vcn"   # Azure VPN Gateway Connection
    vpn_site                              = "vst"   # Azure VPN Site
    virtual_network_gateway               = "vgw"   # Azure Virtual Network Gateway
    web_application_firewall_policy       = "waf"   # Azure Web Application Firewall Policy
    firewall_policy_rule_collection_group = "wafrg" # Azure Web Application Firewall Policy Rule Collection Group

    #Compute and Web
    app_service_environment        = "ase"    # App Service Environment
    app_service_plan               = "asp"    # App Service plan
    app_service                    = "asvc"   # App Service
    availability_set               = "avail"  # Azure Availability Set
    arc_enabled_server             = "arcs"   # Azure Arc Enabled Server
    arc_enabled_kubernetes_cluster = "arck"   # Azure Arc Enabled Kubernetes Cluster
    cloud_service                  = "cld"    # Azure Cloud Service
    disk_encryption_set            = "des"    # Azure Disk Encryption Set
    function_app                   = "func"   # Function App
    shared_image_gallery           = "gal"    # Azure shared image gallery
    managed_disk_os                = "osdisk" # Managed disk (OS)
    managed_disk_data              = "disk"   # Managed disk (Data)
    notification_hub               = "ntf"    # Azure Notification Hub
    notification_hub_namespace     = "ntfns"  # Azure Notification Hub Namespace
    snapshot                       = "snap"   # Azure Snapshot
    spring_cloud_service           = "asc"    # Azure Spring Cloud
    static_site                    = "stapp"  # Azure Static Site
    virtual_machine                = "vm"     # Azure Virtual Machine
    virtual_machine_scale_set      = "vmss"   # Azure VM scaling set
    storage_account_vm             = "stvm"   # Azure storage account (VM)
    web_app                        = "app"    # Azure Web App

    #Containers
    kubernetes_cluster     = "aks" # Azure Kubernetes Cluster
    container_registry     = "cr"  # Azure Container Registry
    container_instance     = "ci"  # Azure Container Instance
    container_group        = "cg"  # Azure Container Group
    service_fabric_cluster = "sf"  # Azure Service Fabric Cluster

    #Databases
    cosmosdb_account                   = "cosmos"  # CosmosDB account
    redis_cache                        = "redis"   # Redis Cache
    sql_server                         = "sql"     # Microsoft SQL Azure Database Server
    sql_database                       = "sqldb"   # Microsoft SQL Azure Database Server Database
    sql_elasticpool                    = "sqlep"   # Microsoft SQL Azure Database Server Elastic Pool
    synapse_workspace                  = "synw"    # Azure Synapse Workspace
    stream_analytics_synapse_workspace = "synw"    # Azure Stream Analytics Synapse Workspace
    synapse_sql_pool                   = "syndp"   # Azure Synapse SQL Dedicated Pool
    synapse_spark_pool                 = "synsp"   # Azure Synapse Spark Pool
    mysql_server                       = "mysql"   # Azure MySQL database server
    mysql_database                     = "mysqldb" # Azure MySQL database
    postgres_server                    = "psql"    # Azure Postgres database server
    sql_managed_database               = "sqlmdb"  # Azure SQL Managed Database
    sql_managed_instance               = "sqlmi"   # Azure SQL Managed Instance

    #Storage
    storage_account      = "st"   # Azure storage account
    storage_account_blob = "blob" # Azure blob storage container

    #AI and Machine Learning
    machine_learning_workspace = "mlw" # Machine Learning Workspace

    #Analytics and IOT
    analysis_services_server     = "as"    # Azure Analysis Services Server
    databricks_workspace         = "dbw"   # DataBricks Workspace
    stream_analytics             = "asa"   # Azure Stream Analytics
    kusto_cluster                = "dec"   # Azure Data Explorer Cluster
    kusto_database               = "dedb"  # Azure Data Explorer Database
    data_factory                 = "adf"   # Azure Data Factory
    eventhub_cluster             = "evhc"  # Event Hub Cluster
    eventhub_namespace           = "evhns" # Event Hub namespace
    eventhub                     = "evh"   # Event Hub
    eventgrid_domain             = "evgd"  # Event Grid Domain
    eventgrid_event_subscription = "evgs"  # Event Grid Subscription
    eventgrid_system_topic       = "evgt"  # Event Grid Topic
    iothub                       = "iot"   # Azure IoT Hub

    #Azure Virtual Desktop
    virtual_desktop_host_pool         = "vdpool" # Azure Virtual Desktop Host Pool
    virtual_desktop_application_group = "vdag"   # Azure Virtual Desktop Application Group
    virtual_desktop_workspace         = "vdws"   # Azure Virtual Desktop Workspace

    #Developer Tools
    app_configuration = "appcs" # App Config
    signalr_service   = "sigr"  # Azure SignalR

    #Integration
    logic_app_integration_account = "ia"    # Azure Logic App Integration Account
    logic_app_workflow            = "logic" # Azure Logic App Workflow
    servicebus_namespace          = "sbns"  # Service Bus namespace
    servicebus_queue              = "sbq"   # Service Bus Queue
    servicebus_topic              = "sbt"   # Service Bus Topic

    #Management and Governance
    automation_account               = "aa"      # Automation Accounts
    application_insights             = "appi"    # App Insights
    monitor_metric_alert             = "azalert" # Azure Monitor Metric Alert
    monitor_action_rule_action_group = "ag"      # Azure Monitor Action Group
    monitor_diagnostics_setting      = "ds"      # Diagnostic setting
    purview_account                  = "pview"   # Azure Purview Account
    blueprint_definition             = "bp"      # Azure Blueprint Definition
    blueprint_assignment             = "bpa"     # Azure Blueprint Assignment
    key_vault                        = "kv"      # Azure key vault
    log_analytics_cluster            = "logc"    # Azure Log Analytics cluster
    log_analytics_workspace          = "log"     # Log analytics workspace
    log_analytics_solution           = "logs"    # Azure Log Analytics solution

    #Migration
    database_migration_project = "migr" # Azure Database Migration Project
    database_migration_service = "dms"  # Azure Database Migration Service
    recovery_services_vault    = "rsv"  # Recovery Services vault
  }
}
