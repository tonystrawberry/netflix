provider "aws" {
  region = "ap-northeast-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

variable "environment" {
  type = string
  default = "development"
}

variable "aws_access_key_id" { type = string }
variable "aws_secret_access_key" { type = string }

data "archive_file" "s3_trigger_aws_lambda_function" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda/s3_trigger_aws_lambda_function.zip"
}

resource "aws_lambda_function" "s3_trigger_aws_lambda_function" {
  function_name    = "tonystrawberry-netflix-s3-trigger-${var.environment}"
  role             = "${aws_iam_role.lambda_aws_iam_role.arn}"
  handler          = "s3_trigger_aws_lambda_function.lambda_handler"
  runtime          = "ruby3.3"
  timeout          = "600"
  filename         = "${data.archive_file.s3_trigger_aws_lambda_function.output_path}"
  source_code_hash = "${data.archive_file.s3_trigger_aws_lambda_function.output_base64sha256}"

  environment {
    variables = {
      DestinationBucket = "${aws_s3_bucket.output_assets_aws_s3_bucket.bucket}"
      MediaConvertRole = "${aws_iam_role.media_convert_aws_iam_role.arn}"
    }
  }
}

resource "aws_iam_role" "lambda_aws_iam_role" {
  name = "tonystrawberry-netflix-lambda-iam-role-${var.environment}"

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

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment" {
  role       = aws_iam_role.lambda_aws_iam_role.name
  policy_arn = aws_iam_policy.lambda_aws_iam_policy.arn
}

# Add permission to create logs in CloudWatch
# and the pass role to media convert role and to do anything on MediaConvert
resource "aws_iam_policy" "lambda_aws_iam_policy" {
  name = "tonystrawberry-netflix-lambda-iam-policy-${var.environment}"
  description = "IAM policy for the API Lambda function"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.assets_aws_s3_bucket.arn}",
          "${aws_s3_bucket.assets_aws_s3_bucket.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.lambda_aws_cloudwatch_log_group.arn,
          "${aws_cloudwatch_log_group.lambda_aws_cloudwatch_log_group.arn}:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.media_convert_aws_iam_role.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "mediaconvert:*"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda_aws_cloudwatch_log_group" {
  name = "/aws/lambda/${aws_lambda_function.s3_trigger_aws_lambda_function.function_name}"
  retention_in_days = 30
}

resource "aws_s3_bucket" "assets_aws_s3_bucket" {
  bucket = "tonystrawberry-netflix-assets-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket" "output_assets_aws_s3_bucket" {
  bucket = "tonystrawberry-netflix-output-assets-${var.environment}"
  force_destroy = true
}

data "aws_cloudfront_cache_policy" "output_assets_aws_cloudfront_cache_policy" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_origin_request_policy" "output_assets_aws_cloudfront_origin_request_policy" {
  name = "Managed-CORS-S3Origin"
}


resource "aws_cloudfront_distribution" "output_assets_aws_cloudfront_distribution" {
  aliases = ["netflix.tonyfromtokyo.online"]
  origin {
    domain_name = aws_s3_bucket.output_assets_aws_s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.output_assets_aws_cloudfront_origin_access_control.id
    origin_id = aws_s3_bucket.output_assets_aws_s3_bucket.id
  }

  enabled =  true

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods = [ "GET", "HEAD", "OPTIONS" ]
    target_origin_id = aws_s3_bucket.output_assets_aws_s3_bucket.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    trusted_key_groups = [aws_cloudfront_key_group.output_assets_aws_cloudfront_public_key_group.id]

    cache_policy_id =  data.aws_cloudfront_cache_policy.output_assets_aws_cloudfront_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.output_assets_aws_cloudfront_origin_request_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.output_assets_aws_cloudfront_response_headers_policy.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
   }
  viewer_certificate {
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
    acm_certificate_arn = "arn:aws:acm:us-east-1:550003277685:certificate/c8ed3332-d3ae-4efa-bd89-fbe414d53e5a"
  }
}
resource "aws_cloudfront_response_headers_policy" "output_assets_aws_cloudfront_response_headers_policy" {
  name    = "tonystrawberry-netflix-output-assets-${var.environment}"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["Cookie"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }

    access_control_allow_origins {
      items = ["http://local.tonyfromtokyo.online:3000", "https://netflix.tonyfromtokyo.online"]
    }

    access_control_expose_headers {
      items = ["Cookie"]
    }

    access_control_max_age_sec = 3000

    origin_override = true
  }
}

