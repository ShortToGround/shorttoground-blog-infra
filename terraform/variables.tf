variable "CLOUDFLARE_API_TOKEN" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_ZONE_ID" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_ACCOUNT_ID" {
  type      = string
  sensitive = true
}

variable "SSH_PUBLIC_KEY" {
  type      = string
  sensitive = true
}