variable "s3_bucket_names" {
  type    = list(any)
  default = ["cleomullerresume.net", "www.cleomullerresume.net"]
}

# Setting variable for subdomain hostname
variable "domain_name" {
  description = "domain name"
  type        = string
  default     = "cleomullerresume.net"
}

variable "cloudfront_distribution" {
  default = "Z2FDTNDATAQYW2"
}

variable "sub_domain" {
  description = "sub domain name"
  type        = string
  default     = "www.cleomullerresume.net"
}
