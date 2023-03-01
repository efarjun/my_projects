resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = var.oac_name
  origin_access_control_origin_type = var.oac_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}

resource "aws_cloudfront_origin_access_identity" "oai" {
}

resource "aws_cloudfront_distribution" "s3_distribution_with_function" {
  count = var.cf_function == true ? 1 : 0
  origin {
    domain_name              = var.s3_origin_name
    origin_id                = var.origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6
  comment             = var.comment
  default_root_object = var.root_object

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.origin_id

    function_association {
      event_type   = var.event_type
      function_arn = var.cloudfront_function
    }

    forwarded_values {
      query_string = var.query_string

      cookies {
        forward = var.forward
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
  }
}
  viewer_certificate {
  cloudfront_default_certificate = var.viewer_certificate
  ssl_support_method = var.ssl_support_method
  }
}

resource "aws_cloudfront_distribution" "s3_distribution_without_function" {
  count = var.cf_function == false ? 1 : 0
  origin {
    domain_name              = var.s3_origin_name
    origin_id                = var.origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6
  comment             = var.comment
  default_root_object = var.root_object

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = var.query_string

      cookies {
        forward = var.forward
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
  }
}
  viewer_certificate {
  cloudfront_default_certificate = var.viewer_certificate
  ssl_support_method = var.ssl_support_method
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_origin_name}/*"]

    principals {
      type        = var.principal_type
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_bucket_policy" {
  bucket = var.s3_origin_name
  policy = data.aws_iam_policy_document.s3_policy.json
}
