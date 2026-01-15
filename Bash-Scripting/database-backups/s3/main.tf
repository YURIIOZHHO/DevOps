resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "store" {
  bucket = "${var.bucket_name}-${random_id.suffix.hex}"

  tags = {
    Name = "backup bucket"
  }
}

