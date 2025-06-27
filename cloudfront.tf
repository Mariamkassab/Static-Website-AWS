resource "aws_cloudfront_origin_access_control" "static_website_oac" {
  name                              = "statis-bucket-site-mariam-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "s3_bucket_policy_oac" {
  statement {
    principals {
      type = "Service"
      # The CloudFront service principal
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.static_website.arn}/*",
    ]

    condition {
      # This condition ensures that access is only allowed for requests
      # coming from the specific CloudFront OAC.
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_origin_access_control.static_website_oac.arn]
    }

    effect = "Allow"
  }
}

# Attach the policy to the S3 bucket
resource "aws_s3_bucket_policy" "allow_cloudfront_oac" {
  bucket = aws_s3_bucket.static_website.id
  policy = data.aws_iam_policy_document.s3_bucket_policy_oac.json
}

##############################################
# AWS CloudFront Distribution #
##############################################

resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.static_website.id
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution"
  default_root_object = "index.html" # Default file to serve when accessing root URL

  # Aliases (CNAMEs) for the distribution. These are the domain names
  # that will point to this CloudFront distribution.
  aliases = [aws_s3_bucket.static_website.bucket]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.static_website.id

    # Configure viewer protocol policy to redirect HTTP to HTTPS
    viewer_protocol_policy = "redirect-to-https"
  }

  # Restrict access to only HTTPS
  viewer_certificate {
    cloudfront_default_certificate = false # We are using a custom certificate
    acm_certificate_arn            = aws_acm_certificate.website_cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


resource "aws_acm_certificate" "website_cert" {
  provider          = aws.us-east-1
  domain_name       = "Mero-site.com"
  validation_method = "DNS"

  tags = {
    Name = "acm-cert"
  }
}