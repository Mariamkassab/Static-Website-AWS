terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.9.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

