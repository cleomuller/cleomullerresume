provider "aws" {
  alias  = "eucentral1"
  region = "eu-central-1"
}

# get hosted zone details
# terraform aws data hosted zone
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
  # version = "4.67.0"
}

resource "aws_acm_certificate" "example" {
  provider = aws.useast1
  domain_name               = "cleomullerresume.net"
  subject_alternative_names = ["www.cleomullerresume.net"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "example_com" {
  provider = aws.useast1
  name         = "cleomullerresume.net"
  private_zone = false
}

resource "aws_route53_record" "example" {
  provider = aws.useast1
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.example_com.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  provider = aws.useast1
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.example_com.id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = replace(aws_cloudfront_distribution.www_s3_distribution.domain_name, "/[.]$/", "")
    zone_id                = "${aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }

  depends_on = [aws_cloudfront_distribution.www_s3_distribution]
}

resource "aws_route53_record" "www-a" {
  zone_id = "${data.aws_route53_zone.example_com.id}"
  name    = "${var.sub_domain}"
  type    = "A"

  alias {
    name                   = replace(aws_cloudfront_distribution.root_s3_distribution.domain_name, "/[.]$/", "")
    zone_id                = "${aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }

  depends_on = [aws_cloudfront_distribution.root_s3_distribution]
}