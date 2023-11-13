provider "aws" {
region     ="ap-south-1"
access_key=""
secret_key=""
}
resource "aws_s3_bucket" "example" {
bucket="${var.env}-ping19bucket"
acl="private"
}

output "bucket_name" {
value="aws_s3_bucket.example.bucket"
}
