output "zone_arn" {
    value = aws_route53_zone.hosted_zone.arn
}
output "zone_id" {
    value = aws_route53_zone.hosted_zone.zone_id
}
