# AWS CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.name_prefix}/application"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = {
    Name = "${var.name_prefix}-application-logs"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/${var.name_prefix}/vpc-flow"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs"
  }
}

# AWS VPC Flow Logs Role & Policy
resource "aws_iam_role" "flow_logs" {
  name = "${var.name_prefix}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.name_prefix}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "vpc" {
  iam_role_arn             = aws_iam_role.flow_logs.arn
  log_destination          = aws_cloudwatch_log_group.vpc_flow.arn
  traffic_type             = "ALL"
  vpc_id                   = var.vpc_id
  max_aggregation_interval = 60

  tags = {
    Name = "${var.name_prefix}-vpc-flow-log"
  }
}

# AWS CloudTrail S3 Bucket & Trail
resource "random_string" "trail_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.name_prefix}-cloudtrail-${random_string.trail_suffix.result}"
  force_destroy = true

  tags = {
    Name = "${var.name_prefix}-cloudtrail"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# AWS GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  count                        = var.enable_guardduty ? 1 : 0
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Name = "${var.name_prefix}-guardduty"
  }
}

# Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.name_prefix}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.common_tags
}

# Azure VPN Gateway Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "vpn_gateway" {
  name                       = "diag-${var.name_prefix}-vpn"
  target_resource_id         = var.azure_vpn_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "GatewayDiagnosticLog"
  }
  enabled_log {
    category = "TunnelDiagnosticLog"
  }
  enabled_log {
    category = "RouteDiagnosticLog"
  }
  enabled_log {
    category = "IKEDiagnosticLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Azure Defender Pricing Plans
resource "azurerm_security_center_subscription_pricing" "vms" {
  count         = var.enable_defender ? 1 : 0
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "kv" {
  count         = var.enable_defender ? 1 : 0
  tier          = "Standard"
  resource_type = "KeyVaults"
}
