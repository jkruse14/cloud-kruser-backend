locals {
  s3_origin_id        = "cloudKruserS3Origin"
  default_root_object = "index.html"
  one_day             = 86400
  one_year            = 31536000
}

resource "aws_s3_bucket" "cloud_kruser" {
  bucket = "cloud-kruser-static-website"
}

resource "aws_s3_bucket" "cloud_kruser_logs" {
  bucket = "cloud-kruser-logs"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cloud_kruser.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloud_kruser_cf_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloud_kruser" {
  bucket = aws_s3_bucket.cloud_kruser.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_acl" "cloud_kruser" {
  bucket = aws_s3_bucket.cloud_kruser.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "cloud_kruser" {
  bucket = aws_s3_bucket.cloud_kruser.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "cloud_kruser" {
  bucket = aws_s3_bucket.cloud_kruser.id
  index_document {
    suffix = local.default_root_object
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_cloudfront_origin_access_identity" "cloud_kruser_cf_oai" {}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.cloud_kruser.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloud_kruser_cf_oai.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = local.default_root_object

  # logging_config {
  #   include_cookies = false
  #   bucket          = aws_s3_bucket.cloud_kruser_logs.id
  #   prefix          = "logs"
  # }
  aliases = ["cloudkruser.com", "www.cloudkruser.com"]
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.com_cert.arn
    ssl_support_method  = "sni-only"
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = local.one_day
    max_ttl                = local.one_year
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
}

resource "aws_route53domains_registered_domain" "cloud_kruser" {
  domain_name = "cloudkruser.com"
  name_server {
    name = "ns-1427.awsdns-50.org"
  }
  name_server {
    name = "ns-455.awsdns-56.com"
  }
  name_server {
    name = "ns-2002.awsdns-58.co.uk"
  }
  name_server {
    name = "ns-673.awsdns-20.net"
  }
}

resource "aws_acm_certificate" "com_cert" {
  domain_name               = "cloudkruser.com"
  subject_alternative_names = ["www.cloudkruser.com"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "cloud_kruser_com" {
  name         = "cloudkruser.com"
  private_zone = false
}

resource "aws_route53_record" "cloud_kruser_record" {
  for_each = {
    for dvo in aws_acm_certificate.com_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cloud_kruser_com.zone_id
}

resource "aws_route53_record" "cf_record" {
  zone_id = data.aws_route53_zone.cloud_kruser_com.zone_id
  type    = "A"
  name    = "cloudkruser.com"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.com_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cloud_kruser_record : record.fqdn]
}

resource "aws_iam_role" "cloud_kruser_lambda_execution" {
  name               = "cloud-kruser-lambda-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "cloud_kruser_lambda_execution_with_visitor_counter_write" {
  name = "cloud-kruser-lambda-execution-role-with-visitor-counter-write"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
  inline_policy {
    name = "AccessTableAllIndexesOnVisitorCounter"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect : "Allow"
          Action : [
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchWriteItem",
            "dynamodb:GetItem",
            "dynamodb:BatchGetItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:ConditionCheckItem"
          ],
          Resource = [
            "${resource.aws_dynamodb_table.visitor_counter.arn}",
            "${resource.aws_dynamodb_table.visitor_counter.arn}/index/*"
          ]
        }
      ]
    })
  }
}

# Lambda Relate IaC

resource "aws_lambda_layer_version" "yarn_cache_resources" {
  filename            = "../nodejs.zip"
  layer_name          = "cloud-kruser-lambdas-yarn-cache"
  compatible_runtimes = ["nodejs16.x"]
  source_code_hash    = filebase64sha256("../nodejs.zip")
}

module "lambda_functions" {
  source      = "./modules/lambda-functions"
  name_prefix = "cloud-kruser-lambdas"
  lambdas = {
    hello = {
      role_arn      = aws_iam_role.cloud_kruser_lambda_execution.arn
      function_name = "hello"
      filename      = "../packages//hello/lambda.zip"
      handler       = "./hello/src/index.handle"
      environment_variables = {
        DEFAULT_AWS_REGION = "us-east-1"
        SETUP_PNP          = true
      }
      memory_size = 128
      timeout     = 3
    }

    goodbye = {
      role_arn      = aws_iam_role.cloud_kruser_lambda_execution.arn
      function_name = "goodbye"
      filename      = "../packages/goodbye/lambda.zip"
      handler       = "./goodbye/src/index.handle"
      environment_variables = {
        DEFAULT_AWS_REGION = "us-east-1"
        SETUP_PNP          = true
      }
      memory_size = 128
      timeout     = 3
    }
    createVisitorCounterItem = {
      role_arn      = aws_iam_role.cloud_kruser_lambda_execution_with_visitor_counter_write.arn
      function_name = "create-visitor-counter-item"
      filename      = "../packages/visitor-counter-create/lambda.zip"
      handler       = "./visitor-counter-create/src/index.handle"
      environment_variables = {
        DEFAULT_AWS_REGION = "us-east-1"
        SETUP_PNP          = true
      }
      memory_size = 128
      timeout     = 3
    }
  }
  common_layers = [resource.aws_lambda_layer_version.yarn_cache_resources.arn]
}

# End Lambda Related Iac

# DynamoDB Related IaC
resource "aws_dynamodb_table" "visitor_counter" {
  name         = "VistorCounter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "visitorId"

  attribute {
    name = "visitorId"
    type = "S"
  }
}

# End DDB

#  Begin APIG
