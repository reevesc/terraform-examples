#
# Route53 Hosted Zone
#

# If var.create_dns_zone is true, create a hosted zone record
resource "aws_route53_zone" "hosted_zone" {
  count = var.create_dns_zone ? 1 : 0
  name  = var.app_domain_name
}

# If var.create_dns_zone is false, retrieve the existing hosted zone record
data "aws_route53_zone" "hosted_zone" {
  count = var.create_dns_zone ? 0 : 1
  name  = var.app_domain_name
}

locals {
  dns_zone_id = var.create_dns_zone ? aws_route53_zone.hosted_zone[0].zone_id : data.aws_route53_zone.hosted_zone[0].zone_id
  subdomain = var.environment_name == "production" ? "" : "${var.environment_name}."
}

# Create an A record for the hosted zone and set an alias to the load balancer.
resource "aws_route53_record" "root" {
  zone_id = local.dns_zone_id
  # name    = "${local.subdomain}${var.app_domain_name}"
  name    = aws_acm_certificate.lb_certificate.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}
