resource "cloudflare_record" "website_cname" {
  zone_id = var.cloudflare_zone_id
  name    = aws_s3_bucket.static_website.bucket
  value   = aws_cloudfront_distribution.s3_distribution.domain_name
  type    = "CNAME"
  proxied = true # Crucial for Cloudflare to manage traffic and provide security/caching
  ttl     = 1    # Automatic TTL
}

resource "cloudflare_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      value  = dvo.resource_record_value
      type   = dvo.resource_record_type
      domain = dvo.domain_name
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  ttl     = 1     # Automatic TTL
  proxied = false # Validation records MUST NOT be proxied by Cloudflare
}

##############################################
# ACM Certificate Validation #
##############################################

# This resource waits for the ACM certificate to be successfully validated
# by checking if the DNS validation records are propagated and verified by ACM.
resource "aws_acm_certificate_validation" "website_cert_validation" {
  provider        = aws.us-east-1 # Ensure validation is tied to the us-east-1 cert
  certificate_arn = aws_acm_certificate.website_cert.arn
  # Ensure validation records are created before validation occurs
  validation_record_fqdns = [for record in cloudflare_record.acm_validation : record.hostname]
}
