resource "aws_s3_bucket" "name_of_the_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_public" {
  bucket = aws_s3_bucket.name_of_the_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_policy_for_bucket" {
  bucket = aws_s3_bucket.name_of_the_bucket.id
  policy = jsonencode({
    Version = var.version_of_policy
    Statement = [{
        Effect = "Allow"
        Action = "s3:GetObject"
        Principal = "*"
        Resource = "${aws_s3_bucket.name_of_the_bucket.arn}/*"
    }]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.aws_s3_bucket_public,
  ] 
}

resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {
  bucket = aws_s3_bucket.name_of_the_bucket.bucket

  index_document {
    suffix = var.name_of_the_index_file
  }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.name_of_the_bucket.id
  key = var.name_of_the_index_file
  source = "website/${var.name_of_the_index_file}"
  etag = filemd5("website/${var.name_of_the_index_file}")
  content_type = "text/html"
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.name_of_the_bucket.id
  key = var.name_of_the_css_file
  source = "website/${var.name_of_the_css_file}"
  etag = filemd5("website/style.css")
  content_type = "text/css"
}

resource "aws_s3_object" "js" {
  bucket = aws_s3_bucket.name_of_the_bucket.id
  key = var.name_of_the_js_file
  source = "website/${var.name_of_the_js_file}"
  etag = filemd5("website/${var.name_of_the_index_file}")
  content_type = "text/javascript"
}


# resource "aws_route53_zone" "myzone" {
#   name = var.domain_name
# }

# resource "aws_route53_record" "website_alias" {
#   zone_id = aws_route53_zone.myzone.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_s3_bucket_website_configuration.s3_bucket_website_configuration.website_domain
#     zone_id                = aws_s3_bucket.name_of_the_bucket.hosted_zone_id
#     evaluate_target_health = false
#   }
# }