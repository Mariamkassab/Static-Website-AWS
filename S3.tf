resource "aws_s3_bucket" "static_website" {
  bucket = "statis-bucket-site-mariam"
  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure the S3 bucket for static website hosting
# This creates the website endpoint URL. Cloudflare will proxy to this.
resource "aws_s3_bucket_website_configuration" "static_website_config" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }
}
