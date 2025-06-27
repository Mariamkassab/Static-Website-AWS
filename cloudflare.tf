resource "cloudflare_record" "website_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "statis-bucket-site-mariam"
  value   = aws_cloudfront_distribution.s3_distribution.domain_name
  type    = "CNAME"
  proxied = true # Crucial for Cloudflare to manage traffic and provide security/caching
  ttl     = 1    # Automatic TTL
}

# Optional: Cloudflare Page Rule to force HTTPS and set caching
resource "cloudflare_page_rule" "force_https" {
  zone_id = var.cloudflare_zone_id
  target  = "http://statis-bucket-site-mariam/*" # Match HTTP requests for your domain

  actions {
    always_use_https         = true
    cache_level              = "cache_everything"
    automatic_https_rewrites = "on"
  }

  priority = 1 # Higher priority (lower number) means it's evaluated first
  status   = "active"
}