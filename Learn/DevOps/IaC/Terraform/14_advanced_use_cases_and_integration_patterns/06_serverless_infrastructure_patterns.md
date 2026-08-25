## Serverless Infrastructure Patterns


### AWS Lambda with Infrastructure

```hcl
# serverless-patterns.tf
# Lambda Function
resource "aws_lambda_function" "api_handler" {
  filename         = "api_handler.zip"
  function_name    = "${var.environment}-api-handler"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 256
  
  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }
  
  environment {
    variables = {
      DB_HOST     = aws_db_instance.main.endpoint
      REDIS_HOST  = aws_elasticache_cluster.main.cache_nodes[0].address
      S3_BUCKET   = aws_s3_bucket.app_storage.bucket
      ENVIRONMENT = var.environment
    }
  }
  
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  
  tracing_config {
    mode = "Active"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# API Gateway Integration
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.environment}-api"
  description = "Serverless API Gateway"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ips
          }
        }
      }
    ]
  })
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "ANY"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.api_handler.invoke_arn
}

# Step Functions for Orchestration
resource "aws_sfn_state_machine" "order_processing" {
  name     = "${var.environment}-order-processing"
  role_arn = aws_iam_role.step_function.arn
  
  definition = jsonencode({
    Comment = "Order processing workflow"
    StartAt = "ValidateOrder"
    States = {
      ValidateOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.validate_order.arn
        Next     = "ProcessPayment"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "OrderFailed"
          }
        ]
      }
      ProcessPayment = {
        Type     = "Task"
        Resource = aws_lambda_function.process_payment.arn
        Next     = "UpdateInventory"
      }
      UpdateInventory = {
        Type     = "Task"
        Resource = aws_lambda_function.update_inventory.arn
        Next     = "SendNotification"
      }
      SendNotification = {
        Type     = "Task"
        Resource = aws_lambda_function.send_notification.arn
        End      = true
      }
      OrderFailed = {
        Type   = "Fail"
        Cause  = "Order processing failed"
      }
    }
  })
}

# EventBridge for Event-Driven Architecture
resource "aws_cloudwatch_event_rule" "order_created" {
  name        = "${var.environment}-order-created"
  description = "Trigger when order is created"
  
  event_pattern = jsonencode({
    source      = ["custom.orders"]
    detail-type = ["Order Created"]
  })
}

resource "aws_cloudwatch_event_target" "step_function" {
  rule      = aws_cloudwatch_event_rule.order_created.name
  target_id = "OrderProcessingStepFunction"
  arn       = aws_sfn_state_machine.order_processing.arn
  role_arn  = aws_iam_role.eventbridge_step_function.arn
}

# SQS for Async Processing
resource "aws_sqs_queue" "order_queue" {
  name                       = "${var.environment}-order-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 300
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.order_processor.arn
  batch_size       = 10
  
  scaling_config {
    maximum_concurrency = 100
  }
}

# DynamoDB for Serverless Database
resource "aws_dynamodb_table" "orders" {
  name           = "${var.environment}-orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "order_id"
  range_key      = "created_at"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  attribute {
    name = "created_at"
    type = "S"
  }
  
  attribute {
    name = "customer_id"
    type = "S"
  }
  
  global_secondary_index {
    name     = "customer-index"
    hash_key = "customer_id"
    
    projection_type = "ALL"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb.arn
  }
  
  tags = {
    Name        = "${var.environment}-orders"
    Environment = var.environment
  }
}

# DynamoDB Streams Lambda Trigger
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.orders.stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 100
  
  filter_criteria {
    filter {
      pattern = jsonencode({
        eventName = ["INSERT", "MODIFY"]
      })
    }
  }
}

## Azure Serverless Patterns

# Azure Functions
resource "azurerm_storage_account" "functions" {
  name                     = "${var.environment}funcsa"
  resource_group_name      = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "functions" {
  name                = "${var.environment}-functions-plan"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  os_type            = "Linux"
  sku_name           = "Y1"
}

resource "azurerm_linux_function_app" "main" {
  name                = "${var.environment}-functions"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id           = azurerm_service_plan.functions.id
  
  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
  
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "COSMOS_DB_CONNECTION_STRING" = azurerm_cosmosdb_account.main.connection_strings[0]
    "SERVICE_BUS_CONNECTION_STRING" = azurerm_servicebus_namespace.main.default_primary_connection_string
  }
}

# Logic Apps for Workflow
resource "azurerm_logic_app_workflow" "order_processing" {
  name                = "${var.environment}-order-workflow"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  workflow_schema    = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version   = "1.0.0.0"
  
  parameters = {
    cosmosdb_connection = {
      type = "string"
      value = azurerm_cosmosdb_account.main.connection_strings[0]
    }
  }
}

## Google Cloud Serverless Patterns

# Cloud Functions
resource "google_cloudfunctions_function" "api_handler" {
  name        = "${var.environment}-api-handler"
  description = "API request handler"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.functions.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  trigger {
    http_trigger {
      url = null
    }
  }
  
  environment_variables = {
    DATABASE_URL = google_sql_database_instance.main.connection_name
    PROJECT_ID   = var.gcp_project_id
  }
  
  vpc_connector                 = google_vpc_access_connector.main.name
  vpc_connector_egress_settings = "ALL_TRAFFIC"
}

# Cloud Run for Containerized Serverless
resource "google_cloud_run_service" "api" {
  name     = "${var.environment}-api"
  location = var.gcp_region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project_id}/${var.app_name}:${var.app_version}"
        
        env {
          name  = "DATABASE_URL"
          value = google_sql_database_instance.main.connection_name
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        ports {
          container_port = 8080
        }
      }
      
      container_concurrency = 80
      timeout_seconds      = 300
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "100"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.main.connection_name
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.name
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Pub/Sub for Event-Driven Architecture
resource "google_pubsub_topic" "orders" {
  name = "${var.environment}-orders"
  
  message_storage_policy {
    allowed_persistence_regions = [var.gcp_region]
  }
}

resource "google_pubsub_subscription" "order_processor" {
  name  = "${var.environment}-order-processor"
  topic = google_pubsub_topic.orders.name
  
  message_retention_duration = "1200s"
  retain_acked_messages     = true
  ack_deadline_seconds      = 20
  
  expiration_policy {
    ttl = "300000.5s"
  }
  
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
  
  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 10
  }
}

# Cloud Workflows
resource "google_workflows_workflow" "order_processing" {
  name            = "${var.environment}-order-workflow"
  region          = var.gcp_region
  description     = "Order processing workflow"
  service_account = google_service_account.workflow.email
  
  source_contents = yamlencode({
    main = {
      steps = [
        {
          validate_order = {
            call = "http.post"
            args = {
              url = "${google_cloud_run_service.api.status[0].url}/validate"
              body = "${args.order}"
            }
            result = "validation_result"
          }
        },
        {
          process_payment = {
            call = "http.post"
            args = {
              url = "${google_cloud_run_service.api.status[0].url}/payment"
              body = {
                order_id = "${validation_result.body.order_id}"
                amount   = "${validation_result.body.amount}"
              }
            }
            result = "payment_result"
          }
        },
        {
          update_inventory = {
            call = "googleapis.firestore.v1.documents.patch"
            args = {
              name = "projects/${var.gcp_project_id}/databases/(default)/documents/inventory/${args.order.product_id}"
              body = {
                fields = {
                  quantity = {
                    integerValue = "${args.order.quantity - 1}"
                  }
                }
              }
            }
          }
        }
      ]
    }
  })
}

## Network and Security Automation

### Multi-Cloud Network Mesh
resource "aws_transit_gateway" "main" {
  description                     = "${var.environment} Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "${var.environment}-tgw"
  }
}

resource "aws_transit_gateway_vpc_attachment" "vpc_attachments" {
  count = length(var.vpc_ids)
  
  subnet_ids         = var.tgw_subnet_ids[count.index]
  transit_gateway_id = aws_transit_gateway.main.id
  vpc_id            = var.vpc_ids[count.index]
  
  tags = {
    Name = "${var.environment}-tgw-attachment-${count.index}"
  }
}

# AWS Network Firewall
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.environment}-firewall-policy"
  
  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.allow_icmp.arn
    }
    
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_filtering.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "domain_filtering" {
  capacity = 100
  name     = "${var.environment}-domain-filtering"
  type     = "STATEFUL"
  
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/16", "192.168.0.0/16"]
        }
      }
    }
    
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types        = ["HTTP_HOST", "TLS_SNI"]
        targets             = var.blocked_domains
      }
    }
  }
}

resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.environment}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id             = var.firewall_vpc_id
  
  dynamic "subnet_mapping" {
    for_each = var.firewall_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }
}

### Zero Trust Network Architecture
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "${var.environment} Client VPN"
  server_certificate_arn = aws_acm_certificate.vpn_server.arn
  client_cidr_block     = "172.16.0.0/16"
  
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_client.arn
  }
  
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }
  
  dns_servers = ["8.8.8.8", "8.8.4.4"]
  
  tags = {
    Name = "${var.environment}-client-vpn"
  }
}

# Service Mesh with Istio (EKS)
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  version    = var.istio_version
  
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = var.istio_version
  
  values = [
    yamlencode({
      global = {
        meshID      = var.environment
        network     = "network1"
        hub         = "docker.io/istio"
        tag         = var.istio_version
      }
      pilot = {
        env = {
          EXTERNAL_ISTIOD = false
        }
      }
    })
  ]
  
  depends_on = [helm_release.istio_base]
}

# Network Policies
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = "default"
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_frontend_to_backend" {
  metadata {
    name      = "allow-frontend-to-backend"
    namespace = "default"
  }
  
  spec {
    pod_selector {
      match_labels = {
        app = "backend"
      }
    }
    
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "frontend"
          }
        }
      }
      
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
    
    policy_types = ["Ingress"]
  }
}

### Security Automation Patterns

# AWS Config Rules
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.environment}-config-recorder"
  role_arn = aws_iam_role.config.arn
  
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "${var.environment}-s3-bucket-public-read-prohibited"
  
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_remediation_configuration" "s3_bucket_public_read" {
  config_rule_name = aws_config_config_rule.s3_bucket_public_read_prohibited.name
  
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-RemoveS3BucketPolicy"
  target_version   = "1"
  
  parameter {
    name           = "AutomationAssumeRole"
    static_value   = aws_iam_role.config_remediation.arn
  }
  
  parameter {
    name                = "BucketName"
    resource_value      = "RESOURCE_ID"
  }
  
  automatic          = true
  maximum_automatic_attempts = 3
}

# Security Hub Custom Insights
resource "aws_securityhub_insight" "critical_findings" {
  filters {
    severity_label {
      comparison = "EQUALS"
      value      = "CRITICAL"
    }
    
    record_state {
      comparison = "EQUALS"
      value      = "ACTIVE"
    }
  }
  
  group_by_attribute = "ProductArn"
  name              = "${var.environment}-critical-findings"
}

# CloudWatch Security Metrics
resource "aws_cloudwatch_metric_alarm" "high_failed_logins" {
  alarm_name          = "${var.environment}-high-failed-logins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FailedLoginAttempts"
  namespace           = "CustomSecurity"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors failed login attempts"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
  
  insufficient_data_actions = []
}

# AWS Systems Manager for Patch Management
resource "aws_ssm_patch_baseline" "main" {
  name             = "${var.environment}-patch-baseline"
  description      = "Patch baseline for ${var.environment}"
  operating_system = "UBUNTU"
  
  approval_rule {
    approve_after_days = 7
    
    patch_filter {
      key    = "PRIORITY"
      values = ["Required", "Important"]
    }
    
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix", "Enhancement"]
    }
  }
  
  rejected_patches = ["kernel*"]
}

resource "aws_ssm_patch_group" "main" {
  baseline_id = aws_ssm_patch_baseline.main.id
  patch_group = "${var.environment}-servers"
}

resource "aws_ssm_maintenance_window" "main" {
  name     = "${var.environment}-maintenance-window"
  schedule = "cron(0 2 ? * SUN *)"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "main" {
  window_id     = aws_ssm_maintenance_window.main.id
  name          = "${var.environment}-maintenance-target"
  description   = "Maintenance window target"
  resource_type = "INSTANCE"
  
  targets {
    key    = "tag:PatchGroup"
    values = ["${var.environment}-servers"]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_task" {
  max_concurrency = "2"
  max_errors      = "1"
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.main.id
  
  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.main.id]
  }
  
  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      
      timeout_seconds = 3600
    }
  }
}
```

