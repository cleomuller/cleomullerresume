# Resource to create S3 bucket
resource "aws_s3_bucket" "two-buckets" {
  count  = length(var.s3_bucket_names) // count is 2
  bucket = var.s3_bucket_names[count.index]

  #  acl    = "public-read"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
        "Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
          "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.s3_bucket_names[count.index]}/*"]
    }
  ]
}
EOF
}


# Redirection to subdomain
resource "aws_s3_bucket_website_configuration" "s3_root_website" {
  bucket = var.s3_bucket_names[0]

  redirect_all_requests_to {
    host_name = var.sub_domain
    protocol  = "https"
  }
}

# Index document defined
resource "aws_s3_bucket_website_configuration" "s3_sub_website" {
  bucket = var.s3_bucket_names[1]
  index_document {
    suffix = "cleomullerresume.html"
  }
}

resource "aws_s3_bucket_website_configuration" "s3_main_website" {
  bucket = var.s3_bucket_names[0]
  index_document {
    suffix = "cleomullerresume.html"
  }
}

# # Bucket versioning enabled for root and subdomain
# resource "aws_s3_bucket_versioning" "s3_version_root" {
#   bucket = var.s3_bucket_names[0]
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_versioning" "s3_version_sub" {
#   bucket = var.s3_bucket_names[1]
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

resource "aws_s3_object" "file" {
  for_each     = fileset(path.module, "content/**/*.{html,css,scss,js,png,jpg}")
  bucket       = var.s3_bucket_names[0]
  key          = replace(each.value, "/^content//", "")
  source       = each.value
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5(each.value)
}

resource "aws_s3_object" "file_upload" {
  for_each     = fileset(path.module, "content/**/*.{html,css,scss,js,png,jpg}")
  bucket       = var.s3_bucket_names[1]
  key          = replace(each.value, "/^content//", "")
  source       = each.value
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5(each.value)
}




