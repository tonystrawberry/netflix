provider "aws" {
  region = "ap-northeast-1"
}

data "archive_file" "s3_trigger_aws_lambda_function" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda/s3_trigger_aws_lambda_function.zip"
}

resource "aws_lambda_function" "s3_trigger_aws_lambda_function" {
  function_name    = "tonystrawberry-netflix-s3-trigger"
  role             = "${aws_iam_role.lambda_aws_iam_role.arn}"
  handler          = "s3_trigger_aws_lambda_function.lambda_handler"
  runtime          = "ruby3.3"
  timeout          = "600"
  filename         = "${data.archive_file.s3_trigger_aws_lambda_function.output_path}"
  source_code_hash = "${data.archive_file.s3_trigger_aws_lambda_function.output_base64sha256}"

  environment {
    variables = {
      DestinationBucket = "${aws_s3_bucket.output_video_aws_s3_bucket.bucket}"
      MediaConvertRole = "${aws_iam_role.media_convert_aws_iam_role.arn}"
    }
  }
}

resource "aws_iam_role" "lambda_aws_iam_role" {
  name = "tonystrawberry-netflix-lambda-iam-role"

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
  name = "tonystrawberry-netflix-lambda-iam-policy"
  description = "IAM policy for the API Lambda function"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
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

resource "aws_s3_bucket" "input_video_aws_s3_bucket" {
  bucket = "tonystrawberry-netflix-input-video"
}

resource "aws_s3_bucket" "output_video_aws_s3_bucket" {
  bucket = "tonystrawberry-netflix-output-video"
}

# Add a CORS configuration to the S3 output bucket
resource "aws_s3_bucket_cors_configuration" "output_video_aws_s3_bucket_cors_configuration" {
  bucket = aws_s3_bucket.output_video_aws_s3_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_notification" "s3_trigger_aws_s3_bucket_notification" {
  bucket = aws_s3_bucket.input_video_aws_s3_bucket.bucket
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_aws_lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mp4"
  }
}



resource "aws_lambda_permission" "allow_s3_trigger_aws_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_aws_lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_video_aws_s3_bucket.arn
}

resource "aws_s3_bucket_notification" "output_video_aws_s3_bucket_notification" {
  bucket = aws_s3_bucket.output_video_aws_s3_bucket.bucket
}

output "aws_lambda_function_arn" {
  value = aws_lambda_function.s3_trigger_aws_lambda_function.arn
}

resource "aws_iam_role" "media_convert_aws_iam_role" {
  name = "tonystrawberry-netflix-media-convert-iam-role"

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
  name = "tonystrawberry-netflix-media-convert-iam-policy"
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
          "${aws_s3_bucket.input_video_aws_s3_bucket.arn}/*",
          "${aws_s3_bucket.output_video_aws_s3_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "media_convert_iam_role_policy_attachment" {
  role       = aws_iam_role.media_convert_aws_iam_role.name
  policy_arn = aws_iam_policy.media_convert_aws_iam_policy.arn
}
