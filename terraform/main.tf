provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# This provider is only used for ACN in the us-east-1 region.
# That is because Cloudfront is only accepting ACM certificates from the us-east-1 region.
# Reference: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html
provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}


#################
### Variables ###
#################

variable "environment" { type = string }
variable "aws_region" { type = string }
variable "aws_access_key_id" { type = string }
variable "aws_secret_access_key" { type = string }
variable "project_name" { type = string }

###############
### Storage ###
###############
resource "aws_s3_bucket" "assets_aws_s3_bucket" {
  bucket = "${var.project_name}-assets-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket" "output_videos_aws_s3_bucket" {
  bucket = "${var.project_name}-output-videos-${var.environment}"
  force_destroy = true
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


resource "aws_s3_bucket_cors_configuration" "output_videos_aws_s3_bucket_cors_configuration" {
  bucket = aws_s3_bucket.output_videos_aws_s3_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT"]
    allowed_origins = ["https://tonyfromtokyo.online:3000"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_policy" "output_videos_aws_s3_bucket_policy" {
    bucket = aws_s3_bucket.output_videos_aws_s3_bucket.id
    policy = data.aws_iam_policy_document.output_videos_data_iam_policy_documents.json
}

##########################
### CertificateManager ###
##########################

resource "aws_acm_certificate" "output_videos_aws_acm_certificate" {
  provider = aws.us-east-1

  domain_name       = "netflix.tonyfromtokyo.online"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


##################
### CloudFront ###
##################

resource "aws_cloudfront_distribution" "output_videos_aws_cloudfront_distribution" {
  aliases = ["netflix.tonyfromtokyo.online"]
  origin {
    domain_name = aws_s3_bucket.output_videos_aws_s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.output_videos_aws_cloudfront_origin_access_control.id
    origin_id = aws_s3_bucket.output_videos_aws_s3_bucket.id
  }

  enabled =  true

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods = [ "GET", "HEAD", "OPTIONS" ]
    target_origin_id = aws_s3_bucket.output_videos_aws_s3_bucket.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    trusted_key_groups = [aws_cloudfront_key_group.output_videos_aws_cloudfront_public_key_group.id]

    cache_policy_id =  data.aws_cloudfront_cache_policy.output_videos_aws_cloudfront_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.output_videos_aws_cloudfront_origin_request_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.output_videos_aws_cloudfront_response_headers_policy.id
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
    acm_certificate_arn = aws_acm_certificate.output_videos_aws_acm_certificate.arn
  }
}

data "aws_cloudfront_cache_policy" "output_videos_aws_cloudfront_cache_policy" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_origin_request_policy" "output_videos_aws_cloudfront_origin_request_policy" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_response_headers_policy" "output_videos_aws_cloudfront_response_headers_policy" {
  name    = "${var.project_name}-output-videos-${var.environment}"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["Cookie"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }

    access_control_allow_origins {
      items = ["https://tonyfromtokyo.online:3000"]
    }

    access_control_expose_headers {
      items = ["Cookie"]
    }

    access_control_max_age_sec = 3000

    origin_override = true
  }
}

resource "aws_cloudfront_origin_access_control" "output_videos_aws_cloudfront_origin_access_control" {
  name = "${var.project_name}-cloudfront-origin-access-control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Only allow CloudFront to access the S3 bucket for output videos.
# Reference: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "output_videos_data_iam_policy_documents" {
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
        "${aws_s3_bucket.output_videos_aws_s3_bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.output_videos_aws_cloudfront_distribution.arn]
    }
  }
}

# Create a CloudFront public key and key group for the output videos.
# The access to the output videos is restricted and only allowed for requests with signed cookies.
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#choosing-key-groups-or-AWS-accounts
resource "aws_cloudfront_public_key" "output_videos_aws_cloudfront_public_key" {
  encoded_key = file("files/output_videos_aws_cloudfront_public_key.pem")
  name        = "${var.project_name}-output-videos-${var.environment}"
}

resource "aws_cloudfront_key_group" "output_videos_aws_cloudfront_public_key_group" {
  items   = [aws_cloudfront_public_key.output_videos_aws_cloudfront_public_key.id]
  name    = "${var.project_name}-output-videos-${var.environment}"
}

####################
### MediaConvert ###
####################

resource "aws_iam_role" "media_convert_aws_iam_role" {
  name = "${var.project_name}-media-convert-iam-role-${var.environment}"

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

# Grant permission to MediaConvert to access the S3 buckets (both assets and output videos).
# The assets bucket is used for retrieving the input videos, and the output videos bucket is used for storing the converted videos.
resource "aws_iam_policy" "media_convert_aws_iam_policy" {
  name = "${var.project_name}-media-convert-iam-policy-${var.environment}"
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
          "${aws_s3_bucket.output_videos_aws_s3_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "media_convert_iam_role_policy_attachment" {
  role       = aws_iam_role.media_convert_aws_iam_role.name
  policy_arn = aws_iam_policy.media_convert_aws_iam_policy.arn
}
