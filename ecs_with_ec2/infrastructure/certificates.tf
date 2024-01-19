#
# SSL Certificate(s) Configuration
#

# Create the certificate for our environment domain name
resource "aws_acm_certificate" "lb_certificate" {
  domain_name               = "${local.subdomain}${var.app_domain_name}"
  validation_method         = "DNS"

  # We aren't going to allow wildcard SSLs for this implementation, but 
  # below is how you would do that.
  # subject_alternative_names = ["*.${var.app_domain_name}"]
}

# Request a DNS validated certificate, deploy the required validation records and 
# wait for validation to complete.
resource "aws_acm_certificate_validation" "lb_certificate" {
  certificate_arn         = aws_acm_certificate.lb_certificate.arn
  validation_record_fqdns = [aws_route53_record.generic_certificate_validation.fqdn]
}

# Create the dns record to validate the SSL Certificate
resource "aws_route53_record" "generic_certificate_validation" {
  name    = tolist(aws_acm_certificate.lb_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.lb_certificate.domain_validation_options)[0].resource_record_type
  zone_id = local.dns_zone_id
  records = [tolist(aws_acm_certificate.lb_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}