resource "aws_cloudfront_origin_access_control" "cf_oac" {
  name                              = var.oac_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "cf_oai" {
}

resource "aws_acm_certificate" "cert" {
  domain_name       = aws_s3_bucket.s3_bucket.id
  validation_method = "DNS"
}

resource "aws_cloudfront_distribution" "cloudfront_function_yes" {
  count = var.cf_function == true ? 1 : 0
  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = local.s3_origin_id

    function_association {
      event_type = "viewer-request"
      function_arn = local.cf_function_arn
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
  }
}
  viewer_certificate {
  cloudfront_default_certificate = true
  ssl_support_method = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "cloudfront_function_no" {
  count = var.cf_function == false ? 1 : 0
  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
  }
}
  viewer_certificate {
  cloudfront_default_certificate = true
  ssl_support_method = "sni-only"
  }
}
