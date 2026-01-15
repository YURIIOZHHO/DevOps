output "bucket_name" {
  value = aws_s3_bucket.store.bucket
  description = "Generated S3 bucket name for DB backups"
}