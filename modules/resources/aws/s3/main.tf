resource "aws_s3_bucket" "bucket_resource" {
  bucket                        = var.bucket_name
  tags                          = {"Name": var.bucket_name, "ResourceName": "bucket_resource@${local.resource_path}"}

}
resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket                        = aws_s3_bucket.bucket_resource.id
  block_public_acls             = true
  block_public_policy           = true
  ignore_public_acls            = true
}
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count                        = var.expiration_in_days > 0 ? 1: 0
  bucket                       = aws_s3_bucket.bucket_resource.id
  rule {
    id     = "objectDelete"
    status = "Enabled"
    expiration {
      days          = var.expiration_in_days
    }
  }
}
resource "aws_iam_policy" "bucket_policy" {
  name                      = "${var.bucket_name}_s3_bucket_policy"
  path                      = "/"
  description               = "S3 Actions policy for ${var.bucket_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ObjectOperations",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}/*",
           "arn:aws:s3:::${var.bucket_name}*"
        ]
      },
      {
        "Sid" : "BucketOperations",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bucket_policy_attachment" {
  role       = var.iam_role_name
  policy_arn = aws_iam_policy.bucket_policy.arn
}
