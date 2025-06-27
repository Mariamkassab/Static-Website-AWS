variable "cloudflare_api_token" {
  description = "Cloudflare API Token with DNS and Zone:Edit permissions."
  type        = string
  sensitive   = true # Mark as sensitive to prevent showing in plan/output
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for your domain."
  type        = string
}

# Cloudflare Account ID
# You can find this in your Cloudflare dashboard, under 'My Profile' -> 'API Tokens' -> 'View' next to your token.
variable "cloudflare_account_id" {
  description = "Cloudflare Account ID."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront HTTPS (must be in us-east-1)."
  type        = string
}