resource "aws_cloudfront_origin_access_control" "output_assets_aws_cloudfront_origin_access_control" {
  name = "tonystrawberry-netflix-cloudfront-origin-access-control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_cors_configuration" "assets_aws_s3_bucket_cors_configuration" {
  bucket = aws_s3_bucket.assets_aws_s3_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT"]
    allowed_origins = ["https://tonyfromtokyo.online:3000"]
    expose_headers  = []
  }
}

# Add a CORS configuration to the S3 output bucket
resource "aws_s3_bucket_cors_configuration" "output_assets_aws_s3_bucket_cors_configuration" {
  bucket = aws_s3_bucket.output_assets_aws_s3_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT"]
    allowed_origins = ["https://tonyfromtokyo.online:3000", "https://netflix.tonyfromtokyo.online"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_policy" "output_assets_aws_s3_bucket_policy" {
    bucket = aws_s3_bucket.output_assets_aws_s3_bucket.id
    policy = data.aws_iam_policy_document.output_assets_data_iam_policy_documents.json
}

# Reference: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "output_assets_data_iam_policy_documents" {
  statement {
    sid = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
        "s3:GetObject"
    ]

    resources = [
        "${aws_s3_bucket.output_assets_aws_s3_bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.output_assets_aws_cloudfront_distribution.arn]
    }
  }
}


resource "aws_s3_bucket_notification" "s3_trigger_aws_s3_bucket_notification" {
  bucket = aws_s3_bucket.assets_aws_s3_bucket.bucket
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_aws_lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#choosing-key-groups-or-AWS-accounts
resource "aws_cloudfront_public_key" "output_assets_aws_cloudfront_public_key" {
  encoded_key = file("files/output_assets_aws_cloudfront_public_key.pem")
  name        = "tonystrawberry-netflix-output-assets-${var.environment}"
}

resource "aws_cloudfront_key_group" "output_assets_aws_cloudfront_public_key_group" {
  items   = [aws_cloudfront_public_key.output_assets_aws_cloudfront_public_key.id]
  name    = "tonystrawberry-netflix-output-assets-${var.environment}"
}

resource "aws_lambda_permission" "allow_s3_trigger_aws_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_aws_lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets_aws_s3_bucket.arn
}

resource "aws_s3_bucket_notification" "output_assets_aws_s3_bucket_notification" {
  bucket = aws_s3_bucket.output_assets_aws_s3_bucket.bucket
}

output "aws_lambda_function_arn" {
  value = aws_lambda_function.s3_trigger_aws_lambda_function.arn
}

resource "aws_iam_role" "media_convert_aws_iam_role" {
  name = "tonystrawberry-netflix-media-convert-iam-role-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "mediaconvert.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Grand permission to access the input and output S3 bucket
resource "aws_iam_policy" "media_convert_aws_iam_policy" {
  name = "tonystrawberry-netflix-media-convert-iam-policy-${var.environment}"
  description = "IAM policy for the MediaConvert role"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.assets_aws_s3_bucket.arn}/*",
          "${aws_s3_bucket.output_assets_aws_s3_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "media_convert_iam_role_policy_attachment" {
  role       = aws_iam_role.media_convert_aws_iam_role.name
  policy_arn = aws_iam_policy.media_convert_aws_iam_policy.arn
}
