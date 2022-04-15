data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cloudtrail_role" {
  name = var.cloudtrail_cloudwatch_role_name

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_cloudtrail" "sandbox-cloudtrail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs_bucket.id
  s3_key_prefix                 = "cloudtrailkey"
  include_global_service_events = true
  depends_on                = [aws_s3_bucket.cloudtrail_logs_bucket]
}

resource "aws_s3_bucket" "cloudtrail_logs_bucket" {
  bucket = "${var.cloudtrail_s3_bucket}-${data.aws_caller_identity.current.account_id}"
  force_destroy = "false"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.cloudtrail_logs_bucket.id

  rule {
    status = "Enabled"
    id = "180d_rule"
    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.cloudtrail_s3_bucket}-${data.aws_caller_identity.current.account_id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "S3:PutObject",
            "Resource": "arn:aws:s3:::${var.cloudtrail_s3_bucket}-${data.aws_caller_identity.current.account_id}/cloudtrailkey/AWSLogs/${data.aws_caller_identity.current.id}/*",
            "Condition": {
                "StringEquals": {
                    "S3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
})
}